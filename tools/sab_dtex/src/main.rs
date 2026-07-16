//! sab_dtex — read/write The Saboteur (2009) DTEX textures.
//!
//! A "DTEX" is the texture resource stored inside an SBLA ("ALBS") sub-pack. It has NO 4CC
//! magic of its own; it is a length-prefixed record. This tool operates on a standalone
//! *DTEX record* (the exact bytes of one texture, `nameLen .. end of last zlib stream`),
//! which you can `carve` out of a sub-pack dumped by `sab_pack extract`.
//!
//! ON-DISK DTEX RECORD (all little-endian) — reverse-engineered from real bytes in
//! `Global/Palettes0.megapack` / `Dynamic0.megapack` and corroborated by the clean decomp
//! (format-code map FUN_009bb910 @0x009bb910; DXT-format test FUN_00dee1c0 @0x00dee1c0;
//! ALBS dispatch @0x00e34f70-region, magic 0x53424c41):
//!
//!   +0x00  u32   nameLen
//!   +0x04  char  name[nameLen]              // e.g. "Barge_Wall01_NM"  (NOT hashed here)
//!   +N     u32   format                     // D3DFMT int OR ascii 4CC:
//!                                            //   0x31545844 "DXT1", 0x33545844 "DXT3",
//!                                            //   0x35545844 "DXT5", 0x15 A8R8G8B8,
//!                                            //   0x1c A8, 0x32 L8  (see FUN_009bb910)
//!   +N+4   u32   flags                      // usage bitfield (0x6 base; |1 normal-map;
//!                                            //   |8 spec; |0x10 DXT5/alpha; |0x40,0x80 seen)
//!   +N+8   u16   width
//!   +N+0xA u16   height
//!   +N+0xC u16   mipCount
//!   +N+0xE u32   uncompressedSize           // == sum over streams of decompressed length
//!   +N+0x12 u32  numStreams
//!   +N+0x16 [ u32 compressedSize; u8 zlib[compressedSize] ] * numStreams
//!
//! The concatenation of every decompressed stream is the MIP PAYLOAD: for each mip, in order
//! largest->smallest, a 24-byte descriptor followed by that mip's pixel bytes:
//!
//!   MipDesc (24 bytes): u32 mipIndex; u32 width; u32 height; u32 pad0(=0); u32 one(=1);
//!                       u32 mipDataSize
//!
//! so  uncompressedSize == sum_mips( 24 + mipDataSize ).  Streams split the payload at
//! 0x180000 (1572864) uncompressed-byte boundaries (each chunk zlib-compressed independently).
//!
//! Round-trip note: the 2009 build's zlib deflate output is not reproducible by modern zlib
//! (adler32 matches, deflate body differs). `pack --preserve` reuses the template's exact
//! stream bytes for a BYTE-IDENTICAL container; plain `pack` recompresses (valid + engine-
//! loadable, but the deflate bytes differ).

use std::io::{Read, Write};
use flate2::read::ZlibDecoder;
use flate2::write::ZlibEncoder;
use flate2::Compression;

const DXT1: u32 = 0x3154_5844;
const DXT3: u32 = 0x3354_5844;
const DXT5: u32 = 0x3554_5844;
const CHUNK: usize = 0x180000; // 1572864 — engine's per-stream uncompressed split
const MIPDESC: usize = 24;

fn u16(b: &[u8], o: usize) -> u16 { u16::from_le_bytes([b[o], b[o + 1]]) }
fn u32(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }

// ---- format helpers -------------------------------------------------------
/// bytes-per-pixel for uncompressed formats; None if block-compressed.
fn uncompressed_bpp(fmt: u32) -> Option<usize> {
    match fmt {
        0x15 | 0x14 | 0x3f => Some(4), // A8R8G8B8 / X8R8G8B8 / Q8W8V8U8
        0x16 | 0x28 => Some(2),        // R5G6B5 / V8U8
        0x1c | 0x32 => Some(1),        // A8 / L8
        _ => None,
    }
}
/// bytes occupied by one mip level at (w,h) for the given format.
fn mip_bytes(fmt: u32, w: usize, h: usize) -> usize {
    match fmt {
        DXT1 => ((w + 3) / 4).max(1) * ((h + 3) / 4).max(1) * 8,
        DXT3 | DXT5 => ((w + 3) / 4).max(1) * ((h + 3) / 4).max(1) * 16,
        _ => w * h * uncompressed_bpp(fmt).unwrap_or_else(|| die(&format!("unknown format 0x{fmt:08X}"))),
    }
}
fn fmt_name(fmt: u32) -> String {
    match fmt {
        DXT1 => "DXT1".into(), DXT3 => "DXT3".into(), DXT5 => "DXT5".into(),
        0x15 => "A8R8G8B8".into(), 0x14 => "X8R8G8B8".into(), 0x1c => "A8".into(),
        0x32 => "L8".into(), 0x16 => "R5G6B5".into(), 0x28 => "V8U8".into(),
        _ => format!("0x{fmt:08X}"),
    }
}

