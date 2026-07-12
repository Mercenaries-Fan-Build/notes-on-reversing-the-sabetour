//! SMSH mesh + `.skel` skeleton readers.
//!
//! COPIED from `tools/sab_havok65/src/gltf.rs` (`read_smsh`, `read_skel`, `Bone`, `Smsh`).
//! Do not re-derive these formats.

// Some fields (bone names, UVs) are part of the on-disk format but unused by the viewer.
#![allow(dead_code)]

/// One skeleton bone (rest/bind pose, parent link, inverse-bind for skinning).
pub struct Bone {
    pub parent: i32, // -1 for a root
    pub name: String,
    pub t: [f32; 3],
    pub r: [f32; 4], // xyzw
    pub s: [f32; 3],
    pub inv_bind: Option<[f32; 16]>, // row-major inverse bind matrix
}

/// Decoded SMSH geometry.
pub struct Smsh {
    pub positions: Vec<[f32; 3]>,
    pub normals: Vec<[f32; 3]>,
    pub uvs: Vec<[f32; 2]>,
    pub joints: Vec<[u16; 4]>, // GLOBAL skeleton bone indices
    pub weights: Vec<[f32; 4]>,
    pub indices: Vec<u32>,
}

pub fn read_smsh(b: &[u8]) -> Result<Smsh, String> {
    if b.len() < 20 || &b[0..4] != b"SMSH" {
        return Err("not an SMSH blob".into());
    }
    let rd_u32 = |o: usize| u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]);
    let rd_f32 = |o: usize| f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]);
    let rd_u16 = |o: usize| u16::from_le_bytes([b[o], b[o + 1]]);
    let nv = rd_u32(8) as usize;
    let ni = rd_u32(12) as usize;
    // Bounds check: header claims nv verts + ni indices in the fixed-stride layout below.
    let need = 20 + nv * (12 + 12 + 8 + 8 + 16) + ni * 4;
    if b.len() < need {
        return Err(format!("SMSH truncated: need {need} bytes, have {}", b.len()));
    }
    let mut p = 20usize;
    let mut positions = Vec::with_capacity(nv);
    for i in 0..nv { let o = p + i * 12; positions.push([rd_f32(o), rd_f32(o + 4), rd_f32(o + 8)]); }
    p += nv * 12;
    let mut normals = Vec::with_capacity(nv);
    for i in 0..nv { let o = p + i * 12; normals.push([rd_f32(o), rd_f32(o + 4), rd_f32(o + 8)]); }
    p += nv * 12;
    let mut uvs = Vec::with_capacity(nv);
    for i in 0..nv { let o = p + i * 8; uvs.push([rd_f32(o), rd_f32(o + 4)]); }
    p += nv * 8;
    let mut joints = Vec::with_capacity(nv);
    for i in 0..nv { let o = p + i * 8; joints.push([rd_u16(o), rd_u16(o + 2), rd_u16(o + 4), rd_u16(o + 6)]); }
    p += nv * 8;
    let mut weights = Vec::with_capacity(nv);
    for i in 0..nv { let o = p + i * 16; weights.push([rd_f32(o), rd_f32(o + 4), rd_f32(o + 8), rd_f32(o + 12)]); }
    p += nv * 16;
    let mut indices = Vec::with_capacity(ni);
    for i in 0..ni { indices.push(rd_u32(p + i * 4)); }
    Ok(Smsh { positions, normals, uvs, joints, weights, indices })
}

/// Read a whitespace `.skel` file: one bone per line
/// `parent name tx ty tz rx ry rz rw sx sy sz [invbind m0..m15 (row-major)]`.
pub fn read_skel(text: &str) -> Vec<Bone> {
    let mut out = Vec::new();
    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let f: Vec<&str> = line.split_whitespace().collect();
        if f.len() < 12 {
            continue;
        }
        let p = |i: usize| f[i].parse::<f32>().unwrap_or(0.0);
        let inv_bind = if f.len() >= 28 {
            let mut m = [0.0f32; 16];
            for (k, slot) in m.iter_mut().enumerate() {
                *slot = p(12 + k);
            }
            Some(m)
        } else {
            None
        };
        out.push(Bone {
            parent: f[0].parse().unwrap_or(-1),
            name: f[1].to_string(),
            t: [p(2), p(3), p(4)],
            r: [p(5), p(6), p(7), p(8)],
            s: [p(9), p(10), p(11)],
            inv_bind,
        });
    }
    out
}
