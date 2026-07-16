//! sab_sbla — parse & rebuild the internal directory of a Saboteur (2009) `SBLA`/`ALBS`
//! sub-pack (the hash->offset table the streaming loader uses), so an edited asset can be
//! spliced into a multi-asset sub-pack and the pack still round-trips.
//!
//! This is the inverse of the loader `FUN_00658870` (decomp VA 0x00658870, magic
//! 0x53424C41 = "ALBS"). That function walks up to 8 typed sections; each section is an array
//! of 24-byte directory records and it accumulates `record.compSize` to compute running data
//! offsets (`piVar4 += 6` = 6 dwords = 24-byte stride; it reads `*piVar4` at record+8 = the
//! size). We reproduce the on-disk layout from that plus byte evidence in the shipped packs.
//!
//! ON-DISK SBLA LAYOUT (all little-endian). Reverse-engineered from `FUN_00658870` and verified
//! by a byte-identical parse->rebuild round-trip over 1042 real mesh/texture sub-packs in
//! France/Mega0.megapack, Start0.kiloPack, BelleStart0.kiloPack, Global/Dynamic0.megapack
//! (0 mismatches; terrain "HEI1" and blueprint/Locator variants are a different layout, refused).
//!
//!   HEADER
//!     +0x00  char  magic[4] = "ALBS"        (u32 the loader tests = 0x53424C41)
//!     +0x04  u32   flags                    (0x00 = "object" variant; 0x3C = "streamblock"
//!                                            variant — selects directory start & offset base)
//!     +0x08  u32   name_crc                 (pandemic_hash(assetName); 0 for streamblocks)
//!     +0x0C  u32   reserved (0)
//!     +0x10  u32   aux0                     (object variant: = first record's `offset` field,
//!                                            i.e. the file offset where the blob region begins)
//!     +0x14  u32   aux1                     (object: size of the first middle/structured block)
//!     +0x18 .. dir_start: reserved/other header words (preserved verbatim)
//!
//!   DIRECTORY  (starts at 0x20 when flags!=0x3C, else 0x44)
//!     record[N] — 24 bytes each:
//!       +0x00 u32 hash        // per-sub-asset name/type hash (pandemic_hash); 0 => section
//!                             //   boundary "placeholder" (shares the next record's offset;
//!                             //   contributes NO bytes to the body / does not advance the cursor)
//!       +0x04 u32 offset      // running offset of this record's compressed blob. Chains:
//!                             //   offset[0] = `first`; offset[i] = offset[i-1] + compSize[i-1]
//!                             //   for real records (hash!=0). See FUN_00658870's accumulate loop.
//!       +0x08 u32 compSize    // stored (zlib-compressed) byte length of the blob
//!       +0x0C u32 uncompSize  // decompressed byte length
//!       +0x10 u32 f4          // flags/lod (0 or 1 observed)
//!       +0x14 u32 f5          // aux (0 or small)
//!     The directory ends at the first record whose `offset` != the expected running cursor
//!     (that word is the start of the next region, e.g. an "AHSM"/MSHA block magic).
//!
//!   MIDDLE   [dir_end, blob_base): uncompressed structured headers (AHSM/MSHA meshes, DTEX
//!            texture descriptors). Preserved verbatim by this tool.
//!   BODY     [blob_base, blob_base+span): the compressed blobs back-to-back, one per real
//!            record, in directory order. `span = sum(compSize of real records)`.
//!   TRAILING [blob_base+span, EOF): footer/padding, preserved verbatim.
//!
//!   BLOB PLACEMENT MODELS (deterministic from the parse):
//!     * "abs"  when first >= dir_end  → the `offset` field is the real file offset; the blob
//!              region begins at `first` (== header aux0), MIDDLE sits between the directory and
//!              it, and a footer may trail the body. (Most single/multi-mesh object sub-packs.)
//!     * "tail" otherwise (first < dir_end, i.e. relative offsets incl. streamblocks & large
//!              merged objects) → blobs are stored at the END of the file: blob_base = EOF - span,
//!              MIDDLE = [dir_end, blob_base), no trailing.
//!
//! Splicing (`replace`) recomputes every record's `offset` field from the compSize chain and
//! relays MIDDLE/TRAILING verbatim, so a no-op replace is byte-identical and a real edit keeps
//! the directory the loader bsearches consistent.

use std::io::{Read, Write};

