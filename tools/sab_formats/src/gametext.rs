//! GameText.dlg — The Saboteur's complete localized-text container (one file per language under
//! `Cinematics/Dialog/<Lang>/`). Holds every UI string (objectives, mission names, tooltips,
//! shop/object display names — the text GameTemplates and Lua reference) AND every cinematic VO
//! subtitle. Ground-truthed against all six retail language files and the engine parser
//! `FUN_0095f370 @0x0095f370`. See `docs/formats/gametext.md`.
//!
//! ```text
//! Header (12 bytes): u32 version=5, u32 record_count, u32 total_string_code_units
//! record_count × { "TXTD", u32 asset_id, u16 key_len(incl NUL), key[key_len], u16 str_len(CU),
//!                  u16 str[str_len] (UTF-16LE, NUL-terminated) }
//! "DNEC" section: u32 group_count, group_count × {u32 scene_hash, u32 ABS file_offset}, sub-blobs to EOF
//! ```
//!
//! * **UI text**: `key_len == 1` (a bare NUL), `asset_id == pandemic_hash("<File>_Text.<Key>")`.
//!   Add one by appending a keyless record whose `asset_id` is that hash — no Lua registration needed.
//! * **VO subtitle**: ascii `vo_…` key; store lookup is `pandemic_hash(key)`; `asset_id` = audio event.

use crate::pandemic_hash;

const MAGIC_REC: &[u8; 4] = b"TXTD";
const MAGIC_DNEC: &[u8; 4] = b"DNEC";
pub const VERSION: u32 = 5;

#[derive(Clone, Debug)]
pub struct Record {
    pub asset_id: u32,
    /// Raw key bytes exactly as on disk, INCLUDING the trailing NUL. `[0x00]` (empty) for UI text.
    pub key: Vec<u8>,
    /// UTF-16LE code units of the localized string, INCLUDING its trailing NUL terminator.
    pub text: Vec<u16>,
}

impl Record {
    /// A UI-text record: empty ascii key (`key_len==1`, a bare NUL); VO records carry a `vo_…` name.
    pub fn is_ui(&self) -> bool {
        self.key_str().is_empty()
    }
    /// Ascii key without the trailing NUL ("" for UI text).
    pub fn key_str(&self) -> String {
        let end = self.key.iter().position(|&b| b == 0).unwrap_or(self.key.len());
        String::from_utf8_lossy(&self.key[..end]).into_owned()
    }
    /// The localized string without its trailing NUL terminator.
    pub fn text_string(&self) -> String {
        let end = self.text.iter().position(|&u| u == 0).unwrap_or(self.text.len());
        String::from_utf16_lossy(&self.text[..end])
    }
    /// Replace the localized string (kept NUL-terminated on disk, matching every retail record).
    pub fn set_text(&mut self, s: &str) {
        self.text = encode_text(s);
    }
    fn size(&self) -> usize {
        4 + 4 + 2 + self.key.len() + 2 + self.text.len() * 2
    }
}

/// Encode a string to the on-disk UTF-16LE form (code units + NUL terminator; `str_len` counts it).
pub fn encode_text(s: &str) -> Vec<u16> {
    let mut v: Vec<u16> = s.encode_utf16().collect();
    v.push(0);
    v
}

pub struct GameText {
    pub version: u32,
    pub records: Vec<Record>,
    /// The whole post-records section, verbatim. If it begins with `DNEC` its absolute directory
    /// offsets are rebased on write; otherwise it is copied unchanged. `orig_base_len` remembers
    /// where the tail began on disk so the rebase delta can be computed.
    tail: Vec<u8>,
    orig_base_len: usize,
}

fn rd_u16(b: &[u8], o: usize) -> Result<u16, String> {
    b.get(o..o + 2).map(|s| u16::from_le_bytes([s[0], s[1]])).ok_or_else(|| format!("EOF u16 @{o}"))
}
fn rd_u32(b: &[u8], o: usize) -> Result<u32, String> {
    b.get(o..o + 4).map(|s| u32::from_le_bytes([s[0], s[1], s[2], s[3]])).ok_or_else(|| format!("EOF u32 @{o}"))
}