// ---- parsed DTEX ----------------------------------------------------------
struct Dtex {
    name: String,
    format: u32,
    flags: u32,
    width: u16,
    height: u16,
    mips: u16,
    unc: u32,
    streams: Vec<Vec<u8>>, // raw compressed bytes, exactly as on disk
    total_len: usize,      // record byte length (nameLen field .. end of last stream)
}

fn parse(buf: &[u8]) -> Dtex {
    let name_len = u32(buf, 0) as usize;
    if name_len == 0 || name_len > 256 || 4 + name_len + 26 > buf.len() {
        die("not a DTEX record (bad name length)");
    }
    let name = String::from_utf8_lossy(&buf[4..4 + name_len]).into_owned();
    let f = 4 + name_len; // format field
    let format = u32(buf, f);
    let flags = u32(buf, f + 4);
    let width = u16(buf, f + 8);
    let height = u16(buf, f + 10);
    let mips = u16(buf, f + 12);
    let unc = u32(buf, f + 14);
    let ns = u32(buf, f + 18) as usize;
    let mut o = f + 22;
    let mut streams = Vec::with_capacity(ns);
    for _ in 0..ns {
        let cs = u32(buf, o) as usize;
        o += 4;
        if o + cs > buf.len() { die("stream overruns buffer"); }
        streams.push(buf[o..o + cs].to_vec());
        o += cs;
    }
    Dtex { name, format, flags, width, height, mips, unc, streams, total_len: o }
}

/// decompress + concatenate every stream into the full mip payload.
fn payload(d: &Dtex) -> Vec<u8> {
    let mut out = Vec::with_capacity(d.unc as usize);
    for s in &d.streams {
        let mut z = ZlibDecoder::new(&s[..]);
        let mut buf = Vec::new();
        z.read_to_end(&mut buf).unwrap_or_else(|e| die(&format!("zlib inflate: {e}")));
        out.extend_from_slice(&buf);
    }
    if out.len() != d.unc as usize {
        eprintln!("[warn] payload {} != uncompressedSize {}", out.len(), d.unc);
    }
    out
}

/// walk the mip descriptors, returning (mipIndex,w,h,dataSize,dataSlice) per mip.
fn mips_of<'a>(d: &Dtex, pl: &'a [u8]) -> Vec<(u32, u32, u32, &'a [u8])> {
    let mut v = Vec::new();
    let mut o = 0usize;
    for _ in 0..d.mips {
        if o + MIPDESC > pl.len() { break; }
        let w = u32(pl, o + 4);
        let h = u32(pl, o + 8);
        let sz = u32(pl, o + 20) as usize;
        o += MIPDESC;
        if o + sz > pl.len() { die("mip data overruns payload"); }
        v.push((u32(pl, o - MIPDESC), w, h, &pl[o..o + sz]));
        o += sz;
    }
    v
}

