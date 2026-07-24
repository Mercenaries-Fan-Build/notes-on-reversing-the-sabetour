//! DTEX — a texture resource stored inside an `ALBS` sub-pack.
//!
//! A DTEX has **no 4CC of its own**; it is a length-prefixed record. Layout ground-truthed by
//! `tools/sab_dtex` (validated on 12,559 retail textures) and corroborated against the decomp
//! (format-code map `FUN_009bb910` @0x009bb910; DXT test `FUN_00dee1c0` @0x00dee1c0).
//!
//! ```text
//!   +0x00  u32   nameLen
//!   +0x04  char  name[nameLen]
//!   +N     u32   format            D3DFMT int OR ascii 4CC (DXT1/DXT3/DXT5, 0x15 A8R8G8B8, 0x21 ...)
//!   +N+4   u32   flags
//!   +N+8   u16   width
//!   +N+0xA u16   height
//!   +N+0xC u16   mipCount
//!   +N+0xE u32   uncompressedSize  == sum over streams of decompressed length
//!   +N+0x12 u32  numStreams
//!   +N+0x16 stream[]{ u32 compSize; u8 zlib[compSize] }
//! ```
//! Decompressed streams concatenate into the mip payload: per mip (largest→smallest) a 24-byte
//! `MipDesc { u32 idx, w, h, pad0=0, one=1, dataSize }` followed by `dataSize` pixel bytes, so
//! `uncompressedSize == sum_mips(24 + dataSize)`. Streams split the payload at 0x180000 boundaries.

use std::io::Read;

pub const DXT1: u32 = 0x3154_5844;
pub const DXT3: u32 = 0x3354_5844;
pub const DXT5: u32 = 0x3554_5844;
/// Engine's per-stream uncompressed split (1572864 bytes).
pub const CHUNK: usize = 0x18_0000;
/// Size of one mip descriptor in the decompressed payload.
pub const MIPDESC: usize = 24;