impl GameText {
    pub fn parse(b: &[u8]) -> Result<GameText, String> {
        let version = rd_u32(b, 0)?;
        if version != VERSION {
            return Err(format!("unexpected GameText version {version}, expected {VERSION}"));
        }
        let count = rd_u32(b, 4)?;
        let _total_cu = rd_u32(b, 8)?;
        let mut o = 12;
        let mut records = Vec::with_capacity(count as usize);
        for i in 0..count {
            if b.get(o..o + 4) != Some(MAGIC_REC.as_slice()) {
                return Err(format!("record {i}: bad magic at {o}, expected TXTD"));
            }
            o += 4;
            let asset_id = rd_u32(b, o)?;
            o += 4;
            let key_len = rd_u16(b, o)? as usize;
            o += 2;
            let key = b.get(o..o + key_len).ok_or("EOF key")?.to_vec();
            o += key_len;
            let str_len = rd_u16(b, o)? as usize;
            o += 2;
            let raw = b.get(o..o + str_len * 2).ok_or("EOF str")?;
            let text: Vec<u16> = raw.chunks_exact(2).map(|c| u16::from_le_bytes([c[0], c[1]])).collect();
            o += str_len * 2;
            records.push(Record { asset_id, key, text });
        }
        let orig_base_len = o;
        let tail = b[o..].to_vec();
        Ok(GameText { version, records, tail, orig_base_len })
    }

    pub fn total_code_units(&self) -> u32 {
        self.records.iter().map(|r| r.text.len() as u32).sum()
    }

    fn base_len(&self) -> usize {
        12 + self.records.iter().map(|r| r.size()).sum::<usize>()
    }

    /// Find a record by dotted UI id (`pandemic_hash(id)`) or raw asset_id.
    pub fn find(&self, asset_id: u32) -> Option<&Record> {
        self.records.iter().find(|r| r.asset_id == asset_id)
    }
    pub fn find_mut(&mut self, asset_id: u32) -> Option<&mut Record> {
        self.records.iter_mut().find(|r| r.asset_id == asset_id)
    }
    pub fn find_id(&self, dotted_id: &str) -> Option<&Record> {
        self.find(pandemic_hash(dotted_id))
    }

    /// Append a NEW UI-text record for a dotted id (`asset_id = pandemic_hash(id)`, empty key).
    /// Errors if the id already exists (use `find_mut(...).set_text` to edit).
    pub fn add_ui(&mut self, dotted_id: &str, text: &str) -> Result<u32, String> {
        let asset_id = pandemic_hash(dotted_id);
        if self.records.iter().any(|r| r.asset_id == asset_id) {
            return Err(format!("id {dotted_id:?} (0x{asset_id:08x}) already exists"));
        }
        self.records.push(Record { asset_id, key: vec![0u8], text: encode_text(text) });
        Ok(asset_id)
    }

    /// Serialize back to bytes: header + records + tail (DNEC absolute offsets rebased by the shift
    /// in the base section). Unmodified input round-trips byte-identical.
    pub fn write(&self) -> Vec<u8> {
        let mut out = Vec::with_capacity(self.base_len() + self.tail.len());
        out.extend_from_slice(&self.version.to_le_bytes());
        out.extend_from_slice(&(self.records.len() as u32).to_le_bytes());
        out.extend_from_slice(&self.total_code_units().to_le_bytes());
        for rec in &self.records {
            out.extend_from_slice(MAGIC_REC);
            out.extend_from_slice(&rec.asset_id.to_le_bytes());
            out.extend_from_slice(&(rec.key.len() as u16).to_le_bytes());
            out.extend_from_slice(&rec.key);
            out.extend_from_slice(&(rec.text.len() as u16).to_le_bytes());
            for &u in &rec.text {
                out.extend_from_slice(&u.to_le_bytes());
            }
        }
        let delta = self.base_len() as i64 - self.orig_base_len as i64;
        let mut tail = self.tail.clone();
        if delta != 0 && tail.len() >= 8 && &tail[0..4] == MAGIC_DNEC {
            let groups = u32::from_le_bytes(tail[4..8].try_into().unwrap()) as usize;
            for g in 0..groups {
                let po = 8 + g * 8 + 4; // the file_offset field of pair g
                if po + 4 > tail.len() {
                    break;
                }
                let off = u32::from_le_bytes(tail[po..po + 4].try_into().unwrap());
                let rebased = (off as i64 + delta) as u32;
                tail[po..po + 4].copy_from_slice(&rebased.to_le_bytes());
            }
        }
        out.extend_from_slice(&tail);
        out
    }
}
