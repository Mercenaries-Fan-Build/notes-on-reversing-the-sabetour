//! WSAO material→texture resolver — the engine's real binding, read from `France.materials`
//! (loose file at the game root, magic `OASW`, ~4.3 MB — PRESENT on the retail PC build; the earlier
//! "absent on PC" note was wrong). A drawcall material hash → a WSMA record → a
//! `[textureBegin..+numTextures]` slice of the WSTX texture-name-hash array (order [d,s,n,wm], so
//! slot 0 is the colour map). This is what the click-path resolver uses instead of the name-suffix
//! heuristic — the mapping the game itself uses, correct for every character/vehicle/weapon/prop, not
//! just the ~27 assets whose textures happen to carry a `_D` suffix.

#![allow(dead_code)]

use std::collections::HashMap;

fn u32at(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

pub struct Wsao {
    wstx: Vec<u32>,
    by_mat: HashMap<u32, (u32, u32)>,
}

impl Wsao {
    pub fn open(path: &str) -> Result<Wsao, String> {
        let b = std::fs::read(path).map_err(|e| format!("read {path}: {e}"))?;
        if b.len() < 80 || &b[0..4] != b"OASW" {
            return Err("not a WSAO (France.materials) file".into());
        }
        let num_wstx = u32at(&b, 4 * 17) as usize;
        let num_wsma = u32at(&b, 8) as usize;
        let find = |m: &[u8; 4]| b.windows(4).position(|w| w == m).ok_or("block not found");
        let wstx_off = find(b"XTSW")? + 4;
        let wsma_off = find(b"AMSW")? + 4;
        let wstx: Vec<u32> = (0..num_wstx).map(|i| u32at(&b, wstx_off + i * 4)).collect();
        let mut by_mat = HashMap::new();
        let mut o = wsma_off;
        for _ in 0..num_wsma {
            if o + 8 > b.len() {
                break;
            }
            // Field 0 is a record UID, NOT a drawcall material hash: measured to match a drawcall's
            // `materials[0]` 0/14331 times. The hashes a drawcall actually keys on are the `ids[]`
            // (alias) array that follows. Indexing by `uid` first (as this once did) only mislead the
            // lookup — on a collision it would hand back the UID owner's textures — so skip it.
            let _uid = u32at(&b, o);
            let idc = u32at(&b, o + 4) as usize;
            o += 8;
            if idc > 64 || o + idc * 4 + 16 > b.len() {
                break;
            }
            let ids: Vec<u32> = (0..idc).map(|i| u32at(&b, o + i * 4)).collect();
            o += idc * 4;
            let num_tex = u32at(&b, o + 4);
            let tex_begin = u32at(&b, o + 8);
            o += 16;
            for id in ids {
                by_mat.entry(id).or_insert((tex_begin, num_tex));
            }
        }
        Ok(Wsao { wstx, by_mat })
    }

    /// Texture name-hashes for a material hash, in [diffuse, spec, normal, wm] order.
    pub fn textures(&self, mat: u32) -> Option<Vec<u32>> {
        let &(begin, n) = self.by_mat.get(&mat)?;
        let (b, e) = (begin as usize, (begin + n) as usize);
        (e <= self.wstx.len()).then(|| self.wstx[b..e].to_vec())
    }
}

/// Load a loose `<dir>/<hash:08X>.dtex` (as written by `sab_poc mattias`) and decode its finest mip.
pub fn load_loose_dtex(dir: &str, hash: u32) -> Result<crate::dtex::CpuTexture, String> {
    let path = format!("{dir}/{hash:08X}.dtex");
    let bytes = std::fs::read(&path).map_err(|e| format!("read {path}: {e}"))?;
    // files are written with a leading 'DTEX' tag; the decoder wants the bare record
    let rec = if bytes.len() > 4 && &bytes[0..4] == b"DTEX" { &bytes[4..] } else { &bytes[..] };
    crate::dtex::decode(rec)
}
