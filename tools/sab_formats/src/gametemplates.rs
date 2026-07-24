//! GameTemplates.wsd (magic `AULB`) — The Saboteur's object-definition layer: a flat table of named
//! templates (disguise use-points, cars, weapons, props, lights, particles, humans…), each a bag of
//! `{property-hash → data}` pairs. Ground-truthed against `DLC/01/GameTemplates.wsd` and the full main
//! DB (embedded in `France/loosefiles_BinPC.pack`), and the loader `FUN_0162bfa0 @0x0162bfa0`. See
//! `tools/sab_gametemplates/GAMETEMPLATES_FORMAT.md`.
//!
//! ```text
//! Header: "AULB", u32 entry_count
//! entry_count × Entry, each a Marker (12 bytes: 08 00 00 00 + 8 zero) or a Template:
//!   u32 total_size (bytes after this field), u32 unk1=0, u32 unk2=1,
//!   u32 name_len, name+NUL, u32 type_len, type+NUL, u32 pair_count,
//!   pair_count × { u32 hash=pandemic_hash(prop) LE, u32 data_size, data[data_size] }
//! ```
//!
//! A 4-byte `data` may itself be a `pandemic_hash` — a sibling-template ref, `"none"`, or a **texture**
//! (`data == pandemic_hash(textureName)`, the ALBS/WSTX key; see the format doc §Texture references).

use crate::pandemic_hash;

