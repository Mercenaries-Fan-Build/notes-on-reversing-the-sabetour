//! sab_asi — an in-process engine SDK for The Saboteur (retail GOG `Saboteur.exe`).
//!
//! The game is a 32-bit process loaded at a fixed base `0x400000` (no ASLR — verified live), so every
//! engine VA below is absolute and callable/hookable directly. Two surfaces:
//!
//!   1. **Dynamic hooks** (MinHook detours) that read engine state and append it to `sab_devlog.txt`
//!      next to the exe. Runs at full engine speed on the game's own threads — no debugger, no pause,
//!      so it cannot trigger the "resume after a full-process freeze" crash a breakpoint does.
//!   2. A **`Dev.*` Lua binding surface**: we register our own C functions into the live `lua_State`
//!      by piggy-backing on the engine's own table-publish routine, so they're callable from the
//!      game console / any script — a permanent live-inspection seam.
//!
//! Injection: build as a cdylib, rename to `sab_asi.asi`, and load it with Ultimate ASI Loader
//! (proxy `dinput8.dll`) or DXwrapper dropped in the game folder. See README.md.
//!
//! Engine facts are sourced from `docs/sab-engine-lua-seam/` and the Ghidra decomp; see `addrs`.

#![allow(non_snake_case)]
#![allow(clippy::missing_safety_doc)]

use core::ffi::{c_char, c_int, c_void};
use std::fs::OpenOptions;
use std::io::Write;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Mutex, OnceLock};

/// Engine virtual addresses. Imagebase `0x400000`, no ASLR (confirmed: the module list reports base
/// `0x400000` under the debugger, and the decomp's absolute call targets resolve 1:1). If a future
/// build/patch shifts these, only this module changes.
mod addrs {
    /// `__thiscall` human body-setup (`WSFxHumanBodySetup`). `ecx` = the setup object; `+0x60` is the
    /// combined-LOD model handle (`SetupCombinedLODModel`'s write target). 15 params total
    /// (`this` + 14 stack args) — the detour must forward all of them.
    pub const BODY_SETUP: usize = 0x0051_8490;

    /// `__thiscall(manager, undefined4* pL)` — runs once per level load; publishes the engine's 26 Lua
    /// namespace tables. `L == *pL` (it feeds `*pL` to `luaL_register`/`luaL_loadstring`/`lua_pcall`).
    /// We hook it to grab `L` and append our own table right after. (docs/sab-engine-lua-seam/00 §7.1)
    pub const REGISTER_BINDINGS: usize = 0x006f_8a90;

    /// stock `luaL_openlib(lua_State* L, const char* libname, const luaL_Reg* l, int nup)` — cdecl.
    /// Creates-or-reuses the global table and installs the entries. (00 §7.1)
    pub const LUAL_OPENLIB: usize = 0x015f_d2d0;

    // Reserved for later Dev bindings that run Lua or resolve handles:
    #[allow(dead_code)]
    pub const LUA_PCALL: usize = 0x0040_8310; // cdecl lua_pcall(L, nargs, nresults, errfunc)
    #[allow(dead_code)]
    pub const LUAL_LOADSTRING: usize = 0x015f_e1a0; // cdecl luaL_loadstring(L, const char*)
}

// ─────────────────────────── logging sink ───────────────────────────

static LOG: OnceLock<Mutex<std::fs::File>> = OnceLock::new();

fn logf(args: std::fmt::Arguments) {
    if let Some(m) = LOG.get() {
        if let Ok(mut f) = m.lock() {
            let _ = writeln!(f, "{args}");
            let _ = f.flush();
        }
    }
}
macro_rules! log {
    ($($t:tt)*) => { crate::logf(format_args!($($t)*)) };
}

/// `sab_devlog.txt` beside the host exe (`current_exe()` in an injected DLL is `Saboteur.exe`).
fn log_path() -> std::path::PathBuf {
    std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(|d| d.join("sab_devlog.txt")))
        .unwrap_or_else(|| "sab_devlog.txt".into())
}

/// Read a 32-bit word from process memory. Callers pass engine object pointers we already trust
/// (e.g. `this + 0x60`); a null base reads nothing. This is deliberately not SEH-guarded — the hook
/// sites hand us live, valid objects.
#[inline]
unsafe fn rd32(p: usize) -> u32 {
    if p == 0 {
        return 0;
    }
    core::ptr::read_unaligned(p as *const u32)
}

