//! `.megapack` — the outer Saboteur archive (on-disk magic `00PM`).
//!
//! Parses the index the streaming mounter `FUN_00e428c0` reads. Field layout and the 2048-byte
//! sector alignment are ground-truthed by `tools/sab_pack` (byte-verified writer round-trip over
//! `Global\Dynamic0.megapack`, 759 entries).
//!
//! ```text
//! HEADER
//!   +0x00  char  magic[4] = "00PM"        (the u32 the engine tests)
//!   +0x04  u32   count                    number of entries
//!   +0x08  Entry index[count]             20 bytes each
//!   ...    Pair  table2[count]            8 bytes each ({crc,index}, mirrors index[] order)
//!   ...    pad to 2048                    (0xCB filler; engine never reads it)
//!   ...    sub-pack bytes at each entry.offset (2048-aligned, zero-padded to 2048)
//!
//! Entry (20 bytes)
//!   +0x00  u32  crc      resource path_crc = pandemic_hash("global\\<name>.dynpack")  (bsearch key)
//!   +0x04  u32  index    resource name_crc = pandemic_hash(name)  (or streamblock ordinal in world packs)
//!   +0x08  u32  size     exact byte length of the sub-pack at `offset`
//!   +0x0C  u64  offset   absolute file offset of the sub-pack
//! ```

/// The engine's magic constant, in on-disk byte order.
pub const MAGIC: &[u8; 4] = b"00PM";
/// Observed alignment of every data offset in the retail packs.
pub const SECTOR: u64 = 2048;

fn u32le(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}
fn u64le(b: &[u8], o: usize) -> u64 {
    u64::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3], b[o + 4], b[o + 5], b[o + 6], b[o + 7]])
}

/// One index entry (20 bytes on disk).
#[derive(Clone, Copy, Debug)]
pub struct Entry {
    /// `path_crc` — the bsearch key the mounter compares against.
    pub crc: u32,
    /// `name_crc` for Global dynpacks; a streamblock ordinal for world packs.
    pub index: u32,
    /// Sub-pack byte length.
    pub size: u32,
    /// Absolute file offset of the sub-pack.
    pub offset: u64,
}

/// A parsed megapack index (the archive body stays in the caller's original buffer).
#[derive(Clone, Debug)]
pub struct Megapack {
    pub count: usize,
    pub entries: Vec<Entry>,
}

impl Megapack {
    /// Largest `offset + size` across entries — the file size the header implies.
    pub fn implied_end(&self) -> u64 {
        self.entries.iter().map(|e| e.offset + e.size as u64).max().unwrap_or(0)
    }
}

/// Parse the megapack index. Strict: bad magic or a truncated index is an error (i.e. a
/// structural finding the validator reports as fatal). Entry *contents* (offset/size sanity,
/// alignment) are validated separately against the actual buffer length.
pub fn parse(buf: &[u8]) -> Result<Megapack, String> {
    if buf.len() < 8 {
        return Err("file smaller than an 8-byte megapack header".into());
    }
    if &buf[0..4] != MAGIC {
        return Err(format!(
            "bad magic {:02X?} (expected {:02X?} \"00PM\")",
            &buf[0..4],
            MAGIC
        ));
    }
    let count = u32le(buf, 4) as usize;
    // A count that can't fit its own index table is a corrupt header, not a huge archive.
    let index_bytes = count.checked_mul(20).ok_or("entry count overflows")?;
    if 8 + index_bytes > buf.len() {
        return Err(format!(
            "index truncated: header claims {count} entries ({index_bytes} bytes) but file has {}",
            buf.len()
        ));
    }
    let mut entries = Vec::with_capacity(count);
    let mut p = 8;
    for _ in 0..count {
        entries.push(Entry {
            crc: u32le(buf, p),
            index: u32le(buf, p + 4),
            size: u32le(buf, p + 8),
            offset: u64le(buf, p + 12),
        });
        p += 20;
    }
    Ok(Megapack { count, entries })
}

/// Borrow the sub-pack bytes for one entry from the archive buffer.
pub fn entry_slice<'a>(buf: &'a [u8], e: &Entry) -> Option<&'a [u8]> {
    let s = e.offset as usize;
    let end = s.checked_add(e.size as usize)?;
    buf.get(s..end)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_bad_magic() {
        assert!(parse(b"XXXX\0\0\0\0").is_err());
    }

    #[test]
    fn rejects_truncated_index() {
        // Header claims 100 entries but the file holds none of them.
        let mut b = Vec::from(*MAGIC);
        b.extend_from_slice(&100u32.to_le_bytes());
        assert!(parse(&b).unwrap_err().contains("truncated"));
    }

    #[test]
    fn parses_single_entry() {
        let mut b = Vec::from(*MAGIC);
        b.extend_from_slice(&1u32.to_le_bytes());
        b.extend_from_slice(&0xAAAA_AAAAu32.to_le_bytes()); // crc
        b.extend_from_slice(&0xBBBB_BBBBu32.to_le_bytes()); // index
        b.extend_from_slice(&2048u32.to_le_bytes()); // size
        b.extend_from_slice(&2048u64.to_le_bytes()); // offset
        let mp = parse(&b).unwrap();
        assert_eq!(mp.count, 1);
        assert_eq!(mp.entries[0].crc, 0xAAAA_AAAA);
        assert_eq!(mp.implied_end(), 4096);
    }
}