// ---- DDS ------------------------------------------------------------------
fn write_dds(d: &Dtex, mips: &[(u32, u32, u32, &[u8])], path: &str) {
    let mut h = vec![0u8; 128];
    h[0..4].copy_from_slice(b"DDS ");
    put32(&mut h, 4, 124); // dwSize
    let mut flags = 0x1007u32; // CAPS|HEIGHT|WIDTH|PIXELFORMAT
    if d.mips > 1 { flags |= 0x2_0000; } // MIPMAPCOUNT
    let compressed = uncompressed_bpp(d.format).is_none();
    flags |= if compressed { 0x8_0000 } else { 0x8 }; // LINEARSIZE | PITCH
    put32(&mut h, 8, flags);
    put32(&mut h, 12, d.height as u32);
    put32(&mut h, 16, d.width as u32);
    let top = mip_bytes(d.format, d.width as usize, d.height as usize) as u32;
    put32(&mut h, 20, if compressed { top } else { d.width as u32 * uncompressed_bpp(d.format).unwrap() as u32 });
    put32(&mut h, 28, d.mips as u32); // dwMipMapCount
    // DDS_PIXELFORMAT at +76
    put32(&mut h, 76, 32); // dwSize
    match d.format {
        DXT1 | DXT3 | DXT5 => {
            put32(&mut h, 80, 0x4); // DDPF_FOURCC
            h[84..88].copy_from_slice(&d.format.to_le_bytes()); // ascii 4CC == format
        }
        0x15 | 0x14 => {
            put32(&mut h, 80, if d.format == 0x15 { 0x41 } else { 0x40 }); // RGB|(ALPHA)
            put32(&mut h, 88, 32); // bit count
            put32(&mut h, 92, 0x00ff_0000); // R
            put32(&mut h, 96, 0x0000_ff00); // G
            put32(&mut h, 100, 0x0000_00ff); // B
            put32(&mut h, 104, if d.format == 0x15 { 0xff00_0000 } else { 0 }); // A
        }
        0x1c => { put32(&mut h, 80, 0x2); put32(&mut h, 88, 8); put32(&mut h, 104, 0xff); } // ALPHA A8
        0x32 => { put32(&mut h, 80, 0x2_0000); put32(&mut h, 88, 8); put32(&mut h, 92, 0xff); } // LUMINANCE L8
        _ => die(&format!("no DDS pixelformat mapping for 0x{:08X}", d.format)),
    }
    let mut caps = 0x1000u32; // TEXTURE
    if d.mips > 1 { caps |= 0x40_0008; } // COMPLEX|MIPMAP
    put32(&mut h, 108, caps);
    let mut out = h;
    for (_, _, _, data) in mips { out.extend_from_slice(data); }
    write_file(path, &out);
    eprintln!("[extract] {} {} {}x{} {} mips -> {} ({} bytes)",
        d.name, fmt_name(d.format), d.width, d.height, d.mips, path, out.len());
}

/// read a DDS, returning (format, width, height, mipCount, per-mip pixel slices).
fn read_dds(buf: &[u8]) -> (u32, u16, u16, u16, Vec<Vec<u8>>) {
    if &buf[0..4] != b"DDS " || u32(buf, 4) != 124 { die("not a DDS file"); }
    let height = u32(buf, 12) as u16;
    let width = u32(buf, 16) as u16;
    let mut mipc = u32(buf, 28) as u16;
    if mipc == 0 { mipc = 1; }
    let pf_flags = u32(buf, 80);
    let format = if pf_flags & 0x4 != 0 {
        u32(buf, 84) // FOURCC
    } else {
        let bits = u32(buf, 88);
        let amask = u32(buf, 104);
        match (bits, pf_flags) {
            (32, _) => if amask != 0 { 0x15 } else { 0x14 },
            (8, f) if f & 0x2_0000 != 0 => 0x32, // luminance
            (8, _) => 0x1c,
            (16, _) => 0x16,
            _ => die("unsupported DDS pixelformat"),
        }
    };
    let mut o = 128usize;
    let mut mips = Vec::new();
    for m in 0..mipc as usize {
        let w = (width as usize >> m).max(1);
        let h = (height as usize >> m).max(1);
        let sz = mip_bytes(format, w, h);
        if o + sz > buf.len() { die("DDS mip data truncated"); }
        mips.push(buf[o..o + sz].to_vec());
        o += sz;
    }
    (format, width, height, mipc, mips)
}