// ─────────────────────── dynamic hook: body setup ───────────────────────

/// `WSFxHumanBodySetup` setup, forwarding all 15 args unchanged. `undefined4` stack args are opaque
/// 4-byte slots — typing them `u32` preserves the callee-cleanup stack contract.
type BodySetupFn = unsafe extern "thiscall" fn(
    *mut c_void,
    u32, u32, u32, u32, u32, u32, u32, u32, u32, u32, u32, u32, u32, u32,
);
static BODY_ORIG: OnceLock<BodySetupFn> = OnceLock::new();

/// De-dup sets so the log stays readable: each distinct body-setup object and each distinct combined-LOD
/// model object is logged ONCE, not once per frame (the raw hook fires ~thousands/sec).
/// `Dev.DumpNextBodySetup()` clears both, forcing a fresh round of dumps (e.g. right after a disguise swap).
static SEEN_THIS: Mutex<Vec<u32>> = Mutex::new(Vec::new());
static SEEN_MODEL: Mutex<Vec<u32>> = Mutex::new(Vec::new());

/// True if `v` did not already contain `k` (and inserts it).
fn first_time(set: &Mutex<Vec<u32>>, k: u32) -> bool {
    let mut v = set.lock().unwrap();
    if v.contains(&k) {
        false
    } else {
        v.push(k);
        true
    }
}

/// A plausible in-process heap pointer (the observed combined-LOD objects sit at `0x0a……`–`0x2d……`).
#[inline]
fn looks_like_ptr(p: u32) -> bool {
    (0x0001_0000..0x7f00_0000).contains(&p)
}

/// Read `n` bytes at `addr` as space-separated LE dwords, for structure spelunking.
unsafe fn dump_words(addr: usize, n: usize) -> String {
    let mut s = String::with_capacity(n * 3);
    for i in 0..n / 4 {
        s.push_str(&format!("{:08x} ", rd32(addr + i * 4)));
    }
    s
}

#[allow(clippy::too_many_arguments)]
unsafe extern "thiscall" fn body_setup_detour(
    this: *mut c_void,
    a2: u32, a3: u32, a4: u32, a5: u32, a6: u32, a7: u32, a8: u32,
    a9: u32, a10: u32, a11: u32, a12: u32, a13: u32, a14: u32, a15: u32,
) {
    let t = this as usize;
    let p60 = rd32(t + 0x60);
    if first_time(&SEEN_THIS, t as u32) {
        log!(
            "[bodysetup] this=0x{:08x} +0x60=0x{:08x} +0x78(bp)=0x{:08x} +0xa4=0x{:08x}",
            t, p60, rd32(t + 0x78), rd32(t + 0xa4)
        );
    }
    // First time we see each distinct WSFxHumanBodyPartBlueprint at +0x60, dump 0x90 bytes (so we
    // capture the combined-LOD model pointer at partBP+0x84 — per sab-mattias-port-bugs), then FOLLOW
    // that pointer and dump the combined-LOD WSModel itself so we can name it (its +0x40 name-hash).
    if looks_like_ptr(p60) && first_time(&SEEN_MODEL, p60) {
        let m = p60 as usize;
        log!(
            "[partBP] ptr=0x{:08x} vtable=0x{:08x} | {}",
            p60, rd32(m), dump_words(m, 0x90)
        );
        let lod = rd32(m + 0x84);
        if looks_like_ptr(lod) {
            log!(
                "[lodmodel] via partBP+0x84 ptr=0x{:08x} vtable=0x{:08x} | {}",
                lod, rd32(lod as usize), dump_words(lod as usize, 0x60)
            );
        } else {
            log!("[lodmodel] partBP+0x84=0x{lod:08x} (not a pointer — no combined-LOD model set)");
        }
    }
    (BODY_ORIG.get().unwrap())(
        this, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
    )
}

// ─────────────────── binding surface: Dev.* Lua table ───────────────────

/// stock `luaL_Reg` — `{ const char *name; lua_CFunction func; }`.
#[repr(C)]
struct LuaLReg {
    name: *const c_char,
    func: Option<unsafe extern "C" fn(*mut c_void) -> c_int>,
}
type LuaLOpenlib = unsafe extern "C" fn(*mut c_void, *const c_char, *const LuaLReg, c_int);

type RegBindingsFn = unsafe extern "thiscall" fn(*mut c_void, *mut *mut c_void);
static REG_ORIG: OnceLock<RegBindingsFn> = OnceLock::new();

