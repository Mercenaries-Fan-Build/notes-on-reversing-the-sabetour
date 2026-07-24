//! `SBLA`/`ALBS` — the per-asset sub-pack that lives inside a megapack entry.
//!
//! Parses the hash→offset directory the streaming loader `FUN_00658870` (VA 0x00658870,
//! magic 0x53424C41 = "ALBS") walks. Layout and the two blob-placement models are
//! ground-truthed by `tools/sab_sbla` (byte-identical parse→rebuild over 1042 real sub-packs).
//!
//! ```text
//! HEADER
//!   +0x00  char magic[4] = "ALBS"
//!   +0x04  u32  flags        0x00 object variant | 0x3C streamblock variant
//!   +0x08  u32  name_crc     pandemic_hash(assetName); 0 for streamblocks
//!   +0x0C  u32  reserved
//!   ...    header words preserved verbatim to dir_start
//! DIRECTORY  (0x20 when flags != 0x3C, else 0x44) — 24-byte records:
//!   +0x00 u32 hash        per-sub-asset hash; 0 => section-boundary placeholder (no bytes)
//!   +0x04 u32 offset      running blob offset, RELATIVE to a base (object: dir_end; streamblock: 0)
//!                         — never an absolute file offset. Chains offset[i] = offset[i-1] + comp[i-1]
//!   +0x08 u32 comp        stored (zlib) blob length
//!   +0x0C u32 uncomp      decompressed length
//!   +0x10 u32 f4          flags/lod
//!   +0x14 u32 f5          aux
//!   Directory ends at the first record whose `offset` != the running cursor.
//! BODY  span = sum(comp of real records); placed "middle" (first >= dir_end → blob_base =
//!       dir_end + first, with a `first`-byte MIDDLE block between directory and blobs) or
//!       "tail" (at EOF - span).
//! ```
//!
//! ⚠️ `offset` is dir_end-RELATIVE. Treating it as absolute (blob_base = first) is wrong by exactly
//! `dir_end` and yields a phantom trailing region of that same size. A parse→rebuild round-trip
//! cannot detect the error — it relays regions verbatim — but any consumer that *slices* blobs by
//! `blob_base` reads the wrong bytes, and any splice corrupts the preceding asset. Verified over
//! every ALBS sub-pack in Dynamic0 + Palettes0 + Mega0 + Start0 + BelleStart0: for the object
//! variant, `dir_end + first + span == fileSize` exactly in 1080 of 1137 packs (the rest have a
//! genuine small footer). Corrected 2026-07-24; see `tools/sab_sbla/README.md`.

fn u32le(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

/// The engine's magic constant, in on-disk byte order.
pub const MAGIC: &[u8; 4] = b"ALBS";

/// One 24-byte directory record.
#[derive(Clone, Copy, Debug)]
pub struct Record {
    pub hash: u32,
    pub offset: u32,
    pub comp: u32,
    pub uncomp: u32,
    pub f4: u32,
    pub f5: u32,
}
impl Record {
    /// A real blob-bearing record (hash != 0). Zero-hash records are section boundaries that
    /// contribute no bytes and do not advance the blob cursor.
    pub fn real(&self) -> bool {
        self.hash != 0
    }
}

/// Where the concatenated blob region sits relative to the directory.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Model {
    /// Object variant: `offset` is relative to `dir_end`, so blobs begin at `dir_end + first`
    /// with a `first`-byte MIDDLE block (the uncompressed MSHA/DTEX descriptors) in between.
    Middle,
    /// Streamblock variant: `offset` is blob-relative (`first == 0`); blobs sit at the end of file.
    Tail,
}

/// A parsed sub-pack directory. Blob *bytes* are borrowed from the caller's buffer via
/// [`blob_ranges`]; this struct holds only the directory + placement facts a validator needs.
#[derive(Clone, Debug)]
pub struct Sbla {
    pub flags: u32,
    pub name_crc: u32,
    pub dir_start: usize,
    pub dir_end: usize,
    pub recs: Vec<Record>,
    pub first: u32,
    pub span: u32,
    pub model: Model,
    pub blob_base: usize,
}

/// Parse the directory. Strict: bad magic, an unknown header variant, an empty directory, or a
/// blob region that falls outside the buffer are errors the validator surfaces as fatal.
pub fn parse(buf: &[u8]) -> Result<Sbla, String> {
    let size = buf.len();
    if size < 0x20 || &buf[0..4] != MAGIC {
        return Err("not an ALBS sub-pack (bad magic / too small)".into());
    }
    let flags = u32le(buf, 4);
    // 0x00 = object (single/multi mesh or texture bundle; absolute blob offsets)
    // 0x3C = streamblock (baked world cell; blob-relative offsets, blobs at EOF)
    if flags != 0x00 && flags != 0x3C {
        return Err(format!("unknown ALBS header variant flags=0x{flags:X} (expected 0x00 or 0x3C)"));
    }
    let name_crc = u32le(buf, 8);
    let dir_start = if flags == 0x3C { 0x44 } else { 0x20 };
    if dir_start + 24 > size {
        return Err("no directory".into());
    }
    let first = u32le(buf, dir_start + 4);
    let mut recs = Vec::new();
    let mut cursor = first;
    let mut o = dir_start;
    while o + 24 <= size {
        let r = Record {
            hash: u32le(buf, o),
            offset: u32le(buf, o + 4),
            comp: u32le(buf, o + 8),
            uncomp: u32le(buf, o + 12),
            f4: u32le(buf, o + 16),
            f5: u32le(buf, o + 20),
        };
        // Directory ends when the offset field no longer matches the running cursor (that word
        // is the magic of the next region), or a size is nonsensical.
        if r.offset != cursor || (r.comp as usize) > size {
            break;
        }
        if r.real() {
            cursor = cursor.wrapping_add(r.comp);
        }
        recs.push(r);
        o += 24;
    }
    if recs.is_empty() {
        return Err("empty directory".into());
    }
    let dir_end = o;
    let span = cursor.wrapping_sub(first);
    // `offset` is relative to dir_end for the object variant (see the ⚠️ note at the top of this
    // module) — reading it as absolute puts every blob dir_end bytes early.
    let (model, blob_base) = if first as usize >= dir_end {
        (Model::Middle, dir_end.checked_add(first as usize).ok_or("dir_end + first overflows")?)
    } else {
        (Model::Tail, size.checked_sub(span as usize).ok_or("span > file size")?)
    };
    if blob_base < dir_end || blob_base + span as usize > size {
        return Err(format!(
            "blob region out of range (base=0x{blob_base:X} span=0x{span:X} size=0x{size:X})"
        ));
    }
    Ok(Sbla { flags, name_crc, dir_start, dir_end, recs, first, span, model, blob_base })
}

/// The `(start, end)` byte range of each record's compressed blob **within the full archive
/// buffer**, in directory order. Placeholder (zero-hash) records map to an empty range.
///
/// Mirrors `tools/sab_sbla`'s proven body-relative accumulation (`p += comp`) and rebases it onto
/// `blob_base`, so a real record's slice is `buf[start..end]` regardless of placement model.
pub fn blob_ranges(s: &Sbla) -> Vec<(usize, usize)> {
    let mut v = Vec::with_capacity(s.recs.len());
    let mut p = s.blob_base;
    for r in &s.recs {
        if r.real() {
            v.push((p, p + r.comp as usize));
            p += r.comp as usize;
        } else {
            v.push((p, p));
        }
    }
    v
}