// ---- (re)build the DTEX record -------------------------------------------
/// build the uncompressed mip payload from per-mip pixel data (regenerates descriptors).
fn build_payload(format: u32, width: u16, height: u16, mips: &[Vec<u8>]) -> Vec<u8> {
    let mut out = Vec::new();
    for (m, data) in mips.iter().enumerate() {
        let w = (width as usize >> m).max(1) as u32;
        let h = (height as usize >> m).max(1) as u32;
        out.extend_from_slice(&(m as u32).to_le_bytes());
        out.extend_from_slice(&w.to_le_bytes());
        out.extend_from_slice(&h.to_le_bytes());
        out.extend_from_slice(&0u32.to_le_bytes());
        out.extend_from_slice(&1u32.to_le_bytes());
        out.extend_from_slice(&(data.len() as u32).to_le_bytes());
        out.extend_from_slice(data);
        let _ = format;
    }
    out
}
fn zlib_compress(raw: &[u8]) -> Vec<u8> {
    let mut e = ZlibEncoder::new(Vec::new(), Compression::fast());
    e.write_all(raw).unwrap();
    e.finish().unwrap()
}
/// serialize a full DTEX record. `preset_streams` = reuse these exact compressed bytes
/// (byte-identical container); otherwise recompress `payload` into 0x180000 chunks.
fn serialize(name: &str, format: u32, flags: u32, width: u16, height: u16, mips: u16,
             payload: &[u8], preset_streams: Option<&[Vec<u8>]>) -> Vec<u8> {
    let streams: Vec<Vec<u8>> = match preset_streams {
        Some(s) => s.to_vec(),
        None => payload.chunks(CHUNK).map(zlib_compress).collect(),
    };
    let mut out = Vec::new();
    out.extend_from_slice(&(name.len() as u32).to_le_bytes());
    out.extend_from_slice(name.as_bytes());
    out.extend_from_slice(&format.to_le_bytes());
    out.extend_from_slice(&flags.to_le_bytes());
    out.extend_from_slice(&width.to_le_bytes());
    out.extend_from_slice(&height.to_le_bytes());
    out.extend_from_slice(&mips.to_le_bytes());
    out.extend_from_slice(&(payload.len() as u32).to_le_bytes());
    out.extend_from_slice(&(streams.len() as u32).to_le_bytes());
    for s in &streams {
        out.extend_from_slice(&(s.len() as u32).to_le_bytes());
        out.extend_from_slice(s);
    }
    out
}

// ---- carve a DTEX out of an ALBS sub-pack ---------------------------------
/// find every texture record in a sub-pack: (byteStart, recordLen, name).
fn find_records(sub: &[u8]) -> Vec<(usize, usize, String)> {
    let mut v = Vec::new();
    let known = |f: u32| matches!(f, DXT1 | DXT3 | DXT5)
        || uncompressed_bpp(f).is_some();
    let mut i = 0usize;
    while i + 26 < sub.len() {
        let f = u32(sub, i);
        if known(f) {
            // name length u32 immediately before an ascii name ending at i
            for nl in 1..80usize {
                if i < 4 + nl { break; }
                let lo = i - 4 - nl;
                if u32(sub, lo) as usize == nl
                    && sub[lo + 4..lo + 4 + nl].iter().all(|&b| (0x20..0x7f).contains(&b))
                    && lo + 4 + nl == i
                {
                    let d = parse(&sub[lo..]);
                    v.push((lo, d.total_len, d.name.clone()));
                    break;
                }
            }
        }
        i += 1;
    }
    v
}

// ---- misc -----------------------------------------------------------------
fn put32(b: &mut [u8], o: usize, v: u32) { b[o..o + 4].copy_from_slice(&v.to_le_bytes()); }
fn die(m: &str) -> ! { eprintln!("error: {m}"); std::process::exit(1); }
fn read_file(p: &str) -> Vec<u8> {
    let mut f = std::fs::File::open(p).unwrap_or_else(|e| die(&format!("open {p}: {e}")));
    let mut v = Vec::new(); f.read_to_end(&mut v).unwrap(); v
}
fn write_file(p: &str, b: &[u8]) {
    std::fs::File::create(p).and_then(|mut f| f.write_all(b)).unwrap_or_else(|e| die(&format!("write {p}: {e}")));
}

fn usage() -> ! {
    eprintln!("sab_dtex — read/write The Saboteur DTEX textures\n");
    eprintln!("  info    <in.dtex>                      print header + mip table");
    eprintln!("  extract <in.dtex> <out.dds>            decode DTEX -> DDS");
    eprintln!("  pack    <in.dds> <template.dtex> <out.dtex> [--preserve]");
    eprintln!("             rebuild a DTEX (name/flags/format from template); --preserve reuses");
    eprintln!("             the template's exact zlib streams (byte-identical container).");
    eprintln!("  list    <in.sub>                       list texture records in an ALBS sub-pack");
    eprintln!("  carve   <in.sub> <name> <out.dtex>     dump one texture record verbatim");
    eprintln!("  roundtrip <in.dtex>                    decode->re-encode oracle (byte-identity)");
    std::process::exit(2);
}