/// The live `lua_State*`, captured the first time the engine publishes its tables.
static LUA_STATE: AtomicUsize = AtomicUsize::new(0);

unsafe extern "thiscall" fn reg_bindings_detour(manager: *mut c_void, p_l: *mut *mut c_void) {
    // Let the engine create its own 26 tables first, then graft ours on.
    (REG_ORIG.get().unwrap())(manager, p_l);
    let l = *p_l; // L == *param_2  (docs/sab-engine-lua-seam/00 §7.1)
    LUA_STATE.store(l as usize, Ordering::SeqCst);
    register_dev(l);
    log!("[lua] Dev.* registered on L=0x{:08x}", l as usize);
}

// ---- Dev.* implementations (cdecl `lua_CFunction`: int f(lua_State*)) ----

/// `Dev.Mark()` — write a separator to the log so you can bracket an experiment.
unsafe extern "C" fn dev_mark(_l: *mut c_void) -> c_int {
    log!("──── Dev.Mark ────");
    0
}

/// `Dev.DumpNextBodySetup()` — clear the de-dup sets so every body-setup/model re-logs once more.
/// Call it, then swap a disguise, to force a fresh capture of the player's rebuilt body.
unsafe extern "C" fn dev_dump_next(_l: *mut c_void) -> c_int {
    SEEN_THIS.lock().unwrap().clear();
    SEEN_MODEL.lock().unwrap().clear();
    log!("[lua] Dev.DumpNextBodySetup: seen-sets cleared, will re-dump");
    0
}

unsafe fn register_dev(l: *mut c_void) {
    // luaL_openlib copies these into the table during the call, so a local array is fine.
    let regs = [
        LuaLReg { name: b"Mark\0".as_ptr() as *const c_char, func: Some(dev_mark) },
        LuaLReg { name: b"DumpNextBodySetup\0".as_ptr() as *const c_char, func: Some(dev_dump_next) },
        LuaLReg { name: core::ptr::null(), func: None },
    ];
    let openlib: LuaLOpenlib = core::mem::transmute(addrs::LUAL_OPENLIB);
    openlib(l, b"Dev\0".as_ptr() as *const c_char, regs.as_ptr(), 0);
}

// ─────────────────────────── install / entry ───────────────────────────

use minhook_sys::{MH_CreateHook, MH_EnableHook, MH_Initialize, MH_OK};

unsafe fn create(target: usize, detour: usize) -> Result<*mut c_void, String> {
    let mut orig: *mut c_void = core::ptr::null_mut();
    let st = MH_CreateHook(target as *mut c_void, detour as *mut c_void, &mut orig);
    if st != MH_OK {
        return Err(format!("MH_CreateHook(0x{target:08x}) = {st}"));
    }
    Ok(orig)
}

unsafe fn install() -> Result<(), String> {
    if MH_Initialize() != MH_OK {
        return Err("MH_Initialize failed".into());
    }
    let orig = create(addrs::BODY_SETUP, body_setup_detour as *const () as usize)?;
    BODY_ORIG.set(core::mem::transmute::<*mut c_void, BodySetupFn>(orig)).ok();

    let orig = create(addrs::REGISTER_BINDINGS, reg_bindings_detour as *const () as usize)?;
    REG_ORIG.set(core::mem::transmute::<*mut c_void, RegBindingsFn>(orig)).ok();

    // MH_ALL_HOOKS == null.
    if MH_EnableHook(core::ptr::null_mut()) != MH_OK {
        return Err("MH_EnableHook failed".into());
    }
    Ok(())
}

fn init() {
    if let Ok(f) = OpenOptions::new().create(true).append(true).open(log_path()) {
        let _ = LOG.set(Mutex::new(f));
    }
    log!("═══ sab_asi attached ═══");
    match unsafe { install() } {
        Ok(()) => log!("hooks installed: bodysetup@0x518490, regbindings@0x6f8a90"),
        Err(e) => log!("INSTALL FAILED: {e}"),
    }
}

/// Standard cdylib entry. Do no real work under the loader lock — spin up a thread.
#[no_mangle]
pub extern "system" fn DllMain(_module: *mut c_void, reason: u32, _reserved: *mut c_void) -> i32 {
    const DLL_PROCESS_ATTACH: u32 = 1;
    if reason == DLL_PROCESS_ATTACH {
        std::thread::spawn(init);
    }
    1
}
