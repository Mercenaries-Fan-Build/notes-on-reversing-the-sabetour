//! In-app megapack reader — open a `.megapack`, enumerate its ALBS sub-pack entries, and hand back
//! each entry's bytes. Enough of `tools/sab_pack` to let the viewer read a character's DTEX bundles
//! straight from the game install (mirrors how `mercs2_workshop` reads the WAD in-process).
//!
//! Megapack layout (COPIED from `tools/sab_pack`, verified vs `Global/Dynamic0.megapack`):
//!   +0x00 char magic[4] = "00PM"
//!   +0x04 u32  count
//!   +0x08 Entry[count] (20 B: u32 crc, u32 index, u32 size, u64 offset)
//!   ...   table2[count] (8 B pairs, ignored here)
//!   ...   sub-pack bytes at each entry's `offset`

#![allow(dead_code)]

const MAGIC: &[u8; 4] = b"00PM";

fn u32le(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}
fn u64le(b: &[u8], o: usize) -> u64 {
    u64::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3], b[o + 4], b[o + 5], b[o + 6], b[o + 7]])
}

/// `pandemic_hash` — the game's name hash (FNV-1a/32 variant, case-folded). Verified kernel:
/// `pandemic_hash("ANY") == 0xED057225`. Not needed for plaintext DTEX enumeration, but kept for
/// resolving hash-keyed lookups (megapack index / future WSAO).
pub fn pandemic_hash(name: &str) -> u32 {
    let mut h: u32 = 0x811C_9DC5;
    for &c in name.as_bytes() {
        h = ((c as u32 | 0x20) ^ h).wrapping_mul(0x0100_0193);
    }
    (h ^ 0x2A).wrapping_mul(0x0100_0193)
}

#[derive(Clone, Copy)]
pub struct Entry {
    pub crc: u32,
    pub index: u32,
    pub size: u32,
    pub offset: u64,
}

/// An opened megapack: the whole file in memory + its parsed index. Character texture bundles are a
/// small fraction of the 715 MB Dynamic0, but the index is hash-only (no plaintext paths), so we
/// scan bundle bytes for a character token rather than resolve names — see `find_textures`.
pub struct Megapack {
    data: Vec<u8>,
    entries: Vec<Entry>,
}

impl Megapack {
    pub fn open(path: &str) -> Result<Megapack, String> {
        let data = std::fs::read(path).map_err(|e| format!("read {path}: {e}"))?;
        if data.len() < 8 || &data[0..4] != MAGIC {
            return Err(format!("not a megapack (magic {:02X?})", &data[0..4.min(data.len())]));
        }
        let count = u32le(&data, 4) as usize;
        let mut entries = Vec::with_capacity(count);
        let mut p = 8usize;
        for _ in 0..count {
            if p + 20 > data.len() {
                return Err("megapack index truncated".into());
            }
            entries.push(Entry {
                crc: u32le(&data, p),
                index: u32le(&data, p + 4),
                size: u32le(&data, p + 8),
                offset: u64le(&data, p + 12),
            });
            p += 20;
        }
        Ok(Megapack { data, entries })
    }

    pub fn entry_count(&self) -> usize {
        self.entries.len()
    }

    /// The whole file. Needed by scanners that work on absolute file offsets rather than per-entry
    /// slices (e.g. the `AHSM` model sweep in `meshload::list_meshes`).
    pub fn raw(&self) -> &[u8] {
        &self.data
    }

    /// The bytes of entry `i`'s ALBS sub-pack (bounds-checked; empty slice if the entry is corrupt).
    pub fn slice(&self, e: &Entry) -> &[u8] {
        let s = e.offset as usize;
        let end = s.saturating_add(e.size as usize).min(self.data.len());
        if s >= self.data.len() || end <= s {
            return &[];
        }
        &self.data[s..end]
    }

    pub fn entries(&self) -> &[Entry] {
        &self.entries
    }

    /// The entry whose sub-pack spans absolute file offset `off` — maps a model found by the raw
    /// `AHSM` sweep back to the bundle it lives in (so we can read that bundle's textures).
    pub fn entry_containing(&self, off: usize) -> Option<Entry> {
        self.entries.iter().find(|e| {
            let s = e.offset as usize;
            off >= s && off < s + e.size as usize
        }).copied()
    }
}

/// Case-insensitive substring search (ASCII) — bundles store DTEX names in plaintext, so a bundle
/// holding a character's textures contains that character token as raw bytes.
pub fn contains_ascii_ci(haystack: &[u8], needle: &str) -> bool {
    let nl = needle.len();
    if nl == 0 || haystack.len() < nl {
        return false;
    }
    let nlow = needle.as_bytes();
    haystack.windows(nl).any(|w| {
        w.iter().zip(nlow).all(|(a, b)| a.eq_ignore_ascii_case(b))
    })
}