fn main() {
    let a: Vec<String> = std::env::args().collect();
    if a.len() < 2 { usage(); }
    match a[1].as_str() {
        "info" => {
            if a.len() < 3 { usage(); }
            let d = parse(&read_file(&a[2]));
            let pl = payload(&d);
            println!("name={:?} format={} flags=0x{:x} {}x{} mips={} unc={} streams={} recordLen={}",
                d.name, fmt_name(d.format), d.flags, d.width, d.height, d.mips, d.unc, d.streams.len(), d.total_len);
            for (idx, w, h, data) in mips_of(&d, &pl) {
                println!("  mip{idx} {w}x{h} {} bytes", data.len());
            }
        }
        "extract" => {
            if a.len() < 4 { usage(); }
            let d = parse(&read_file(&a[2]));
            let pl = payload(&d);
            let mips = mips_of(&d, &pl);
            write_dds(&d, &mips, &a[3]);
        }
        "pack" => {
            if a.len() < 5 { usage(); }
            let dds = read_file(&a[2]);
            let tmpl = parse(&read_file(&a[3]));
            let preserve = a.get(5).map(|s| s == "--preserve").unwrap_or(false);
            let (format, width, height, mipc, mip_pixels) = read_dds(&dds);
            if format != tmpl.format || width != tmpl.width || height != tmpl.height || mipc != tmpl.mips {
                eprintln!("[warn] DDS ({} {}x{} m{}) differs from template ({} {}x{} m{})",
                    fmt_name(format), width, height, mipc, fmt_name(tmpl.format), tmpl.width, tmpl.height, tmpl.mips);
            }
            let pl = build_payload(format, width, height, &mip_pixels);
            let preset = if preserve {
                if pl != payload(&tmpl) { die("--preserve requires unchanged pixels (payload differs from template)"); }
                Some(&tmpl.streams[..])
            } else { None };
            let out = serialize(&tmpl.name, format, tmpl.flags, width, height, mipc, &pl, preset);
            write_file(&a[4], &out);
            eprintln!("[pack] {} {} {}x{} m{} -> {} ({} bytes){}",
                tmpl.name, fmt_name(format), width, height, mipc, a[4], out.len(),
                if preserve { " [preserve: byte-identical container]" } else { " [recompressed]" });
        }
        "list" => {
            if a.len() < 3 { usage(); }
            let sub = read_file(&a[2]);
            for (off, len, name) in find_records(&sub) {
                let d = parse(&sub[off..off + len]);
                println!("@{off:<8} len={len:<9} {} {}x{} m{} {:?}",
                    fmt_name(d.format), d.width, d.height, d.mips, name);
            }
        }
        "carve" => {
            if a.len() < 5 { usage(); }
            let sub = read_file(&a[2]);
            let rec = find_records(&sub).into_iter().find(|(_, _, n)| n == &a[3])
                .unwrap_or_else(|| die(&format!("no texture named {:?} in sub-pack", a[3])));
            write_file(&a[4], &sub[rec.0..rec.0 + rec.1]);
            eprintln!("[carve] {:?} @{} len={} -> {}", a[3], rec.0, rec.1, a[4]);
        }
        "roundtrip" => {
            if a.len() < 3 { usage(); }
            let orig = read_file(&a[2]);
            let d = parse(&orig);
            let pl = payload(&d);
            let mips = mips_of(&d, &pl);
            let mip_pixels: Vec<Vec<u8>> = mips.iter().map(|(_, _, _, s)| s.to_vec()).collect();
            // (1) descriptor oracle: rebuilt payload == original decompressed payload
            let rebuilt_pl = build_payload(d.format, d.width, d.height, &mip_pixels);
            let pl_ok = rebuilt_pl == pl;
            // (2) container oracle: rebuild whole record, reuse original streams
            let rebuilt = serialize(&d.name, d.format, d.flags, d.width, d.height, d.mips, &pl, Some(&d.streams));
            // compare against the record slice (orig may have trailing padding)
            let container_ok = rebuilt.as_slice() == &orig[..d.total_len];
            // (3) semantic: recompress, re-decode, compare pixels
            let recompressed = serialize(&d.name, d.format, d.flags, d.width, d.height, d.mips, &pl, None);
            let d2 = parse(&recompressed);
            let pl2 = payload(&d2);
            let semantic_ok = pl2 == pl;
            println!("name={:?} {} {}x{} mips={} streams={} recordLen={}",
                d.name, fmt_name(d.format), d.width, d.height, d.mips, d.streams.len(), d.total_len);
            println!("  [1] descriptor payload rebuild byte-identical: {}", yn(pl_ok));
            println!("  [2] container rebuild (preserve streams) byte-identical: {}", yn(container_ok));
            println!("  [3] recompress->decode pixels identical (semantic): {}", yn(semantic_ok));
            if !(pl_ok && container_ok && semantic_ok) { std::process::exit(1); }
        }
        _ => usage(),
    }
}
fn yn(b: bool) -> &'static str { if b { "YES" } else { "NO" } }