const MAGIC: &[u8; 4] = b"AULB";
const MARKER: [u8; 12] = [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

#[derive(Clone, Debug)]
pub struct Pair {
    pub hash: u32,
    pub data: Vec<u8>,
}

impl Pair {
    /// If `data` is exactly 4 bytes, its little-endian u32 (an int / f32 bits / a pandemic_hash ref).
    pub fn as_u32(&self) -> Option<u32> {
        (self.data.len() == 4).then(|| u32::from_le_bytes(self.data.clone().try_into().unwrap()))
    }
}

#[derive(Clone, Debug)]
pub struct Template {
    pub unk1: u32,
    pub unk2: u32,
    pub name: String,
    pub ttype: String,
    pub pairs: Vec<Pair>,
}

impl Template {
    pub fn pair(&self, hash: u32) -> Option<&Pair> {
        self.pairs.iter().find(|p| p.hash == hash)
    }
    pub fn pair_mut(&mut self, hash: u32) -> Option<&mut Pair> {
        self.pairs.iter_mut().find(|p| p.hash == hash)
    }
    /// Set (or insert) a pair's data by property-name hash.
    pub fn set_pair(&mut self, hash: u32, data: Vec<u8>) {
        match self.pair_mut(hash) {
            Some(p) => p.data = data,
            None => self.pairs.push(Pair { hash, data }),
        }
    }
    fn body_size(&self) -> usize {
        let mut n = 4 + 4; // unk1 + unk2
        n += 4 + self.name.len() + 1;
        n += 4 + self.ttype.len() + 1;
        n += 4; // pair_count
        for p in &self.pairs {
            n += 4 + 4 + p.data.len();
        }
        n
    }
}

#[derive(Clone, Debug)]
pub enum Entry {
    Marker,
    Template(Template),
}

pub struct GameTemplates {
    pub entries: Vec<Entry>,
}

fn rd_u32(b: &[u8], o: usize) -> Result<u32, String> {
    b.get(o..o + 4).map(|s| u32::from_le_bytes([s[0], s[1], s[2], s[3]])).ok_or_else(|| format!("EOF u32 @{o}"))
}

impl GameTemplates {
    /// Iterate templates (skipping markers) with their entry index.
    pub fn templates(&self) -> impl Iterator<Item = (usize, &Template)> {
        self.entries.iter().enumerate().filter_map(|(i, e)| match e {
            Entry::Template(t) => Some((i, t)),
            Entry::Marker => None,
        })
    }
    pub fn find(&self, name: &str) -> Option<(usize, &Template)> {
        self.templates().find(|(_, t)| t.name == name)
    }
    pub fn template_mut(&mut self, entry_index: usize) -> Option<&mut Template> {
        match self.entries.get_mut(entry_index) {
            Some(Entry::Template(t)) => Some(t),
            _ => None,
        }
    }

    pub fn parse(b: &[u8]) -> Result<(GameTemplates, usize), String> {
        if b.get(0..4) != Some(MAGIC.as_slice()) {
            return Err(format!("bad magic {:?}, expected AULB", &b.get(0..4)));
        }
        let count = rd_u32(b, 4)?;
        let mut o = 8;
        let mut entries = Vec::with_capacity(count as usize);
        for ti in 0..count {
            if b.get(o..o + 12) == Some(MARKER.as_slice()) {
                o += 12;
                entries.push(Entry::Marker);
                continue;
            }
            let total_size = rd_u32(b, o)?;
            let body_start = o + 4;
            let unk1 = rd_u32(b, body_start)?;
            let unk2 = rd_u32(b, body_start + 4)?;
            let mut p = body_start + 8;
            let nlen = rd_u32(b, p)? as usize;
            p += 4;
            let name = String::from_utf8_lossy(b.get(p..p + nlen - 1).ok_or("EOF name")?).into_owned();
            p += nlen;
            let tlen = rd_u32(b, p)? as usize;
            p += 4;
            let ttype = String::from_utf8_lossy(b.get(p..p + tlen - 1).ok_or("EOF type")?).into_owned();
            p += tlen;
            let pcount = rd_u32(b, p)?;
            p += 4;
            let mut pairs = Vec::with_capacity(pcount as usize);
            for _ in 0..pcount {
                let hash = rd_u32(b, p)?;
                let dsize = rd_u32(b, p + 4)? as usize;
                let data = b.get(p + 8..p + 8 + dsize).ok_or("EOF pair data")?.to_vec();
                p += 8 + dsize;
                pairs.push(Pair { hash, data });
            }
            let measured = (p - body_start) as u32;
            if measured != total_size {
                return Err(format!(
                    "template {ti} ({name:?}): total_size={total_size} but measured body={measured}"
                ));
            }
            o = p;
            entries.push(Entry::Template(Template { unk1, unk2, name, ttype, pairs }));
        }
        Ok((GameTemplates { entries }, o))
    }

    pub fn write(&self) -> Vec<u8> {
        let mut out = Vec::new();
        out.extend_from_slice(MAGIC);
        out.extend_from_slice(&(self.entries.len() as u32).to_le_bytes());
        for e in &self.entries {
            match e {
                Entry::Marker => out.extend_from_slice(&MARKER),
                Entry::Template(t) => {
                    out.extend_from_slice(&(t.body_size() as u32).to_le_bytes());
                    out.extend_from_slice(&t.unk1.to_le_bytes());
                    out.extend_from_slice(&t.unk2.to_le_bytes());
                    out.extend_from_slice(&((t.name.len() + 1) as u32).to_le_bytes());
                    out.extend_from_slice(t.name.as_bytes());
                    out.push(0);
                    out.extend_from_slice(&((t.ttype.len() + 1) as u32).to_le_bytes());
                    out.extend_from_slice(t.ttype.as_bytes());
                    out.push(0);
                    out.extend_from_slice(&(t.pairs.len() as u32).to_le_bytes());
                    for p in &t.pairs {
                        out.extend_from_slice(&p.hash.to_le_bytes());
                        out.extend_from_slice(&(p.data.len() as u32).to_le_bytes());
                        out.extend_from_slice(&p.data);
                    }
                }
            }
        }
        out
    }
}

/// Named property/value hashes reversed so far (property names + the `Texture` reference).
pub fn known_property_name(hash: u32) -> Option<&'static str> {
    const NAMES: &[&str] = &[
        "Name", "Model", "Priority", "Offset", "Type", "LOD", "Color", "Face", "Head", "Skin",
        "Description", "Image", "Texture", "none", "AIAttractionPt",
    ];
    NAMES.iter().copied().find(|n| pandemic_hash(n) == hash)
}
