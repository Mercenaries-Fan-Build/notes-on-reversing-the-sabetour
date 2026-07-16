// sab_map6 - reader for The Saboteur (2009) MAP6 files.
//
// Two container variants share the same magic and record *core*:
//   * global.map  -> loaded by FUN_009f3370 @0x009f3370 (the world/asset registry)
//   * <region>.map (e.g. FRANCE.map) -> loaded by FUN_009f75f0 @0x009f75f0
//
// The global.map layout is fully reverse-engineered and validated byte-exact
// (parse cursor lands on EOF with 0 leftover). The <region>.map layout shares
// the record core but adds conditional variable-length sub-lists that are only
// partially decoded; region files are parsed best-effort and the reader reports
// exactly how many bytes it could account for.
//
// std-only. Usage:  sab_map6 <path-to.map>
//
// All multi-byte integers/floats in these two files are little-endian.
// (Magic bytes on disk are "6PAM" = 0x4D41'5036 read LE, checked at
//  FUN_009f3370 line ~885179 / FUN_0049ee70 @0x0049ee70 = read-u32.)

use std::env;
use std::fs;
use std::process::exit;

const MAGIC: u32 = 0x4D41_5036; // "6PAM" little-endian

/// Pandemic FNV-1a variant used by the engine for asset/object name ids.
/// basis 0x811C9DC5; per byte  h = ((c|0x20) ^ h) * 0x01000193 ; finalize (h ^ 0x2A) * 0x01000193
/// Verified: phash("ANY") == 0xED057225, phash("MM_Belle_VIP") == 0x315C74B2,
///           phash("KnifeThrow") == 0xFB5E3070 (both match the on-disk record hashes).
fn pandemic_hash(s: &str) -> u32 {
    let mut h: u32 = 0x811C_9DC5;
    for &c in s.as_bytes() {
        h = ((((c as u32) | 0x20) ^ h).wrapping_mul(0x0100_0193)) & 0xFFFF_FFFF;
    }
    ((h ^ 0x2A).wrapping_mul(0x0100_0193)) & 0xFFFF_FFFF
}

/// Tiny reverse dictionary: known names whose hashes we can resolve.
/// (Record names in the file are stored as plain strings, so they self-resolve;
///  sub-entry hashes reference asset/animation names not stored in the file.)
const KNOWN_NAMES: &[&str] = &[
    "MM_Belle_VIP",
    "KnifeThrow",
    "ANY",
    "FRANCE",
    "Global",
];

fn resolve(hash: u32) -> Option<&'static str> {
    KNOWN_NAMES.iter().copied().find(|n| pandemic_hash(n) == hash)
}

