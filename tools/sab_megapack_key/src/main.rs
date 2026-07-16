//! Proof that a Saboteur (2009) `.megapack` (MP00) index key is reproducible from a
//! reconstructed resource-path string.
//!
//! ## Result (proven against real retail data)
//!
//! A megapack index entry on disk is 20 bytes:
//! `{ u32 path_crc; u32 name_crc; u32 size; u64 offset }`.
//! The engine finds an asset by `bsearch` on `path_crc` (`FUN_00e42740` @0x00e42740).
//!
//!   * `name_crc` (SabTool: `FileEntry.Name`) = `pandemic_hash(resourceName)`
//!   * `path_crc` (SabTool: `FileEntry.Path`, THE bsearch key)
//!                 = `pandemic_hash("global\\" + resourceName + ".dynpack")`   (Global\Dynamic0)
//!                 = `pandemic_hash("global\\" + resourceName + ".palettepack")` (Global\Palettes0)
//!
//! `pandemic_hash` == FNV-1a/32 with case-fold and a fixed finalizer, matching the engine
//! kernel `FUN_00dc1e20` @0x00dc1e20 byte-for-byte:
//!   basis 0x811C9DC5; per byte `h = ((c | 0x20) ^ h) * 0x1000193`;
//!   finalize `(h ^ 0x2A) * 0x1000193`; empty/NULL string -> 0.
//!
//! This file hard-codes several REAL (resourceName, on-disk path_crc, on-disk name_crc) triples
//! taken from `Global\Dynamic0.megapack` and reproduces both u32s purely from the name string.
//! Optionally pass a path to a `.megapack` to re-parse it live and confirm the derived key is a
//! real entry the engine's bsearch would hit.

use std::env;
use std::fs;

const BASIS: u32 = 0x811C9DC5;
const PRIME: u32 = 0x0100_0193;

/// Engine `FUN_00dc1e20` @0x00dc1e20 (Saboteur.exe): FNV-1a/32 + case-fold + finalizer.
fn pandemic_hash(s: &str) -> u32 {
    let b = s.as_bytes();
    if b.is_empty() {
        return 0;
    }
    let mut h = BASIS;
    for &c in b {
        h = ((u32::from(c) | 0x20) ^ h).wrapping_mul(PRIME);
    }
    (h ^ 0x2A).wrapping_mul(PRIME)
}

/// The exact pre-hash string the engine builds for a Global\* dynamic-pack request.
fn dynpack_path(name: &str) -> String {
    format!("global\\{name}.dynpack")
}
#[allow(dead_code)]
fn palettepack_path(name: &str) -> String {
    format!("global\\{name}.palettepack")
}

/// (resourceName, real path_crc, real name_crc) — lifted directly from Global\Dynamic0.megapack.
/// The first two are the two entries whose *mesh* is both `P_Keys_KeyRing_A` yet whose keys
/// differ: proof the key hashes the RESOURCE name, not the mesh name.
const DYN0: &[(&str, u32, u32)] = &[
    ("Act1_IntKey", 0xD3EF_69E0, 0xB333_DA43), // mesh P_Keys_KeyRing_A (entry #0)
    ("AMBCat_CellKey", 0x708B_49A0, 0x5E35_13B5), // mesh P_Keys_KeyRing_A (entry #3)
    ("AI_Alarm", 0x4CE0_D45C, 0xAE54_0515),
    ("AI_Alarm_Tower", 0x9943_3506, 0x2B09_46FB),
    ("AmbientTutorial", 0x8745_0C5A, 0xE17C_DBE5),
    ("AnimatedObject_SingleDoor", 0x7B48_9865, 0x1ECD_CA36),
    ("ArtilleryOrdnance", 0xC2FD_54E6, 0x59A7_0951),
];

fn self_test() {
    // Cross-check the kernel against the known vector.
    assert_eq!(pandemic_hash("ANY"), 0xED05_7225, "pandemic_hash kernel mismatch");
}

fn main() {
    self_test();
    println!("== Saboteur megapack key derivation proof ==");
    println!("kernel: pandemic_hash == FNV-1a/32 (FUN_00dc1e20 @0x00dc1e20)");
    println!("format: path_crc = pandemic_hash(\"global\\\\<name>.dynpack\")");
    println!("        name_crc = pandemic_hash(\"<name>\")\n");

    let mut all_ok = true;
    for (name, real_path, real_name) in DYN0 {
        let p = dynpack_path(name);
        let dp = pandemic_hash(&p);
        let dn = pandemic_hash(name);
        let ok = dp == *real_path && dn == *real_name;
        all_ok &= ok;
        println!(
            "[{}] {:<26} path=0x{:08X} (real 0x{:08X})  name=0x{:08X} (real 0x{:08X})  <= {:?}",
            if ok { "OK" } else { "FAIL" },
            name, dp, real_path, dn, real_name, p
        );
    }
    println!(
        "\n{} of {} hard-coded Dynamic0 entries reproduced from the name string.",
        DYN0.iter()
            .filter(|(n, p, nm)| pandemic_hash(&dynpack_path(n)) == *p && pandemic_hash(n) == *nm)
            .count(),
        DYN0.len()
    );

    // Optional: re-parse a real .megapack and confirm the derived keys are genuine entries.
    if let Some(path) = env::args().nth(1) {
        println!("\n-- live re-parse of {path} --");
        let data = fs::read(&path).expect("read megapack");
        assert_eq!(&data[0..4], b"00PM", "not an MP00 megapack (LE magic 00PM)");
        let count = u32::from_le_bytes(data[4..8].try_into().unwrap()) as usize;
        // entry = {u32 path_crc; u32 name_crc; u32 size; u64 offset} = 20 bytes
        let mut keys: Vec<(u32, u32, u32, u64)> = Vec::with_capacity(count);
        for i in 0..count {
            let o = 8 + i * 20;
            let path_crc = u32::from_le_bytes(data[o..o + 4].try_into().unwrap());
            let name_crc = u32::from_le_bytes(data[o + 4..o + 8].try_into().unwrap());
            let size = u32::from_le_bytes(data[o + 8..o + 12].try_into().unwrap());
            let offset = u64::from_le_bytes(data[o + 12..o + 20].try_into().unwrap());
            keys.push((path_crc, name_crc, size, offset));
        }
        println!("parsed {count} entries.");
        for (name, _, _) in DYN0 {
            let dp = pandemic_hash(&dynpack_path(name));
            let hit = keys.iter().find(|(pc, ..)| *pc == dp);
            match hit {
                Some((pc, nc, sz, off)) => {
                    // confirm the block really starts with ALBS (SBLA)
                    let magic = &data[*off as usize..*off as usize + 4];
                    println!(
                        "  {:<26} -> derived path=0x{:08X} FOUND (name=0x{:08X} size={} off=0x{:X} magic={:?})",
                        name, pc, nc, sz, off, std::str::from_utf8(magic).unwrap_or("?")
                    );
                }
                None => println!("  {name:<26} -> derived path=0x{dp:08X} NOT FOUND"),
            }
        }
    } else {
        println!("\n(tip: pass a .megapack path to live-verify the derived keys exist as real entries)");
    }

    std::process::exit(if all_ok { 0 } else { 1 });
}
