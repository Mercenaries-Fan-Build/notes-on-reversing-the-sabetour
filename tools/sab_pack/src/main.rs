//! sab_pack — WRITE a valid The Saboteur (2009) `.megapack` (magic "00PM").
//!
//! This is the inverse of the `sab_mesh` / `sab_skeleton` readers: it lays out a megapack
//! the engine's mounter (`FUN_00e428c0` @ decomp VA 0x00e428c0) will accept, so we can pack
//! one extracted asset (an SBLA sub-pack) into a single-entry pack, or build a
//! `patchdynamic0.megapack`-style override.
//!
//! ON-DISK FORMAT (all little-endian) — reverse-engineered from FUN_00e428c0 and verified
//! byte-for-byte against `Global/Dynamic0.megapack` (759 entries, PC/GOG build):
//!
//!   +0x00  char   magic[4]   = "00PM"  (0x30 0x30 0x50 0x4D; the u32 the engine tests is
//!                                        0x4D503030 — see decomp VA 0x00e42?? `if (iVar4 == 0x4d503030)`)
//!   +0x04  u32    count                (number of entries)
//!   +0x08  Entry  index[count]         (20 bytes each — see below)
//!   ...    Pair   table2[count]        (8 bytes each — {crc,index}, mirrors index[] in file order)
//!   ...    pad to 2048                 (engine never reads it; real packs fill with 0xCB)
//!   ...    per entry: sub-pack bytes at `offset` (2048-aligned), padded to 2048
//!
//!   Entry (20 bytes, read by the first loop of FUN_00e428c0):
//!     +0x00 u32 crc      // FIELD0 — the engine's bsearch/lookup KEY (FUN_00e42740). A 32-bit
//!                        //          hash of the *resource path* the game requests (external;
//!                        //          NOT a checksum of the data — proven: two entries with
//!                        //          byte-identical data carry different crc/index).
//!     +0x04 u32 index    // FIELD1 — a second 32-bit path/instance hash. Stored, not used as
//!                        //          the primary key. All distinct in Dynamic0.
//!     +0x08 u32 size     // exact byte length of the sub-pack at `offset`
//!     +0x0C u64 offset   // absolute file offset of the sub-pack (2048-aligned in real packs)
//!
//!   The engine reads count Entries (0x18=24 bytes apart *in memory*, 20 on disk: 3xu32 via
//!   FUN_00427cb0 + 1xu64 via FUN_006ca430), qsorts them by FIELD0, then reads a second
//!   `count`-long table of {u32,u32} pairs (8 bytes each) — table2 — in original file order.
//!   It performs NO validation of crc/index against the data, so the writer is free to choose
//!   them (for an override, copy the base asset's crc so the by-hash lookup matches).
//!
//! std-only: the sub-pack bytes (ALBS + MSHA + zlib blobs) are copied VERBATIM from a real
//! pack, so no (de)compression is needed here.

use std::io::{Read, Write};

const MAGIC: &[u8; 4] = b"00PM";
const SECTOR: u64 = 2048; // observed alignment of every data offset in Dynamic0/Palettes0

