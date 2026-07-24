# sab_asi — in-process engine SDK for The Saboteur

A 32-bit DLL you inject into `Saboteur.exe`. It gives two live seams into the engine, both running on
the game's own threads at full speed — **no debugger, no breakpoints, no process freeze**, so it can't
trigger the "resume after a full-process pause" crash that a debugger read does.

1. **Dynamic hooks** (MinHook detours) that read engine state and append it to `sab_devlog.txt` next to
   the exe. Shipped hook: the human body-setup at `0x518490`, logging `[ecx+0x60]` (the combined-LOD
   model handle) plus the neighbouring blueprint / LOD-slot fields.
2. A **`Dev.*` Lua binding surface**: our own C functions registered into the live `lua_State` by
   piggy-backing on the engine's own table-publish routine (`0x6f8a90`). Callable from the game console
   or any script. Shipped: `Dev.Mark()`, `Dev.DumpNextBodySetup()`.

All engine addresses (retail GOG `Saboteur.exe`, imagebase `0x400000`, no ASLR) live in one place:
[`src/lib.rs` → `mod addrs`](src/lib.rs). A patched exe = update that module only.

## Build

```
cargo build --release           # target i686-pc-windows-msvc is pinned in .cargo/config.toml
```
One-time: `rustup target add i686-pc-windows-msvc`. Output: `target/i686-pc-windows-msvc/release/sab_asi.dll`.

## Inject

**Ultimate ASI Loader** (recommended):
1. Drop Ultimate ASI Loader in the game folder as `dinput8.dll` (the game loads `dinput8` from its own
   dir before SysWOW64 — confirmed; it is not a KnownDLL).
2. Copy `sab_asi.dll` → the game folder as **`sab_asi.asi`**.
3. Launch. The loader loads every `*.asi` at startup — early enough to hook the per-level VM publish.

**DXwrapper** works too (proxy `d3d9.dll`); point its plugin/ASI loading at `sab_asi.asi`.

## Use

- **Passive:** launch, reach gameplay, **swap a disguise** (rebuilds the player body). Watch
  `sab_devlog.txt` for `[bodysetup] this=… +0x60=…`. Do it somewhere quiet so the hit is unambiguously
  the player.
- **Targeted:** open the game console and call `Dev.DumpNextBodySetup()`, then swap the disguise — the
  next body-setup logs the full struct window (`+0x60`, `+0x78`, `+0xa4/a8/ac`) as `[bodysetup*]`.

## Interpreting `+0x60`

The log prints the raw 32-bit value. If it's a heap-looking pointer (`0x0C……`/`0x1……`), it points at a
model object — add a follow-up read of its name field. If it's a scattered 32-bit value, it's a
`pandemic_hash` — resolve it against the asset name tables (`pandemic_hash` is in `sab_workshop/pack.rs`).
That resolved name is the combined-LOD WSModel to override / disable for the transparency fix.

## Status / next

- Builds clean as a 32-bit DLL; **not yet run in-process** (needs the game + a loader). First run =
  confirm the two log lines appear.
- Grow `Dev.*` once `L`-capture is confirmed: `Dev.PlayerModel()`, `Dev.OverrideCombinedLOD(hash)` to
  test the fix live without repacking assets.