fn u16(b: &[u8], o: usize) -> u16 {
    u16::from_le_bytes([b[o], b[o + 1]])
}
fn u32(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

/// Bytes-per-pixel for the uncompressed formats the engine's map accepts; `None` for
/// block-compressed (DXT) formats.
pub fn uncompressed_bpp(fmt: u32) -> Option<usize> {
    match fmt {
        0x15 | 0x16 | 0x21 => Some(4), // A8R8G8B8 / X8R8G8B8 / B8G8R8A8-ish
        _ => None,
    }
}

/// Bytes one mip level of `(w, h)` occupies for `fmt`. Returns `None` for a format the engine's
/// map does not accept (the caller reports that as a finding rather than guessing a size).
pub fn mip_bytes(fmt: u32, w: usize, h: usize) -> Option<usize> {
    Some(match fmt {
        DXT1 => ((w + 3) / 4).max(1) * ((h + 3) / 4).max(1) * 8,
        DXT3 | DXT5 => ((w + 3) / 4).max(1) * ((h + 3) / 4).max(1) * 16,
        _ => w * h * uncompressed_bpp(fmt)?,
    })
}

/// Human name for a format code.
pub fn fmt_name(fmt: u32) -> String {
    match fmt {
        DXT1 => "DXT1".into(),
        DXT3 => "DXT3".into(),
        DXT5 => "DXT5".into(),
        0x15 => "A8R8G8B8".into(),
        0x16 => "X8R8G8B8".into(),
        0x21 => "B8G8R8A8".into(),
        _ => format!("0x{fmt:08X}"),
    }
}

/// A parsed DTEX record. `streams` holds the raw compressed bytes exactly as on disk.
#[derive(Clone, Debug)]
pub struct Dtex {
    pub name: String,
    pub format: u32,
    pub flags: u32,
    pub width: u16,
    pub height: u16,
    pub mips: u16,
    /// The header's declared `uncompressedSize`.
    pub unc: u32,
    pub streams: Vec<Vec<u8>>,
    /// Record byte length actually consumed (nameLen field .. end of last stream).
    pub total_len: usize,
}

/// One walked mip: `(mipIndex, width, height, dataSize)`. The pixel bytes live at the
/// corresponding slice of the decompressed payload.
#[derive(Clone, Copy, Debug)]
pub struct Mip {
    pub index: u32,
    pub width: u32,
    pub height: u32,
    pub data_size: usize,
}

/// Parse a DTEX record from the start of `buf`. Strict on structural limits (name length, stream
/// overrun) so the validator can report a malformed record as fatal.
pub fn parse(buf: &[u8]) -> Result<Dtex, String> {
    if buf.len() < 4 {
        return Err("shorter than a DTEX nameLen field".into());
    }
    let name_len = u32(buf, 0) as usize;
    if name_len == 0 || name_len > 256 {
        return Err(format!("implausible name length {name_len} (expected 1..=256)"));
    }
    if 4 + name_len + 26 > buf.len() {
        return Err("record truncated before the fixed header".into());
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
    for i in 0..ns {
        if o + 4 > buf.len() {
            return Err(format!("stream {i}/{ns} compSize field overruns record"));
        }
        let cs = u32(buf, o) as usize;
        o += 4;
        if o + cs > buf.len() {
            return Err(format!("stream {i}/{ns} data ({cs} bytes) overruns record"));
        }
        streams.push(buf[o..o + cs].to_vec());
        o += cs;
    }
    Ok(Dtex { name, format, flags, width, height, mips, unc, streams, total_len: o })
}

/// Decompress + concatenate every stream into the full mip payload.
pub fn payload(d: &Dtex) -> Result<Vec<u8>, String> {
    let mut out = Vec::with_capacity(d.unc as usize);
    for (i, s) in d.streams.iter().enumerate() {
        let mut z = flate2::read::ZlibDecoder::new(&s[..]);
        let before = out.len();
        z.read_to_end(&mut out).map_err(|e| format!("stream {i} zlib inflate: {e}"))?;
        let _ = before;
    }
    Ok(out)
}

/// Is `fmt` a texture format code the engine's map (`FUN_009bb910`) accepts?
pub fn known_format(fmt: u32) -> bool {
    matches!(fmt, DXT1 | DXT3 | DXT5) || uncompressed_bpp(fmt).is_some()
}

/// Content-scan a sub-pack for the byte offsets where DTEX records begin. This is exactly how the
/// asset extractors (`tools/sab_dtex::find_records`) locate textures — a DTEX has no 4CC, so we
/// find a known format-code `u32` and back-scan 1..80 bytes for a `u32 nameLen` immediately
/// followed by `nameLen` printable-ASCII bytes ending exactly at the format field. Returns record
/// start offsets (the `nameLen` field); the caller parses + validates each. The discriminator is
/// tight enough that a hit is a real record (validated across 12,559 retail textures).
pub fn find_record_starts(sub: &[u8]) -> Vec<usize> {
    let mut v = Vec::new();
    let mut i = 0usize;
    while i + 26 < sub.len() {
        if known_format(u32(sub, i)) {
            for nl in 1..80usize {
                if i < 4 + nl {
                    break;
                }
                let lo = i - 4 - nl;
                if u32(sub, lo) as usize == nl
                    && lo + 4 + nl == i
                    && sub[lo + 4..lo + 4 + nl].iter().all(|&b| (0x20..0x7f).contains(&b))
                {
                    v.push(lo);
                    break;
                }
            }
        }
        i += 1;
    }
    v
}

/// Walk the mip descriptor chain in a decompressed payload. Stops early (rather than panicking)
/// if a descriptor or its data would overrun — the caller compares the count it got against
/// `d.mips` to detect truncation.
pub fn mips_of(d: &Dtex, payload: &[u8]) -> Vec<Mip> {
    let mut v = Vec::new();
    let mut o = 0usize;
    for _ in 0..d.mips {
        if o + MIPDESC > payload.len() {
            break;
        }
        let index = u32(payload, o);
        let width = u32(payload, o + 4);
        let height = u32(payload, o + 8);
        let sz = u32(payload, o + 20) as usize;
        o += MIPDESC;
        if o + sz > payload.len() {
            break;
        }
        v.push(Mip { index, width, height, data_size: sz });
        o += sz;
    }
    v
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn known_formats() {
        assert!(known_format(DXT1));
        assert!(known_format(DXT5));
        assert!(known_format(0x15)); // A8R8G8B8
        assert!(!known_format(0xDEAD_BEEF));
    }

    #[test]
    fn rejects_bad_name_length() {
        assert!(parse(&[0, 0, 0, 0, 0, 0]).is_err()); // nameLen == 0
        assert!(parse(&0x9999_9999u32.to_le_bytes()).is_err()); // absurd nameLen
    }

    #[test]
    fn dxt_mip_bytes() {
        // 256x256 DXT5 = 64*64 blocks * 16 = 65536.
        assert_eq!(mip_bytes(DXT5, 256, 256), Some(65536));
        // 256x256 DXT1 = half that.
        assert_eq!(mip_bytes(DXT1, 256, 256), Some(32768));
        assert_eq!(mip_bytes(0xDEAD_BEEF, 4, 4), None);
    }
}