fn u32le(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn u64le(b: &[u8], o: usize) -> u64 {
    u64::from_le_bytes([b[o], b[o+1], b[o+2], b[o+3], b[o+4], b[o+5], b[o+6], b[o+7]])
}
fn align_up(v: u64, a: u64) -> u64 { (v + a - 1) / a * a }

#[derive(Clone)]
struct Entry { crc: u32, index: u32, size: u32, offset: u64 }

// ---------------------------------------------------------------------------
// READER (inverts the writer; mirrors sab_mesh::read_megapack_index)
// ---------------------------------------------------------------------------
fn read_index(buf: &[u8]) -> Result<Vec<Entry>, String> {
    if buf.len() < 8 || &buf[0..4] != MAGIC {
        return Err(format!("not a megapack (magic {:02X?})", &buf[0..4.min(buf.len())]));
    }
    let count = u32le(buf, 4) as usize;
    let mut v = Vec::with_capacity(count);
    let mut p = 8usize;
    for _ in 0..count {
        if p + 20 > buf.len() { return Err("index truncated".into()); }
        v.push(Entry { crc: u32le(buf, p), index: u32le(buf, p + 4), size: u32le(buf, p + 8), offset: u64le(buf, p + 12) });
        p += 20;
    }
    Ok(v)
}

/// SBLA sub-pack internal name-hash (ALBS+8 = pandemic_hash(assetName)) + first MSHA name,
/// for human-readable selection. Returns (nameHash, Option<name>).
fn sbla_info(slice: &[u8]) -> (Option<u32>, Option<String>) {
    if slice.len() < 12 || &slice[0..4] != b"ALBS" { return (None, None); }
    let name_hash = u32le(slice, 8);
    // locate first MSHA ("AHSM" on disk) and read its 256-byte name field
    let mut name = None;
    if let Some(pos) = slice.windows(4).position(|w| w == b"AHSM") {
        let ns = pos + 20;
        if ns + 0x100 <= slice.len() {
            let nb = &slice[ns..ns + 0x100];
            let end = nb.iter().position(|&b| b == 0).unwrap_or(0);
            if end > 0 && nb[..end].iter().all(|&b| (0x20..0x7f).contains(&b)) {
                name = Some(String::from_utf8_lossy(&nb[..end]).into_owned());
            }
        }
    }
    (Some(name_hash), name)
}

// ---------------------------------------------------------------------------
// WRITER — the core deliverable
// ---------------------------------------------------------------------------
/// Build a megapack from (entry-metadata, sub-pack-bytes) pairs. Recomputes offsets/sizes so
/// the layout is internally consistent; preserves each entry's crc/index verbatim.
/// `subpacks[i]` are the exact bytes to place at entry i (an ALBS sub-pack slice).
fn build_megapack(items: &[(u32 /*crc*/, u32 /*index*/, Vec<u8> /*subpack*/)]) -> Vec<u8> {
    let count = items.len() as u64;
    let index_bytes = count * 20;
    let table2_bytes = count * 8;
    let header_end = 8 + index_bytes + table2_bytes;
    let mut data_cursor = align_up(header_end, SECTOR);

    // First pass: assign offsets.
    let mut entries: Vec<Entry> = Vec::with_capacity(items.len());
    for (crc, index, sub) in items {
        entries.push(Entry { crc: *crc, index: *index, size: sub.len() as u32, offset: data_cursor });
        data_cursor = align_up(data_cursor + sub.len() as u64, SECTOR);
    }
    let total = data_cursor as usize;

    let mut out = vec![0u8; total];
    out[0..4].copy_from_slice(MAGIC);
    out[4..8].copy_from_slice(&(count as u32).to_le_bytes());
    // index[]
    let mut p = 8usize;
    for e in &entries {
        out[p..p + 4].copy_from_slice(&e.crc.to_le_bytes());
        out[p + 4..p + 8].copy_from_slice(&e.index.to_le_bytes());
        out[p + 8..p + 12].copy_from_slice(&e.size.to_le_bytes());
        out[p + 12..p + 20].copy_from_slice(&e.offset.to_le_bytes());
        p += 20;
    }
    // table2[] — {crc,index} in the same (file) order as index[]
    for e in &entries {
        out[p..p + 4].copy_from_slice(&e.crc.to_le_bytes());
        out[p + 4..p + 8].copy_from_slice(&e.index.to_le_bytes());
        p += 8;
    }
    // data blocks
    for (e, (_, _, sub)) in entries.iter().zip(items.iter()) {
        let o = e.offset as usize;
        out[o..o + sub.len()].copy_from_slice(sub);
    }
    out
}

// ---------------------------------------------------------------------------
// Entry selection
// ---------------------------------------------------------------------------
fn select<'a>(entries: &'a [Entry], sel: &str) -> Result<usize, String> {
    if let Some(rest) = sel.strip_prefix('#') {
        let n: usize = rest.parse().map_err(|_| "bad #N".to_string())?;
        if n >= entries.len() { return Err("index out of range".into()); }
        return Ok(n);
    }
    if let Some(rest) = sel.strip_prefix("crc:") {
        let want = u32::from_str_radix(rest.trim_start_matches("0x"), 16).map_err(|_| "bad crc hex".to_string())?;
        return entries.iter().position(|e| e.crc == want).ok_or_else(|| format!("no entry with crc 0x{:08X}", want));
    }
    Err("selector must be #N or crc:0xHEX (use `list` to browse names)".into())
}

fn read_file(p: &str) -> Vec<u8> {
    let mut f = std::fs::File::open(p).unwrap_or_else(|e| { eprintln!("open {p}: {e}"); std::process::exit(1); });
    let mut v = Vec::new(); f.read_to_end(&mut v).unwrap(); v
}
fn write_file(p: &str, b: &[u8]) {
    std::fs::File::create(p).and_then(|mut f| f.write_all(b)).unwrap_or_else(|e| { eprintln!("write {p}: {e}"); std::process::exit(1); });
}

fn slice_of<'a>(buf: &'a [u8], e: &Entry) -> &'a [u8] {
    let s = e.offset as usize; let end = s + e.size as usize;
    &buf[s..end]
}