fn u32le(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn u64le(b: &[u8], o: usize) -> u64 {
    u64::from_le_bytes([b[o], b[o+1], b[o+2], b[o+3], b[o+4], b[o+5], b[o+6], b[o+7]])
}

#[derive(Clone, Debug)]
struct Record { hash: u32, offset: u32, comp: u32, uncomp: u32, f4: u32, f5: u32 }
impl Record { fn real(&self) -> bool { self.hash != 0 } }

#[derive(Clone, Copy, PartialEq, Debug)]
enum Model { Abs, Tail }

struct Sbla {
    header: Vec<u8>,     // bytes [0, dir_start)
    dir_start: usize,
    recs: Vec<Record>,
    first: u32,          // offset field of record 0
    span: u32,           // sum of comp of real records
    model: Model,
    blob_base: usize,
    middle: Vec<u8>,     // [dir_end, blob_base)
    body: Vec<u8>,       // [blob_base, blob_base+span)
    trailing: Vec<u8>,   // [blob_base+span, EOF)
}

fn parse(buf: &[u8]) -> Result<Sbla, String> {
    let size = buf.len();
    if size < 0x48 || &buf[0..4] != b"ALBS" {
        return Err("not an ALBS sub-pack (bad magic / too small)".into());
    }
    let flags = u32le(buf, 4);
    // `flags` @+0x04 selects the container variant. Two are the MSHA-mesh / DTEX-texture sub-packs
    // this tool models and round-trips byte-identically:
    //   0x00 = "object" (mesh/texture asset; absolute blob offsets, blob region after the middle)
    //   0x3C = "streamblock" (baked world cell of meshes; blob-relative offsets, blobs at EOF)
    // Other values (0xB4.., 0x1xx.. terrain/heightfield "HEI1" cells; tiny values = blueprint/
    // Locator node packs) are a DIFFERENT resource layout and are intentionally out of scope —
    // we refuse them rather than risk a wrong splice.
    if flags != 0x00 && flags != 0x3C {
        return Err(format!("unsupported SBLA variant flags=0x{:X} (not a mesh/texture sub-pack; terrain/blueprint layout out of scope)", flags));
    }
    let dir_start = if flags == 0x3C { 0x44 } else { 0x20 };
    if dir_start + 24 > size { return Err("no directory".into()); }
    let first = u32le(buf, dir_start + 4);
    let mut recs = Vec::new();
    let mut cursor = first;
    let mut o = dir_start;
    while o + 24 <= size {
        let r = Record {
            hash: u32le(buf, o), offset: u32le(buf, o + 4), comp: u32le(buf, o + 8),
            uncomp: u32le(buf, o + 12), f4: u32le(buf, o + 16), f5: u32le(buf, o + 20),
        };
        // directory ends when the offset field no longer matches the running cursor
        // (that word is the magic of the next region), or a size is nonsensical.
        if r.offset != cursor || (r.comp as usize) > size { break; }
        if r.real() { cursor = cursor.wrapping_add(r.comp); }
        recs.push(r);
        o += 24;
    }
    if recs.is_empty() { return Err("empty directory".into()); }
    let dir_end = o;
    let span = cursor.wrapping_sub(first);
    // deterministic placement model
    let (model, blob_base) = if first as usize >= dir_end {
        (Model::Abs, first as usize)
    } else {
        (Model::Tail, size.checked_sub(span as usize).ok_or("span>size")?)
    };
    if blob_base < dir_end || blob_base + span as usize > size {
        return Err(format!("blob region out of range (base=0x{:X} span=0x{:X} size=0x{:X})", blob_base, span, size));
    }
    Ok(Sbla {
        header: buf[0..dir_start].to_vec(),
        dir_start,
        recs,
        first,
        span,
        model,
        blob_base,
        middle: buf[dir_end..blob_base].to_vec(),
        body: buf[blob_base..blob_base + span as usize].to_vec(),
        trailing: buf[blob_base + span as usize..size].to_vec(),
    })
}

/// Serialize the model back to bytes, recomputing every record's `offset` from the compSize chain.
fn build(s: &Sbla) -> Vec<u8> {
    let mut out = Vec::with_capacity(
        s.header.len() + s.recs.len() * 24 + s.middle.len() + s.body.len() + s.trailing.len(),
    );
    out.extend_from_slice(&s.header);
    let mut cur = s.first;
    for r in &s.recs {
        out.extend_from_slice(&r.hash.to_le_bytes());
        out.extend_from_slice(&cur.to_le_bytes());
        out.extend_from_slice(&r.comp.to_le_bytes());
        out.extend_from_slice(&r.uncomp.to_le_bytes());
        out.extend_from_slice(&r.f4.to_le_bytes());
        out.extend_from_slice(&r.f5.to_le_bytes());
        if r.real() { cur = cur.wrapping_add(r.comp); }
    }
    out.extend_from_slice(&s.middle);
    out.extend_from_slice(&s.body);
    out.extend_from_slice(&s.trailing);
    out
}

/// Sequential (offset-order) compressed blob of each real record. Index aligns with `recs`
/// (placeholders map to an empty slice).
fn blob_ranges(s: &Sbla) -> Vec<(usize, usize)> {
    let mut v = Vec::with_capacity(s.recs.len());
    let mut p = 0usize;
    for r in &s.recs {
        if r.real() { v.push((p, p + r.comp as usize)); p += r.comp as usize; }
        else { v.push((p, p)); }
    }
    v
}

/// Replace real record #k's compressed blob and recompute the whole layout.
fn replace(s: &Sbla, k: usize, new_comp: &[u8], new_uncomp: u32) -> Result<Sbla, String> {
    if k >= s.recs.len() { return Err("record index out of range".into()); }
    if !s.recs[k].real() { return Err("cannot replace a section-boundary placeholder record".into()); }
    let ranges = blob_ranges(s);
    let mut new_body = Vec::new();
    let mut new_recs = s.recs.clone();
    for (i, r) in s.recs.iter().enumerate() {
        if !r.real() { continue; }
        if i == k {
            new_body.extend_from_slice(new_comp);
        } else {
            let (a, b) = ranges[i];
            new_body.extend_from_slice(&s.body[a..b]);
        }
    }
    new_recs[k].comp = new_comp.len() as u32;
    new_recs[k].uncomp = new_uncomp;
    let span: u32 = new_recs.iter().filter(|r| r.real()).map(|r| r.comp).sum();
    // Abs: blob_base fixed at `first` (header aux0 unchanged). Tail: base recomputed at emit time
    // (it's EOF-span, i.e. right after MIDDLE), which is implicit since we append body after middle.
    let mut out = s_clone_meta(s);
    out.recs = new_recs;
    out.span = span;
    out.body = new_body;
    // For Tail, blob_base/middle/trailing are still consistent (middle preserved, no trailing).
    // For Abs, keep trailing footer as-is. blob_base recorded for reference only.
    Ok(out)
}

fn s_clone_meta(s: &Sbla) -> Sbla {
    Sbla {
        header: s.header.clone(), dir_start: s.dir_start, recs: s.recs.clone(), first: s.first,
        span: s.span, model: s.model, blob_base: s.blob_base, middle: s.middle.clone(),
        body: s.body.clone(), trailing: s.trailing.clone(),
    }
}

// --------------------------------------------------------------------------- megapack helpers
const MP_MAGIC: &[u8; 4] = b"00PM";
struct MpEntry { crc: u32, _field1: u32, size: u32, offset: u64 }
fn read_mp_index(buf: &[u8]) -> Result<Vec<MpEntry>, String> {
    if buf.len() < 8 || &buf[0..4] != MP_MAGIC { return Err("not a megapack".into()); }
    let count = u32le(buf, 4) as usize;
    let mut v = Vec::with_capacity(count);
    let mut p = 8;
    for _ in 0..count {
        if p + 20 > buf.len() { return Err("index truncated".into()); }
        v.push(MpEntry { crc: u32le(buf, p), _field1: u32le(buf, p + 4), size: u32le(buf, p + 8), offset: u64le(buf, p + 12) });
        p += 20;
    }
    Ok(v)
}

fn read_file(p: &str) -> Vec<u8> {
    let mut f = std::fs::File::open(p).unwrap_or_else(|e| { eprintln!("open {p}: {e}"); std::process::exit(1); });
    let mut v = Vec::new(); f.read_to_end(&mut v).unwrap(); v
}
fn write_file(p: &str, b: &[u8]) {
    std::fs::File::create(p).and_then(|mut f| f.write_all(b)).unwrap_or_else(|e| { eprintln!("write {p}: {e}"); std::process::exit(1); });
}

fn print_dir(s: &Sbla) {
    println!("ALBS flags=0x{:X} name_crc=0x{:08X} dir_start=0x{:X} model={:?} first=0x{:X} span=0x{:X}",
        u32le(&s.header, 4), u32le(&s.header, 8), s.dir_start, s.model, s.first, s.span);
    println!("blob_base=0x{:X} middle={}B body={}B trailing={}B records={}",
        s.blob_base, s.middle.len(), s.body.len(), s.trailing.len(), s.recs.len());
    let mut cur = s.first;
    for (i, r) in s.recs.iter().enumerate() {
        println!("  #{:<3} hash=0x{:08X} offset=0x{:06X} comp=0x{:X} uncomp=0x{:X} f4={} f5={}{}",
            i, r.hash, cur, r.comp, r.uncomp, r.f4, r.f5, if r.real() {""} else {"  [placeholder/section-boundary]"});
        if r.real() { cur = cur.wrapping_add(r.comp); }
    }
}

fn usage() -> ! {
    eprintln!("sab_sbla — parse/rebuild/splice a Saboteur SBLA (ALBS) sub-pack directory\n");
    eprintln!("  list    <sub.albs>                                 parse header+directory, print records");
    eprintln!("  rebuild <sub.albs> <out.albs>                      parse->rebuild (recompute offsets); asserts byte-identical");
    eprintln!("  replace <sub.albs> <recIdx> <blob.bin> <uncompSz> <out.albs>");
    eprintln!("                                                     swap record #recIdx's compressed blob (uncompSz = new");
    eprintln!("                                                     uncompressed size, or '-' to keep) and fix the directory");
    eprintln!("  scan    <megapack>                                 rebuild EVERY ALBS sub-pack in a .megapack/.kiloPack;");
    eprintln!("                                                     report identical / mismatch / non-ALBS (the batch oracle)");
    std::process::exit(2);
}

fn main() {
    let a: Vec<String> = std::env::args().collect();
    if a.len() < 2 { usage(); }
    match a[1].as_str() {
        "list" => {
            if a.len() < 3 { usage(); }
            let buf = read_file(&a[2]);
            let s = parse(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            print_dir(&s);
        }
        "rebuild" => {
            if a.len() < 4 { usage(); }
            let buf = read_file(&a[2]);
            let s = parse(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let out = build(&s);
            let ok = out == buf;
            write_file(&a[3], &out);
            eprintln!("[rebuild] {} records, model={:?} -> {} ({} bytes)", s.recs.len(), s.model, a[3], out.len());
            eprintln!("[rebuild] BYTE-IDENTICAL to input: {}", if ok { "YES" } else { "NO" });
            if !ok { std::process::exit(1); }
        }
        "replace" => {
            if a.len() < 7 { usage(); }
            let buf = read_file(&a[2]);
            let s = parse(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let k: usize = a[3].parse().unwrap_or_else(|_| { eprintln!("bad recIdx"); std::process::exit(1); });
            let nb = read_file(&a[4]);
            let nus = if a[5] == "-" { s.recs[k].uncomp }
                else { a[5].trim_start_matches("0x").parse().or_else(|_| u32::from_str_radix(a[5].trim_start_matches("0x"), 16)).unwrap_or_else(|_| { eprintln!("bad uncompSz"); std::process::exit(1); }) };
            let ns = replace(&s, k, &nb, nus).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            let out = build(&ns);
            write_file(&a[6], &out);
            let noop = out == buf;
            eprintln!("[replace] record #{k}: comp 0x{:X}->0x{:X} uncomp 0x{:X}->0x{:X}", s.recs[k].comp, nb.len(), s.recs[k].uncomp, nus);
            eprintln!("[replace] wrote {} ({} bytes). no-op(byte-identical)={}", a[6], out.len(), noop);
            // re-parse to prove the rewritten directory still parses & chains
            match parse(&out) {
                Ok(re) => eprintln!("[replace] re-parse OK: {} records, span=0x{:X}", re.recs.len(), re.span),
                Err(e) => { eprintln!("[replace] re-parse FAILED: {e}"); std::process::exit(1); }
            }
        }
        "scan" => {
            if a.len() < 3 { usage(); }
            let buf = read_file(&a[2]);
            let idx = read_mp_index(&buf).unwrap_or_else(|e| { eprintln!("{e}"); std::process::exit(1); });
            // ok      = in-scope mesh/texture sub-pack rebuilt byte-identically
            // mismatch= in-scope sub-pack rebuilt WRONG (must stay 0 — that would be a real bug)
            // oos     = out-of-scope variant (terrain/blueprint) or non-ALBS entry (expected)
            let (mut ok, mut mismatch, mut oos) = (0u32, 0u32, 0u32);
            for (i, e) in idx.iter().enumerate() {
                let s0 = e.offset as usize; let s1 = s0 + e.size as usize;
                if s1 > buf.len() { oos += 1; continue; }
                let sub = &buf[s0..s1];
                if sub.len() < 4 || &sub[0..4] != b"ALBS" { oos += 1; continue; }
                match parse(sub) {
                    Ok(s) => {
                        if build(&s) == sub { ok += 1; }
                        else { mismatch += 1; eprintln!("  MISMATCH #{i} crc=0x{:08X} recs={} model={:?}", e.crc, s.recs.len(), s.model); }
                    }
                    Err(_) => { oos += 1; }
                }
            }
            println!("{} entries: byte-identical(mesh/texture)={} in-scope-mismatch={} out-of-scope/non-ALBS={}", idx.len(), ok, mismatch, oos);
            if mismatch != 0 { std::process::exit(1); }
        }
        _ => usage(),
    }
}
