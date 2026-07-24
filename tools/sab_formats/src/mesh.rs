//! MESH — a skinned-geometry resource wrapped by an `MSHA` block (on-disk 4CC `AHSM`).
//!
//! Located by content-scanning for the `AHSM` magic, exactly as the extractors do
//! (`tools/sab_poc::scan_msha`, `tools/sab_workshop::meshload`). The 276-byte MSHA header is
//! immediately followed by two raw zlib blobs: the MESH body and the `.dat` (VB/IB).
//!
//! ```text
//! MSHA header (276 bytes)
//!   +0x00  char AHSM
//!   +0x04  u32  unc0   MESH body uncompressed size
//!   +0x08  u32  unc1   .dat (VB/IB) uncompressed size
//!   +0x0C  u32  c0     MESH body compressed size
//!   +0x10  u32  c1     .dat compressed size
//!   +0x14  char name[256]  (NUL-terminated)
//!   body  = zlib_inflate(buf[off+276 .. off+276+c0])  must be unc0 bytes
//!   .dat  = zlib_inflate(buf[off+276+c0 .. +c1])       must be unc1 bytes
//! ```

use std::io::Read;

pub const MAGIC: &[u8; 4] = b"AHSM";
pub const HEADER: usize = 276;

fn u32at(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

/// One MSHA wrapper located inside a sub-pack.
#[derive(Clone, Debug)]
pub struct Msha {
    /// Byte offset of the `AHSM` magic within the scanned buffer.
    pub off: usize,
    pub name: String,
    pub unc0: u32,
    pub unc1: u32,
    pub c0: u32,
    pub c1: u32,
}

/// Content-scan `buf` for every valid MSHA wrapper. Applies the same acceptance test as the
/// extractors (printable name, non-zero compressed/uncompressed body size, body in-bounds) so a
/// hit is a real mesh, not a coincidental `AHSM` byte pattern.
pub fn scan_msha(buf: &[u8]) -> Vec<Msha> {
    let mut out = Vec::new();
    let mut i = 0usize;
    while i + HEADER <= buf.len() {
        if &buf[i..i + 4] == MAGIC {
            let unc0 = u32at(buf, i + 4);
            let unc1 = u32at(buf, i + 8);
            let c0 = u32at(buf, i + 12);
            let c1 = u32at(buf, i + 16);
            let nb = &buf[i + 20..i + HEADER];
            let end = nb.iter().position(|&b| b == 0).unwrap_or(0);
            if end > 0
                && nb[..end].iter().all(|&b| (0x20..0x7f).contains(&b))
                && c0 > 0
                && unc0 > 0
                && i + HEADER + c0 as usize <= buf.len()
            {
                out.push(Msha {
                    off: i,
                    name: String::from_utf8_lossy(&nb[..end]).into_owned(),
                    unc0,
                    unc1,
                    c0,
                    c1,
                });
            }
        }
        i += 1;
    }
    out
}

/// Decode one blob. The cooker stores a blob raw when compression does not help, signalled by
/// `comp == unc` (matches the "store if incompressible" pattern the engine's stream loader relies
/// on: e.g. the intentionally-degenerate `*_Invisible_*` debris meshes). Otherwise it's zlib.
fn decode(src: &[u8], comp: usize, unc: usize) -> Result<Vec<u8>, String> {
    if comp == unc {
        return Ok(src[..comp].to_vec());
    }
    let mut z = flate2::read::ZlibDecoder::new(src);
    let mut out = Vec::with_capacity(unc);
    z.read_to_end(&mut out).map_err(|e| format!("zlib inflate: {e}"))?;
    Ok(out)
}

/// Decode the MESH body and `.dat` blobs that follow a MSHA header, asserting each yields its
/// declared uncompressed size. A mismatch is exactly the corruption a mod repack can introduce
/// (the engine trusts these sizes when it allocates), so the caller reports it as fatal.
pub fn read_body_and_dat(buf: &[u8], m: &Msha) -> Result<(Vec<u8>, Vec<u8>), String> {
    let s0 = m.off + HEADER;
    let e0 = s0 + m.c0 as usize;
    if e0 > buf.len() {
        return Err(format!("body blob [0x{s0:X}..0x{e0:X}] overruns buffer 0x{:X}", buf.len()));
    }
    let body = decode(&buf[s0..e0], m.c0 as usize, m.unc0 as usize)?;
    if body.len() != m.unc0 as usize {
        return Err(format!("body decoded to {} bytes, header declares {}", body.len(), m.unc0));
    }
    let dat = if m.c1 > 0 && e0 + m.c1 as usize <= buf.len() {
        let d = decode(&buf[e0..e0 + m.c1 as usize], m.c1 as usize, m.unc1 as usize)?;
        if d.len() != m.unc1 as usize {
            return Err(format!(".dat decoded to {} bytes, header declares {}", d.len(), m.unc1));
        }
        d
    } else if m.c1 > 0 {
        return Err(format!(".dat blob (c1={}) overruns buffer", m.c1));
    } else {
        Vec::new()
    };
    Ok((body, dat))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    fn zlib(data: &[u8]) -> Vec<u8> {
        let mut e = flate2::write::ZlibEncoder::new(Vec::new(), flate2::Compression::fast());
        e.write_all(data).unwrap();
        e.finish().unwrap()
    }

    /// A blob whose comp == unc is stored raw (the `*_Invisible_*` debris case): copy, don't inflate.
    #[test]
    fn decode_stored_when_comp_equals_unc() {
        let raw = vec![0u8; 852];
        assert_eq!(decode(&raw, 852, 852).unwrap(), raw);
    }

    /// A blob whose comp < unc is a zlib stream.
    #[test]
    fn decode_inflates_when_compressed() {
        let body = b"the quick brown fox".repeat(20);
        let comp = zlib(&body);
        let out = decode(&comp, comp.len(), body.len()).unwrap();
        assert_eq!(out, body);
    }

    /// A synthetic MSHA with a stored body + no .dat round-trips through read_body_and_dat.
    #[test]
    fn read_stored_body() {
        let mut buf = Vec::from(*MAGIC);
        buf.extend_from_slice(&4u32.to_le_bytes()); // unc0
        buf.extend_from_slice(&0u32.to_le_bytes()); // unc1
        buf.extend_from_slice(&4u32.to_le_bytes()); // c0 == unc0 -> stored
        buf.extend_from_slice(&0u32.to_le_bytes()); // c1
        let mut name = [0u8; 256];
        name[..4].copy_from_slice(b"Test"); // printable, NUL-terminated
        buf.extend_from_slice(&name);
        buf.extend_from_slice(&[1, 2, 3, 4]); // stored body
        let found = scan_msha(&buf);
        assert_eq!(found.len(), 1);
        let (body, dat) = read_body_and_dat(&buf, &found[0]).unwrap();
        assert_eq!(body, vec![1, 2, 3, 4]);
        assert!(dat.is_empty());
    }
}