fn usage() -> ! {
    eprintln!("sab_pack — write/validate Saboteur .megapack containers (std-only)\n");
    eprintln!("  list      <megapack> [name_substr]");
    eprintln!("               list entries: #N crc index size name");
    eprintln!("  extract   <megapack> <sel> <out.sub>");
    eprintln!("               dump one entry's SBLA sub-pack bytes; prints crc/index/size");
    eprintln!("  pack      <in.sub> <crc_hex> <index_hex> <out.megapack>");
    eprintln!("               write a single-entry megapack from a sub-pack + chosen keys");
    eprintln!("  roundtrip <megapack> <sel>");
    eprintln!("               extract -> pack -> re-read; assert byte-identical slice");
    eprintln!("  patch     <base.megapack> <sel> <out_patch.megapack> [replacement.sub]");
    eprintln!("               single-entry override pack keyed by the base asset's crc/index");
    eprintln!("               (replacement.sub defaults to the base asset — a no-op override)");
    eprintln!("\n  <sel> = #N (file order) | crc:0xHEX");
    std::process::exit(2);
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 { usage(); }
    match args[1].as_str() {
        "list" => {
            let buf = read_file(&args[2]);
            let entries = read_index(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let filter = args.get(3).map(|s| s.as_str()).unwrap_or("");
            println!("{} entries", entries.len());
            for (i, e) in entries.iter().enumerate() {
                let (_h, name) = sbla_info(slice_of(&buf, e));
                let nm = name.unwrap_or_default();
                if filter.is_empty() || nm.contains(filter) {
                    println!("#{:<4} crc=0x{:08X} index=0x{:08X} size={:<8} {}", i, e.crc, e.index, e.size, nm);
                }
            }
        }
        "extract" => {
            if args.len() < 5 { usage(); }
            let buf = read_file(&args[2]);
            let entries = read_index(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let i = select(&entries, &args[3]).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let e = &entries[i];
            let sub = slice_of(&buf, e);
            let (h, name) = sbla_info(sub);
            write_file(&args[4], sub);
            eprintln!("[extract] #{i} crc=0x{:08X} index=0x{:08X} size={} nameHash={} name={:?}",
                e.crc, e.index, e.size, h.map(|x| format!("0x{:08X}", x)).unwrap_or_default(), name);
            eprintln!("[extract] wrote {} ({} bytes)", args[4], sub.len());
        }
        "pack" => {
            if args.len() < 6 { usage(); }
            let sub = read_file(&args[2]);
            let crc = u32::from_str_radix(args[3].trim_start_matches("0x"), 16).unwrap_or_else(|_| { eprintln!("bad crc hex"); std::process::exit(1); });
            let index = u32::from_str_radix(args[4].trim_start_matches("0x"), 16).unwrap_or_else(|_| { eprintln!("bad index hex"); std::process::exit(1); });
            let pack = build_megapack(&[(crc, index, sub.clone())]);
            write_file(&args[5], &pack);
            eprintln!("[pack] single-entry megapack crc=0x{:08X} index=0x{:08X} sub={}B -> {} ({}B)",
                crc, index, sub.len(), args[5], pack.len());
            // self-verify
            let re = read_index(&pack).unwrap();
            assert_eq!(re.len(), 1);
            assert_eq!(slice_of(&pack, &re[0]), &sub[..]);
            eprintln!("[pack] self-check OK (re-read entry data == input sub-pack)");
        }
        "roundtrip" => {
            if args.len() < 4 { usage(); }
            let buf = read_file(&args[2]);
            let entries = read_index(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let i = select(&entries, &args[3]).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let e = &entries[i];
            let orig = slice_of(&buf, e).to_vec();
            let (h, name) = sbla_info(&orig);
            eprintln!("[rt] source #{i} crc=0x{:08X} index=0x{:08X} size={} name={:?} (nameHash={})",
                e.crc, e.index, e.size, name, h.map(|x| format!("0x{:08X}", x)).unwrap_or_default());
            let pack = build_megapack(&[(e.crc, e.index, orig.clone())]);
            let re = read_index(&pack).unwrap();
            let got = slice_of(&pack, &re[0]).to_vec();
            let key_ok = re[0].crc == e.crc && re[0].index == e.index && re[0].size == e.size;
            let data_ok = got == orig;
            eprintln!("[rt] re-read: crc=0x{:08X} index=0x{:08X} size={} offset={}", re[0].crc, re[0].index, re[0].size, re[0].offset);
            eprintln!("[rt] key fields identical:  {}", if key_ok {"YES"} else {"NO"});
            eprintln!("[rt] sub-pack BYTE-IDENTICAL: {}  ({} bytes)", if data_ok {"YES"} else {"NO"}, got.len());
            if key_ok && data_ok { eprintln!("[rt] ROUND-TRIP PASS"); }
            else { eprintln!("[rt] ROUND-TRIP FAIL"); std::process::exit(1); }
        }
        "patch" => {
            if args.len() < 5 { usage(); }
            let buf = read_file(&args[2]);
            let entries = read_index(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let i = select(&entries, &args[3]).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let e = &entries[i];
            let sub = if let Some(rp) = args.get(4).filter(|_| args.len() >= 6).map(|_| &args[5]) {
                read_file(rp)
            } else { slice_of(&buf, e).to_vec() };
            let pack = build_megapack(&[(e.crc, e.index, sub.clone())]);
            write_file(&args[4], &pack);
            eprintln!("[patch] override entry #{i} (base crc=0x{:08X} index=0x{:08X}) with {}B sub-pack",
                e.crc, e.index, sub.len());
            eprintln!("[patch] wrote {} ({}B). Deploy as Global/patchdynamic0.megapack (mount priority 0x18704 > base 100)", args[4], pack.len());
            eprintln!("[patch] engine lookup keys on crc (FIELD0); this pack's crc matches the base asset, so the by-hash lookup resolves here first.");
        }
        _ => usage(),
    }
}
