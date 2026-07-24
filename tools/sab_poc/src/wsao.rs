//! WSAO material→texture resolver — `France.materials` (the loose WSAO container in the game root).
//! This is the engine's real binding (refutes the old "WSAO absent on PC" note): a drawcall's material
//! hash → a WSMA record → a `[textureBegin..+numTextures]` slice of the WSTX texture-name-hash array,
//! ordered [diffuse, spec, normal, wm]. Textures then load as Pebble assets by `pandemic_hash(name)`.
//!
//! Format from PredatorCZ/SaboteurToolset `materials/materials_extract.cpp`, byte-validated here:
//! parsing all `numWSMA` records consumes the WSMA block exactly to EOF, and Sean's head material
//! resolves to his four known head textures.

#![allow(dead_code)]

use std::collections::HashMap;

use crate::Flags;

fn u32at(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

/// Parsed WSAO: material hash -> (textureBegin, numTextures) into the WSTX array.
pub struct Wsao {
    pub wstx: Vec<u32>,                 // flat texture-name-hash array
    pub by_mat: HashMap<u32, (u32, u32)>, // material hash (uid OR identifier) -> slice
}

impl Wsao {
    pub fn open(path: &str) -> Result<Wsao, String> {
        let b = std::fs::read(path).map_err(|e| format!("read {path}: {e}"))?;
        if &b[0..4] != b"OASW" {
            return Err(format!("not WSAO (magic {:02X?})", &b[0..4]));
        }
        let num_wstx = u32at(&b, 4 * 17) as usize; // header field: numWSTX
        let num_wsma = u32at(&b, 8) as usize; // header field: numWSMA

        // block offsets by magic (reversed 4CCs on disk)
        let find = |m: &[u8; 4]| -> Result<usize, String> {
            b.windows(4).position(|w| w == m).ok_or_else(|| format!("block {m:?} not found"))
        };
        let wstx_off = find(b"XTSW")? + 4; // magic then flat array
        let wsma_off = find(b"AMSW")? + 4; // magic then records

        let mut wstx = Vec::with_capacity(num_wstx);
        for i in 0..num_wstx {
            wstx.push(u32at(&b, wstx_off + i * 4));
        }

        let mut by_mat = HashMap::new();
        let mut o = wsma_off;
        for _ in 0..num_wsma {
            if o + 8 > b.len() {
                return Err("WSMA truncated".into());
            }
            let uid = u32at(&b, o);
            let idcount = u32at(&b, o + 4) as usize;
            o += 8;
            if idcount > 64 || o + idcount * 4 + 16 > b.len() {
                return Err(format!("WSMA desync (idcount {idcount})"));
            }
            let ids: Vec<u32> = (0..idcount).map(|i| u32at(&b, o + i * 4)).collect();
            o += idcount * 4;
            let _index = u32at(&b, o);
            let num_tex = u32at(&b, o + 4);
            let tex_begin = u32at(&b, o + 8);
            let _rpi = u32at(&b, o + 12);
            o += 16;
            let slice = (tex_begin, num_tex);
            by_mat.entry(uid).or_insert(slice);
            for id in ids {
                by_mat.entry(id).or_insert(slice);
            }
        }
        if o != b.len() {
            return Err(format!("WSMA parse ended at 0x{o:x}, not EOF 0x{:x} — format wrong", b.len()));
        }
        Ok(Wsao { wstx, by_mat })
    }

    /// Texture name-hashes for a material hash, in [diffuse, spec, normal, wm] order.
    pub fn textures(&self, mat: u32) -> Option<Vec<u32>> {
        let &(begin, n) = self.by_mat.get(&mat)?;
        let (b, e) = (begin as usize, (begin + n) as usize);
        if e <= self.wstx.len() {
            Some(self.wstx[b..e].to_vec())
        } else {
            None
        }
    }
}

fn u16w(v: &mut Vec<u8>, x: u16) {
    v.extend_from_slice(&x.to_le_bytes());
}
fn u32w(v: &mut Vec<u8>, x: u32) {
    v.extend_from_slice(&x.to_le_bytes());
}

/// A template WSMA record's shader/param fields (index + renderPassIndex), harvested from a real
/// character material so cloned Mattias materials use a working shader. We clone Sean's opaque BODY
/// (cloth) material, NOT his head — the head is a skin shader (subsurface/alpha) that renders the whole
/// body transparent + shimmering when applied to it.
struct Template {
    index: u32,
    rpi: u32,
}

/// Sean's highest-coverage opaque body material (main cloth/pants): 3 textures (d/s/n like Mattias's),
/// opaque render pass. Picked by geometry coverage so it's the real body shader, not a small decal.
const BODY_TEMPLATE_ID: u32 = 0x0CBFA52B;

/// Append new materials (each: material hash + ordered texture hashes [d,s,n,wm]) to a WSAO file.
/// Textures are appended to WSTX; one WSMA record per material clones the template shader/params and
/// points its slice at the new textures. Header counts patched. Writes `out`.
pub fn edit(base: &str, out: &str, new_mats: &[(u32, Vec<u32>)]) -> Result<(), String> {
    let b = std::fs::read(base).map_err(|e| format!("read {base}: {e}"))?;
    if &b[0..4] != b"OASW" {
        return Err("not WSAO".into());
    }
    let num_wstx = u32at(&b, 4 * 17) as usize;
    let num_wsma = u32at(&b, 8) as usize;
    let num_materials = u32at(&b, 4) as usize;

    let find = |m: &[u8; 4]| b.windows(4).position(|w| w == m).unwrap();
    let wstx_start = find(b"XTSW");
    let wstx_end = wstx_start + 4 + num_wstx * 4; // magic + array
    let wsma_start = find(b"AMSW");
    let wsma_data = wsma_start + 4;

    // Harvest the shader (index) + render pass (rpi) STRICTLY from Sean's opaque body material
    // 0x0CBFA52B. No silent fallback: an earlier version fell back to "the first 3-texture non-head
    // material", which — on an already-patched/accumulated base — grabbed a TRANSLUCENT material's pass
    // and made every Mattias material see-through (index 0x3a2b / rpi 0x47c9 instead of the opaque
    // 0xa97e / 0x6430). If 0x0CBFA52B isn't found, the base is not the clean France.materials — fail loud.
    let mut tmpl: Option<Template> = None;
    {
        let mut o = wsma_data;
        for _ in 0..num_wsma {
            let uid = u32at(&b, o);
            let idc = u32at(&b, o + 4) as usize;
            let base_o = o + 8 + idc * 4;
            let idmatch = uid == BODY_TEMPLATE_ID || (0..idc).any(|i| u32at(&b, o + 8 + i * 4) == BODY_TEMPLATE_ID);
            if idmatch {
                tmpl = Some(Template { index: u32at(&b, base_o), rpi: u32at(&b, base_o + 12) });
                break;
            }
            o = base_o + 16;
        }
    }
    let tmpl = tmpl.ok_or_else(|| format!(
        "opaque body template 0x{BODY_TEMPLATE_ID:08X} not found in {base} — regenerate from the CLEAN France.materials (restore France.materials.bak first)"
    ))?;
    println!("    harvested opaque body shader index=0x{:08x} renderPass=0x{:08x} from 0x{BODY_TEMPLATE_ID:08X}", tmpl.index, tmpl.rpi);

    // new WSTX entries (append all textures; dedup so shared textures reuse a slot)
    let mut new_tex: Vec<u32> = Vec::new();
    let mut tex_slot: std::collections::HashMap<u32, u32> = std::collections::HashMap::new();
    let mut slot_of = |h: u32, new_tex: &mut Vec<u32>| -> u32 {
        if let Some(&s) = tex_slot.get(&h) {
            s
        } else {
            let s = (num_wstx + new_tex.len()) as u32;
            new_tex.push(h);
            tex_slot.insert(h, s);
            s
        }
    };
    // build new WSMA records
    let mut new_records: Vec<u8> = Vec::new();
    for (mat, texes) in new_mats {
        let begin = slot_of(texes[0], &mut new_tex);
        for &t in &texes[1..] {
            slot_of(t, &mut new_tex); // ensure contiguous slots (they are, appended in order)
        }
        u32w(&mut new_records, *mat); // uid
        u32w(&mut new_records, 1); // idcount
        u32w(&mut new_records, *mat); // ids[0] = the drawcall material hash
        u32w(&mut new_records, tmpl.index); // index (cloned)
        u32w(&mut new_records, texes.len() as u32); // numTextures
        u32w(&mut new_records, begin); // textureBegin
        u32w(&mut new_records, tmpl.rpi); // renderPassIndex (cloned shader)
    }

    // rebuild file
    let mut o = Vec::with_capacity(b.len() + new_tex.len() * 4 + new_records.len());
    o.extend_from_slice(&b[0..wstx_start]); // header + WSST..WSVP
    // patch header counts (they live in b[0..80], already copied)
    let np = num_wstx + new_tex.len();
    o[4..8].copy_from_slice(&((num_materials + new_mats.len()) as u32).to_le_bytes());
    o[8..12].copy_from_slice(&((num_wsma + new_mats.len()) as u32).to_le_bytes());
    o[4 * 17..4 * 17 + 4].copy_from_slice(&(np as u32).to_le_bytes());
    // WSTX: magic + old array + new textures
    o.extend_from_slice(b"XTSW");
    o.extend_from_slice(&b[wstx_start + 4..wstx_end]);
    for &t in &new_tex {
        u32w(&mut o, t);
    }
    // region between WSTX and WSMA (WSPA) unchanged
    o.extend_from_slice(&b[wstx_end..wsma_start]);
    // WSMA: magic + old records + new records
    o.extend_from_slice(b"AMSW");
    o.extend_from_slice(&b[wsma_data..b.len()]);
    o.extend_from_slice(&new_records);

    let _ = (u16w,);
    std::fs::write(out, &o).map_err(|e| format!("write {out}: {e}"))?;
    Ok(())
}

pub fn resolve(f: &Flags) -> Result<(), String> {
    let path = format!("{}/France.materials", f.game);
    println!("[1] parsing WSAO: {path}");
    let w = Wsao::open(&path)?;
    println!("    {} texture hashes, {} materials mapped (parse reached EOF cleanly)", w.wstx.len(), w.by_mat.len());

    // validate: Sean's head material (identifier 0x31AD5DD2) must give his 4 head textures
    println!("[2] validation — Sean's head material 0x31AD5DD2:");
    match w.textures(0x31AD5DD2) {
        Some(t) => {
            let hs: Vec<String> = t.iter().map(|h| format!("0x{h:08X}")).collect();
            let expect = [0xD0C7AFBC, 0xB2F6DEB7, 0xA8AF6BDE, 0xFB27FAB8];
            let ok = t == expect;
            println!("    -> [{}]  (roles: d, s, n, wm)  matches known head textures: {}", hs.join(", "), ok);
            if !ok {
                return Err("head material did not resolve to the known textures".into());
            }
        }
        None => return Err("head material 0x31AD5DD2 not found in WSAO".into()),
    }

    // if the user passed --mat, resolve that too
    if let Some(m) = &f.tex {
        if let Ok(h) = u32::from_str_radix(m.trim_start_matches("0x"), 16) {
            println!("[3] --mat 0x{h:08X}:");
            match w.textures(h) {
                Some(t) => println!("    -> [{}]", t.iter().map(|x| format!("0x{x:08X}")).collect::<Vec<_>>().join(", ")),
                None => println!("    (no material record for that hash)"),
            }
        }
    }
    println!("\nPASS — WSAO resolver reproduces the engine's material->texture binding.");
    Ok(())
}