struct Cur<'a> {
    d: &'a [u8],
    p: usize,
}
impl<'a> Cur<'a> {
    fn new(d: &'a [u8]) -> Self { Cur { d, p: 0 } }
    fn rem(&self) -> usize { self.d.len().saturating_sub(self.p) }
    fn u16(&mut self) -> Option<u16> {
        if self.rem() < 2 { return None; }
        let v = u16::from_le_bytes([self.d[self.p], self.d[self.p + 1]]);
        self.p += 2; Some(v)
    }
    fn u32(&mut self) -> Option<u32> {
        if self.rem() < 4 { return None; }
        let v = u32::from_le_bytes(self.d[self.p..self.p + 4].try_into().unwrap());
        self.p += 4; Some(v)
    }
    fn f32(&mut self) -> Option<f32> { self.u32().map(f32::from_bits) }
    fn vec3(&mut self) -> Option<[f32; 3]> {
        Some([self.f32()?, self.f32()?, self.f32()?])
    }
    /// null-terminated string, consuming exactly `len` bytes (len includes the NUL).
    fn fixed_cstr(&mut self, len: usize) -> Option<String> {
        if self.rem() < len { return None; }
        let raw = &self.d[self.p..self.p + len];
        self.p += len;
        let end = raw.iter().position(|&b| b == 0).unwrap_or(len);
        Some(String::from_utf8_lossy(&raw[..end]).into_owned())
    }
    /// null-terminated string (reads until NUL, like engine FUN_00dbb000).
    fn cstr(&mut self) -> Option<String> {
        let start = self.p;
        while self.p < self.d.len() && self.d[self.p] != 0 { self.p += 1; }
        if self.p >= self.d.len() { return None; }
        let s = String::from_utf8_lossy(&self.d[start..self.p]).into_owned();
        self.p += 1; // consume NUL
        Some(s)
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("usage: {} <global.map | region.map>", args[0]);
        exit(2);
    }
    let data = match fs::read(&args[1]) {
        Ok(d) => d,
        Err(e) => { eprintln!("error: cannot read {}: {}", args[1], e); exit(1); }
    };
    println!("file: {}  ({} bytes)", args[1], data.len());

    if data.len() < 8 || u32::from_le_bytes(data[0..4].try_into().unwrap()) != MAGIC {
        eprintln!("error: not a MAP6 file (bad magic)");
        exit(1);
    }

    // Variant detection: byte[4] is an ASCII letter for region files (region name
    // string follows the magic); for global.map byte[4..8] is a u32 count.
    let is_region = data[4].is_ascii_alphabetic();
    let consumed = if is_region {
        parse_region(&data)
    } else {
        parse_global(&data)
    };

    println!("\n=== VALIDATION (oracle: cursor must consume file exactly) ===");
    println!("bytes consumed : {}", consumed);
    println!("file size      : {}", data.len());
    let leftover = data.len() as isize - consumed as isize;
    println!("leftover       : {}", leftover);
    if leftover == 0 {
        println!("RESULT         : EXACT ✓ (0 leftover)");
    } else {
        println!("RESULT         : NOT EXACT ({} bytes unaccounted)", leftover);
    }
}

// -------- global.map ---------------------------------------------------------
//
// Header (16 bytes):
//   u32 magic  = 0x4D415036 ("6PAM")           file 0x00
//   u32 count  = number of records             file 0x04  (=2 in DLC/01/Global.map)
//   u32 pad0   = 0 (reserved)                  file 0x08
//   u32 pad1   = 0 (reserved)                  file 0x0C
//
// Record (variable length):
//   u32   name_hash      pandemic_hash(name)   e.g. 0x315C74B2 = phash("MM_Belle_VIP")
//   u16   name_len       length incl. NUL      e.g. 13
//   u8    name[name_len] NUL-terminated
//   f32x3 vecA           (0,0,0) in this file  -- read as two 12-byte blocks by
//   f32x3 vecB           (0,0,0) in this file     FUN_00dbb2d0(&buf,0xc) x2 in decomp
//   u16   field_c        =1
//   u16   field_d        =2
//   u32   sub_count      number of sub-entries
//   sub_count x {                              -- referenced asset/anim name-hashes
//       u32 hash                                  (+ two u16 flag/param words)
//       u16 flag_a
//       u16 flag_b
//   }
//   [56-byte trailer]  u32[0]=0, u32[1]=? (28 / 388), u32[2]=0,
//                      u32[3]=sub_count (echo), remaining 40 bytes mostly 0.
fn parse_global(d: &[u8]) -> usize {
    let mut c = Cur::new(d);
    c.u32(); // magic
    let count = c.u32().unwrap_or(0);
    let pad0 = c.u32().unwrap_or(0);
    let pad1 = c.u32().unwrap_or(0);
    println!("variant: GLOBAL");
    println!("header: magic=MAP6 count={} reserved=[{},{}]", count, pad0, pad1);

    for r in 0..count {
        let start = c.p;
        let hash = match c.u32() { Some(v) => v, None => { println!("  <truncated>"); break; } };
        let nlen = c.u16().unwrap_or(0) as usize;
        let name = c.fixed_cstr(nlen).unwrap_or_default();
        let va = c.vec3().unwrap_or([0.0; 3]);
        let vb = c.vec3().unwrap_or([0.0; 3]);
        let fc = c.u16().unwrap_or(0);
        let fd = c.u16().unwrap_or(0);
        let sub = c.u32().unwrap_or(0);

        let self_ok = pandemic_hash(&name) == hash;
        println!("\nRecord {} @0x{:X}  '{}'", r, start, name);
        println!("  name_hash = 0x{:08X}  (phash('{}')=0x{:08X} match={})",
                 hash, name, pandemic_hash(&name), self_ok);
        println!("  vecA={:?} vecB={:?}  field_c={} field_d={}", va, vb, fc, fd);
        println!("  sub_count = {}", sub);
        for i in 0..sub {
            let sh = c.u32().unwrap_or(0);
            let a = c.u16().unwrap_or(0);
            let b = c.u16().unwrap_or(0);
            let res = resolve(sh).map(|n| format!(" -> '{}'", n)).unwrap_or_default();
            println!("    sub[{:2}] hash=0x{:08X} flag_a=0x{:04X} flag_b=0x{:04X}{}",
                     i, sh, a, b, res);
        }
        // 56-byte fixed trailer.
        let mut trailer = [0u32; 14];
        for t in trailer.iter_mut() { *t = c.u32().unwrap_or(0); }
        println!("  trailer[1]=0x{:X} trailer[3]={} (== sub_count: {})",
                 trailer[1], trailer[3], trailer[3] == sub);
    }
    c.p
}

// -------- <region>.map (e.g. FRANCE.map) -------------------------------------
//
// Header:
//   u32   magic  = 0x4D415036                  file 0x00
//   cstr  region_name (NUL-terminated)         file 0x04  ("FRANCE\0")
//   u32   unknown (FUN_00427cb0)               after name
// Then THREE record categories, each:
//   u32   category_count
//   category_count x record
//
// The record CORE matches global.map:
//   u32 field0, u16 name_len, name[], f32x3 min, f32x3 max, u16, u16
// (readers FUN_009f3900 / FUN_009f3bf0 / FUN_009f3fa0). vecA/vecB are the
// min/max corners of an axis-aligned streaming tile -- confirmed by real values
// e.g. (0,0,0)-(500,0,500), (60,0,360)-(120,0,420) in FRANCE.map.
//
// NOTE: some region records carry a conditional trailing hash-list
// (u32 count then count x u32 name-hash, e.g. count=4 @0x00CF). The trigger
// condition is not fully decoded, so this parser is best-effort and stops at
// the first record whose core no longer validates, reporting the cursor.
fn parse_region(d: &[u8]) -> usize {
    let mut c = Cur::new(d);
    c.u32(); // magic
    let name = c.cstr().unwrap_or_default();
    let unk = c.u32().unwrap_or(0);
    println!("variant: REGION  name='{}'  header_unk=0x{:X}", name, unk);

    for cat in 0..3 {
        let cnt = match c.u32() { Some(v) => v, None => { println!("  <no more categories>"); return c.p; } };
        println!("\ncategory {}: count={}  (records start @0x{:X})", cat, cnt, c.p);
        for r in 0..cnt {
            let start = c.p;
            let f0 = match c.u32() { Some(v) => v, None => { println!("  <truncated>"); return c.p; } };
            let nlen = c.u16().unwrap_or(0xFFFF) as usize;
            if nlen > 256 || c.rem() < nlen + 28 {
                // core no longer validates -> stop, keep honest cursor at record start.
                println!("  desync at record {} @0x{:X} (name_len={} implausible); stopping.",
                         r, start, nlen);
                return start;
            }
            let name = c.fixed_cstr(nlen).unwrap_or_default();
            let mn = c.vec3().unwrap_or([0.0; 3]);
            let mx = c.vec3().unwrap_or([0.0; 3]);
            let a = c.u16().unwrap_or(0);
            let b = c.u16().unwrap_or(0);
            if r < 6 {
                println!("  rec{:2} @0x{:X} field0=0x{:08X} name='{}' min={:?} max={:?} u16=({},{})",
                         r, start, f0, name, mn, mx, a, b);
            }
        }
    }
    c.p
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn hashes() {
        assert_eq!(pandemic_hash("ANY"), 0xED05_7225);
        assert_eq!(pandemic_hash("MM_Belle_VIP"), 0x315C_74B2);
        assert_eq!(pandemic_hash("KnifeThrow"), 0xFB5E_3070);
    }
}
