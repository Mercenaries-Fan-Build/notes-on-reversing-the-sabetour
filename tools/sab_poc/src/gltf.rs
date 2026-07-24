//! Mattias glTF ingest (geometry + skin) and the bone hash-remap onto Sean's rig.
//!
//! Stage 2 of the Mattias port. glTF is JSON (`model.gltf`) + a binary buffer (`model.bin`). We pull
//! per-primitive POSITION/NORMAL/TEXCOORD_0/JOINTS_0/WEIGHTS_0 + indices, and the skin's joint list.
//! Bone identity is a `pandemic_hash` shared with Sean, so the retarget is a hash join: each Mattias
//! joint maps to a Sean bone by hash, folding unmatched (finger/face detail) up to its nearest
//! hash-matched ancestor. See docs/mattias_port_plan.md + memory `mattias-sean-bone-hash-retarget`.

#![allow(dead_code)]

use std::path::Path;

use serde_json::Value;

use crate::pack::pandemic_hash;
use crate::Flags;

/// One primitive's geometry (glTF space): tightly-parsed CPU arrays.
pub struct GPrim {
    pub positions: Vec<[f32; 3]>,
    pub normals: Vec<[f32; 3]>,
    pub uvs: Vec<[f32; 2]>,
    pub joints: Vec<[u16; 4]>, // local skin-joint indices (0..num joints)
    pub weights: Vec<[f32; 4]>,
    pub indices: Vec<u32>,
    pub material: i64,
    pub skinned: bool,
    /// For an UNSKINNED (rigid-attachment) primitive: the skin-joint it hangs off (via node hierarchy).
    pub attach_joint: Option<usize>,
}

/// The whole Mattias source: primitives + the skin's joints (with name-hash + parent-in-skin).
pub struct MattiasMesh {
    pub prims: Vec<GPrim>,
    pub joint_hashes: Vec<u32>,        // per skin-joint
    pub joint_parent: Vec<Option<usize>>, // parent skin-joint index, if the parent node is also a joint
}

fn comp_size(ct: i64) -> usize {
    match ct {
        5120 | 5121 => 1,
        5122 | 5123 => 2,
        5125 | 5126 => 4,
        _ => 0,
    }
}
fn type_ncomp(t: &str) -> usize {
    match t {
        "SCALAR" => 1,
        "VEC2" => 2,
        "VEC3" => 3,
        "VEC4" => 4,
        "MAT4" => 16,
        _ => 0,
    }
}

struct Doc {
    j: Value,
    bin: Vec<u8>,
}

// ---- minimal column-major 4x4 for glTF node world transforms (rigid-attachment placement) ----
type M4 = [f32; 16];
fn m_id() -> M4 {
    [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
}
fn m_mul(a: &M4, b: &M4) -> M4 {
    let mut c = [0f32; 16];
    for col in 0..4 {
        for row in 0..4 {
            let mut s = 0.0;
            for k in 0..4 {
                s += a[k * 4 + row] * b[col * 4 + k];
            }
            c[col * 4 + row] = s;
        }
    }
    c
}
fn node_local(n: &Value) -> M4 {
    if let Some(m) = n["matrix"].as_array() {
        let mut o = [0f32; 16];
        for (i, v) in m.iter().enumerate().take(16) {
            o[i] = v.as_f64().unwrap_or(0.0) as f32;
        }
        return o;
    }
    let t = n["translation"].as_array().map(|a| [a[0].as_f64().unwrap() as f32, a[1].as_f64().unwrap() as f32, a[2].as_f64().unwrap() as f32]).unwrap_or([0.0; 3]);
    let r = n["rotation"].as_array().map(|a| [a[0].as_f64().unwrap() as f32, a[1].as_f64().unwrap() as f32, a[2].as_f64().unwrap() as f32, a[3].as_f64().unwrap() as f32]).unwrap_or([0.0, 0.0, 0.0, 1.0]);
    let s = n["scale"].as_array().map(|a| [a[0].as_f64().unwrap() as f32, a[1].as_f64().unwrap() as f32, a[2].as_f64().unwrap() as f32]).unwrap_or([1.0; 3]);
    let (x, y, z, w) = (r[0], r[1], r[2], r[3]);
    // column-major T * R * S
    [
        (1.0 - 2.0 * (y * y + z * z)) * s[0], (2.0 * (x * y + z * w)) * s[0], (2.0 * (x * z - y * w)) * s[0], 0.0,
        (2.0 * (x * y - z * w)) * s[1], (1.0 - 2.0 * (x * x + z * z)) * s[1], (2.0 * (y * z + x * w)) * s[1], 0.0,
        (2.0 * (x * z + y * w)) * s[2], (2.0 * (y * z - x * w)) * s[2], (1.0 - 2.0 * (x * x + y * y)) * s[2], 0.0,
        t[0], t[1], t[2], 1.0,
    ]
}
fn m_point(m: &M4, p: [f32; 3]) -> [f32; 3] {
    [
        m[0] * p[0] + m[4] * p[1] + m[8] * p[2] + m[12],
        m[1] * p[0] + m[5] * p[1] + m[9] * p[2] + m[13],
        m[2] * p[0] + m[6] * p[1] + m[10] * p[2] + m[14],
    ]
}
fn m_vec(m: &M4, v: [f32; 3]) -> [f32; 3] {
    let o = [m[0] * v[0] + m[4] * v[1] + m[8] * v[2], m[1] * v[0] + m[5] * v[1] + m[9] * v[2], m[2] * v[0] + m[6] * v[1] + m[10] * v[2]];
    let l = (o[0] * o[0] + o[1] * o[1] + o[2] * o[2]).sqrt();
    if l > 1e-6 {
        [o[0] / l, o[1] / l, o[2] / l]
    } else {
        o
    }
}

impl Doc {
    fn accessor(&self, idx: i64) -> &Value {
        &self.j["accessors"][idx as usize]
    }
    /// (base offset into bin, stride bytes, componentType, ncomp, count, normalized)
    fn acc_layout(&self, idx: i64) -> (usize, usize, i64, usize, usize, bool) {
        let a = self.accessor(idx);
        let bv = &self.j["bufferViews"][a["bufferView"].as_i64().unwrap() as usize];
        let ct = a["componentType"].as_i64().unwrap();
        let ncomp = type_ncomp(a["type"].as_str().unwrap());
        let count = a["count"].as_i64().unwrap() as usize;
        let base = bv["byteOffset"].as_i64().unwrap_or(0) as usize + a["byteOffset"].as_i64().unwrap_or(0) as usize;
        let stride = bv["byteStride"].as_i64().map(|s| s as usize).unwrap_or(ncomp * comp_size(ct));
        let normalized = a["normalized"].as_bool().unwrap_or(false);
        (base, stride, ct, ncomp, count, normalized)
    }

    fn read_f32(&self, idx: i64) -> Vec<Vec<f32>> {
        let (base, stride, ct, ncomp, count, norm) = self.acc_layout(idx);
        let cs = comp_size(ct);
        let mut out = Vec::with_capacity(count);
        for e in 0..count {
            let mut row = Vec::with_capacity(ncomp);
            for c in 0..ncomp {
                let o = base + e * stride + c * cs;
                let v = match ct {
                    5126 => f32::from_le_bytes([self.bin[o], self.bin[o + 1], self.bin[o + 2], self.bin[o + 3]]),
                    5121 => {
                        let b = self.bin[o] as f32;
                        if norm { b / 255.0 } else { b }
                    }
                    5123 => {
                        let b = u16::from_le_bytes([self.bin[o], self.bin[o + 1]]) as f32;
                        if norm { b / 65535.0 } else { b }
                    }
                    _ => 0.0,
                };
                row.push(v);
            }
            out.push(row);
        }
        out
    }

    fn read_u32(&self, idx: i64) -> Vec<Vec<u32>> {
        let (base, stride, ct, ncomp, count, _) = self.acc_layout(idx);
        let cs = comp_size(ct);
        let mut out = Vec::with_capacity(count);
        for e in 0..count {
            let mut row = Vec::with_capacity(ncomp);
            for c in 0..ncomp {
                let o = base + e * stride + c * cs;
                let v = match ct {
                    5121 => self.bin[o] as u32,
                    5123 => u16::from_le_bytes([self.bin[o], self.bin[o + 1]]) as u32,
                    5125 => u32::from_le_bytes([self.bin[o], self.bin[o + 1], self.bin[o + 2], self.bin[o + 3]]),
                    _ => 0,
                };
                row.push(v);
            }
            out.push(row);
        }
        out
    }
}

pub fn load(gltf_path: &str) -> Result<MattiasMesh, String> {
    let text = std::fs::read_to_string(gltf_path).map_err(|e| format!("read {gltf_path}: {e}"))?;
    let j: Value = serde_json::from_str(&text).map_err(|e| format!("parse gltf json: {e}"))?;
    let dir = Path::new(gltf_path).parent().ok_or("gltf has no parent dir")?;
    let uri = j["buffers"][0]["uri"].as_str().ok_or("buffers[0].uri missing (need external .bin)")?;
    let bin = std::fs::read(dir.join(uri)).map_err(|e| format!("read buffer {uri}: {e}"))?;
    let doc = Doc { j, bin };

    // node maps (for rigid-attachment resolution): node->parent, mesh->node, node->skin-joint
    let nodes = doc.j["nodes"].as_array().ok_or("no nodes")?;
    let joints_nodes: Vec<usize> = doc.j["skins"][0]["joints"]
        .as_array()
        .ok_or("skin has no joints")?
        .iter()
        .map(|v| v.as_i64().unwrap() as usize)
        .collect();
    let node_to_joint: std::collections::HashMap<usize, usize> =
        joints_nodes.iter().enumerate().map(|(ji, &n)| (n, ji)).collect();
    let mut node_parent = vec![None; nodes.len()];
    let mut mesh_node: std::collections::HashMap<usize, usize> = std::collections::HashMap::new();
    for (ni, n) in nodes.iter().enumerate() {
        if let Some(ch) = n["children"].as_array() {
            for c in ch {
                node_parent[c.as_i64().unwrap() as usize] = Some(ni);
            }
        }
        if let Some(mi) = n["mesh"].as_i64() {
            mesh_node.entry(mi as usize).or_insert(ni);
        }
    }
    let attach_joint_of = |mesh_idx: usize| -> Option<usize> {
        let mut p = node_parent[*mesh_node.get(&mesh_idx)?];
        while let Some(pn) = p {
            if let Some(&ji) = node_to_joint.get(&pn) {
                return Some(ji);
            }
            p = node_parent[pn];
        }
        None
    };
    // world transform of a mesh node's chain (root -> node), for baking rigid-attachment placement
    let world_of = |mesh_idx: usize| -> M4 {
        let Some(&start) = mesh_node.get(&mesh_idx) else { return m_id() };
        let mut chain = Vec::new();
        let mut k = Some(start);
        while let Some(ni) = k {
            chain.push(ni);
            k = node_parent[ni];
        }
        let mut m = m_id();
        for &ni in chain.iter().rev() {
            m = m_mul(&m, &node_local(&nodes[ni]));
        }
        m
    };

    // primitives
    let mut prims = Vec::new();
    for (mesh_idx, m) in doc.j["meshes"].as_array().ok_or("no meshes")?.iter().enumerate() {
        for p in m["primitives"].as_array().ok_or("no primitives")? {
            let at = &p["attributes"];
            let skinned = at["JOINTS_0"].as_i64().is_some() && at["WEIGHTS_0"].as_i64().is_some();
            let attach_joint = if skinned { None } else { attach_joint_of(mesh_idx) };
            let a_pos = at["POSITION"].as_i64().ok_or("primitive without POSITION")?;
            let mut positions: Vec<[f32; 3]> = doc.read_f32(a_pos).iter().map(|r| [r[0], r[1], r[2]]).collect();
            let mut normals: Vec<[f32; 3]> = at["NORMAL"]
                .as_i64()
                .map(|a| doc.read_f32(a).iter().map(|r| [r[0], r[1], r[2]]).collect())
                .unwrap_or_else(|| vec![[0.0, 0.0, 1.0]; positions.len()]);
            // Rigid attachments are authored in bone-local space; bake the node-chain world transform so
            // they sit where the source places them (hip belt on the hip, etc.), then bind weight-1.
            if !skinned {
                let w = world_of(mesh_idx);
                for p in positions.iter_mut() {
                    *p = m_point(&w, *p);
                }
                for n in normals.iter_mut() {
                    *n = m_vec(&w, *n);
                }
            }
            let uvs: Vec<[f32; 2]> = at["TEXCOORD_0"]
                .as_i64()
                .map(|a| doc.read_f32(a).iter().map(|r| [r[0], r[1]]).collect())
                .unwrap_or_else(|| vec![[0.0, 0.0]; positions.len()]);
            let joints: Vec<[u16; 4]> = at["JOINTS_0"]
                .as_i64()
                .map(|a| doc.read_u32(a).iter().map(|r| [r[0] as u16, r[1] as u16, r[2] as u16, r[3] as u16]).collect())
                .unwrap_or_else(|| vec![[0; 4]; positions.len()]);
            let weights: Vec<[f32; 4]> = at["WEIGHTS_0"]
                .as_i64()
                .map(|a| doc.read_f32(a).iter().map(|r| [r[0], r[1], r[2], r[3]]).collect())
                .unwrap_or_else(|| vec![[0.0; 4]; positions.len()]);
            let indices: Vec<u32> = match p["indices"].as_i64() {
                Some(a) => doc.read_u32(a).iter().map(|r| r[0]).collect(),
                None => (0..positions.len() as u32).collect(),
            };
            prims.push(GPrim {
                positions,
                normals,
                uvs,
                joints,
                weights,
                indices,
                material: p["material"].as_i64().unwrap_or(-1),
                skinned,
                attach_joint,
            });
        }
    }

    // skin joints -> name hashes + in-skin parent
    let mut joint_hashes = Vec::with_capacity(joints_nodes.len());
    let mut joint_parent = Vec::with_capacity(joints_nodes.len());
    for &n in &joints_nodes {
        let name = nodes[n]["name"].as_str().unwrap_or("");
        joint_hashes.push(parse_hash(name).unwrap_or_else(|| pandemic_hash(name)));
        // nearest ancestor node that is itself a joint
        let mut p = node_parent[n];
        let mut pj = None;
        while let Some(pn) = p {
            if let Some(&ji) = node_to_joint.get(&pn) {
                pj = Some(ji);
                break;
            }
            p = node_parent[pn];
        }
        joint_parent.push(pj);
    }

    Ok(MattiasMesh { prims, joint_hashes, joint_parent })
}

/// A hex `0x........` embedded in a bone/joint name (the bone's stable hash).
fn parse_hash(name: &str) -> Option<u32> {
    let b = name.as_bytes();
    let mut i = 0;
    while i + 2 <= b.len() {
        if b[i] == b'0' && (b[i + 1] == b'x' || b[i + 1] == b'X') {
            let hex: String = name[i + 2..].chars().take(8).collect();
            if hex.len() == 8 {
                if let Ok(v) = u32::from_str_radix(&hex, 16) {
                    return Some(v);
                }
            }
        }
        i += 1;
    }
    None
}

/// Sean's skeleton as (hash, name) in bone-index order.
pub fn load_sean_skel(skel_path: &str) -> Result<Vec<(u32, String)>, String> {
    let text = std::fs::read_to_string(skel_path).map_err(|e| format!("read {skel_path}: {e}"))?;
    let mut out = Vec::new();
    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let f: Vec<&str> = line.split_whitespace().collect();
        if f.len() < 2 {
            continue;
        }
        let name = f[1].to_string();
        let hash = parse_hash(&name).unwrap_or_else(|| pandemic_hash(&name));
        out.push((hash, name));
    }
    Ok(out)
}

pub struct Remap {
    /// per Mattias joint: Some(sean_bone_index) or None (orphan — should never happen for Mattias/Sean)
    pub to_sean: Vec<Option<usize>>,
    pub direct: usize,
    pub folded: usize,
    pub orphan: usize,
}

/// Hash-join Mattias joints onto Sean bones; fold unmatched to the nearest matched ancestor.
pub fn build_remap(mm: &MattiasMesh, sean: &[(u32, String)]) -> Remap {
    use std::collections::HashMap;
    let sean_by_hash: HashMap<u32, usize> = sean.iter().enumerate().map(|(i, (h, _))| (*h, i)).collect();
    let direct_of = |ji: usize| sean_by_hash.get(&mm.joint_hashes[ji]).copied();
    let mut to_sean = vec![None; mm.joint_hashes.len()];
    let (mut direct, mut folded, mut orphan) = (0, 0, 0);
    for ji in 0..mm.joint_hashes.len() {
        if let Some(si) = direct_of(ji) {
            to_sean[ji] = Some(si);
            direct += 1;
            continue;
        }
        // fold up to nearest ancestor with a direct match
        let mut p = mm.joint_parent[ji];
        let mut hit = None;
        while let Some(pj) = p {
            if let Some(si) = direct_of(pj) {
                hit = Some(si);
                break;
            }
            p = mm.joint_parent[pj];
        }
        match hit {
            Some(si) => {
                to_sean[ji] = Some(si);
                folded += 1;
            }
            None => orphan += 1,
        }
    }
    Remap { to_sean, direct, folded, orphan }
}

/// Per glTF material: (diffuse, normal, spec) original texture hashes, parsed from the material name
/// `mat_d0x…_n0x…_s0x…`. Index = glTF material index (matches a prim's `material`). Also returns the
/// glTF directory (PNGs are `<dir>/textures/tex_0x<hash>.png`).
pub fn material_roles(gltf_path: &str) -> Result<(std::path::PathBuf, Vec<[Option<u32>; 3]>), String> {
    let text = std::fs::read_to_string(gltf_path).map_err(|e| format!("read {gltf_path}: {e}"))?;
    let j: Value = serde_json::from_str(&text).map_err(|e| e.to_string())?;
    let dir = std::path::Path::new(gltf_path).parent().ok_or("no dir")?.to_path_buf();
    let mut out = Vec::new();
    for m in j["materials"].as_array().cloned().unwrap_or_default() {
        let nm = m["name"].as_str().unwrap_or("");
        let grab = |tag: &str| -> Option<u32> {
            let p = nm.find(tag)?;
            let hex: String = nm[p + tag.len()..].chars().take(8).collect();
            u32::from_str_radix(&hex, 16).ok()
        };
        out.push([grab("_d0x"), grab("_n0x"), grab("_s0x")]);
    }
    Ok((dir, out))
}

// ============================================================================
// GLB source path (50 Cent port).
//
// Deliberately kept SEPARATE from `load()` above. That path is the shipped Mattias port and its
// original `model.gltf` + `textures/` input is no longer on disk, so it cannot be regression-tested;
// refactoring it to share code here would be an unverifiable change to working, shipped output. The
// duplicated primitive-extraction below is the price of that safety. Nothing in this section
// modifies the Mattias path.
//
// Two things differ structurally from the Mattias source (see memory `50cent-port-reset`):
//   * the buffer and images are EMBEDDED (GLB chunks), not external `.bin`/PNG-by-uri;
//   * the skeleton is a different lineage (Blood on the Sand rig), so bone identity is a semantic
//     NAME map, not a `pandemic_hash` join — see `build_remap_named`.
// ============================================================================

/// One primitive from a GLB source. `mesh_index`/`mesh_name` are retained because the 50 Cent
/// source splits cleanly into Body / Head / DeepEye, which drives the part split onto Sean's slots.
pub struct GlbPrim {
    pub positions: Vec<[f32; 3]>,
    pub normals: Vec<[f32; 3]>,
    pub uvs: Vec<[f32; 2]>,
    pub joints: Vec<[u16; 4]>,
    pub weights: Vec<[f32; 4]>,
    pub indices: Vec<u32>,
    pub material: i64,
    pub mesh_index: usize,
    pub mesh_name: String,
}

pub struct GlbMesh {
    pub prims: Vec<GlbPrim>,
    pub joint_names: Vec<String>,
    pub joint_parent: Vec<Option<usize>>,
    /// Per skin-joint inverse-bind matrix (column-major 4x4) exactly as authored in the GLB.
    /// `inverse(ibm)`'s translation is the bone's origin in MESH space — the source points for the
    /// scale/axis alignment fit. (The joint node hierarchy is in a different, ~100x-off space in
    /// this Sketchfab rip, so it must NOT be used for that.)
    pub ibms: Vec<[f32; 16]>,
    pub material_names: Vec<String>,
}

/// Parse a binary glTF container into JSON + BIN chunks.
fn glb_chunks(path: &str) -> Result<(Value, Vec<u8>), String> {
    let data = std::fs::read(path).map_err(|e| format!("read {path}: {e}"))?;
    if data.len() < 12 {
        return Err(format!("{path}: too short to be a GLB"));
    }
    let u32at = |o: usize| u32::from_le_bytes([data[o], data[o + 1], data[o + 2], data[o + 3]]);
    if u32at(0) != 0x4654_6C67 {
        return Err(format!("{path}: not a GLB (bad magic)"));
    }
    let total = (u32at(8) as usize).min(data.len());
    let (mut json, mut bin) = (None, Vec::new());
    let mut off = 12usize;
    while off + 8 <= total {
        let clen = u32at(off) as usize;
        let ctype = u32at(off + 4);
        off += 8;
        let end = off.checked_add(clen).ok_or("GLB chunk length overflow")?;
        if end > total {
            return Err(format!("{path}: GLB chunk overruns file"));
        }
        match ctype {
            0x4E4F_534A => json = Some(serde_json::from_slice(&data[off..end]).map_err(|e| format!("parse GLB JSON chunk: {e}"))?),
            0x004E_4942 => bin = data[off..end].to_vec(),
            _ => {}
        }
        off = end; // chunkLength already includes the 4-byte padding per spec
    }
    Ok((json.ok_or("GLB has no JSON chunk")?, bin))
}

pub fn load_glb(path: &str) -> Result<GlbMesh, String> {
    let (j, bin) = glb_chunks(path)?;
    let doc = Doc { j, bin };

    let nodes = doc.j["nodes"].as_array().ok_or("no nodes")?.clone();
    let joints_nodes: Vec<usize> = doc.j["skins"][0]["joints"]
        .as_array()
        .ok_or("skin has no joints")?
        .iter()
        .map(|v| v.as_i64().unwrap() as usize)
        .collect();
    let node_to_joint: std::collections::HashMap<usize, usize> =
        joints_nodes.iter().enumerate().map(|(ji, &n)| (n, ji)).collect();
    let mut node_parent = vec![None; nodes.len()];
    for (ni, n) in nodes.iter().enumerate() {
        if let Some(ch) = n["children"].as_array() {
            for c in ch {
                node_parent[c.as_i64().unwrap() as usize] = Some(ni);
            }
        }
    }

    // primitives
    let mut prims = Vec::new();
    for (mesh_idx, m) in doc.j["meshes"].as_array().ok_or("no meshes")?.iter().enumerate() {
        let mesh_name = m["name"].as_str().unwrap_or("").to_string();
        for p in m["primitives"].as_array().ok_or("no primitives")? {
            let at = &p["attributes"];
            let a_pos = at["POSITION"].as_i64().ok_or("primitive without POSITION")?;
            let positions: Vec<[f32; 3]> = doc.read_f32(a_pos).iter().map(|r| [r[0], r[1], r[2]]).collect();
            let normals: Vec<[f32; 3]> = at["NORMAL"]
                .as_i64()
                .map(|a| doc.read_f32(a).iter().map(|r| [r[0], r[1], r[2]]).collect())
                .unwrap_or_else(|| vec![[0.0, 0.0, 1.0]; positions.len()]);
            let uvs: Vec<[f32; 2]> = at["TEXCOORD_0"]
                .as_i64()
                .map(|a| doc.read_f32(a).iter().map(|r| [r[0], r[1]]).collect())
                .unwrap_or_else(|| vec![[0.0, 0.0]; positions.len()]);
            let joints: Vec<[u16; 4]> = at["JOINTS_0"]
                .as_i64()
                .map(|a| doc.read_u32(a).iter().map(|r| [r[0] as u16, r[1] as u16, r[2] as u16, r[3] as u16]).collect())
                .unwrap_or_else(|| vec![[0; 4]; positions.len()]);
            let weights: Vec<[f32; 4]> = at["WEIGHTS_0"]
                .as_i64()
                .map(|a| doc.read_f32(a).iter().map(|r| [r[0], r[1], r[2], r[3]]).collect())
                .unwrap_or_else(|| vec![[0.0; 4]; positions.len()]);
            let indices: Vec<u32> = match p["indices"].as_i64() {
                Some(a) => doc.read_u32(a).iter().map(|r| r[0]).collect(),
                None => (0..positions.len() as u32).collect(),
            };
            prims.push(GlbPrim {
                positions,
                normals,
                uvs,
                joints,
                weights,
                indices,
                material: p["material"].as_i64().unwrap_or(-1),
                mesh_index: mesh_idx,
                mesh_name: mesh_name.clone(),
            });
        }
    }

    // skin joints: names + in-skin parent
    let mut joint_names = Vec::with_capacity(joints_nodes.len());
    let mut joint_parent = Vec::with_capacity(joints_nodes.len());
    for &n in &joints_nodes {
        joint_names.push(nodes[n]["name"].as_str().unwrap_or("").to_string());
        let mut p = node_parent[n];
        let mut pj = None;
        while let Some(pn) = p {
            if let Some(&ji) = node_to_joint.get(&pn) {
                pj = Some(ji);
                break;
            }
            p = node_parent[pn];
        }
        joint_parent.push(pj);
    }

    // inverse-bind matrices
    let ibms: Vec<[f32; 16]> = match doc.j["skins"][0]["inverseBindMatrices"].as_i64() {
        Some(a) => doc
            .read_f32(a)
            .iter()
            .map(|r| {
                let mut m = [0f32; 16];
                m.copy_from_slice(&r[..16]);
                m
            })
            .collect(),
        None => return Err("skin has no inverseBindMatrices — cannot align to Sean's bind pose".into()),
    };
    if ibms.len() != joint_names.len() {
        return Err(format!("IBM count {} != joint count {}", ibms.len(), joint_names.len()));
    }

    let material_names = doc.j["materials"]
        .as_array()
        .cloned()
        .unwrap_or_default()
        .iter()
        .map(|m| m["name"].as_str().unwrap_or("").to_string())
        .collect();

    Ok(GlbMesh { prims, joint_names, joint_parent, ibms, material_names })
}

/// Sean's per-bone parent index, in the same order as `load_sean_skel`. Both skip the `#` header, so
/// the indices of the two agree (and agree with `mesh::bone_world_positions`).
pub fn load_sean_parents(skel_path: &str) -> Result<Vec<i32>, String> {
    let text = std::fs::read_to_string(skel_path).map_err(|e| format!("read {skel_path}: {e}"))?;
    let mut out = Vec::new();
    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let f: Vec<&str> = line.split_whitespace().collect();
        if f.len() < 2 {
            continue;
        }
        out.push(f[0].parse::<i32>().unwrap_or(-1));
    }
    Ok(out)
}

/// The 50 Cent (Blood on the Sand) rig -> Sean bone-name map.
///
/// This replaces the `pandemic_hash` join used for Mattias: the two rigs share no hash lineage, but
/// both are ordinary bipeds, so identity transfers by name. Anything not named here (muscle/twist
/// helpers, face micro-bones, camera bones) deliberately returns None and is folded to its nearest
/// mapped ancestor by `build_remap_named` — a visible, reported fidelity loss, never a silent pin.
///
/// `l_foot`/`l_toe`/`r_foot`/`r_toe` are passed in because Sean's feet are hash-named
/// (`bone_5_0x1226F58D` etc.) and are resolved from his hierarchy rather than hard-coded.
fn map_50cent_bone(n: &str, feet: &[Option<String>; 4]) -> Option<String> {
    let l = if n.ends_with("_L") || n.contains("_L_") {
        true
    } else if n.ends_with("_R") || n.contains("_R_") {
        false
    } else {
        // sideless bones below never consult `l`; default keeps the match arms total
        true
    };
    let lr = |a: &str, b: &str| Some((if l { a } else { b }).to_string());

    if n == "_rootJoint" {
        return Some("Bone_Root".into());
    }
    // fingers: ThumbBone0N_L / IndexFinger0N_L / MiddleFinger0N_L / RingFinger0N_L / littleFinger0N_L
    let fam = if n.starts_with("ThumbBone") {
        Some("Thumb")
    } else if n.starts_with("IndexFinger") {
        Some("Index")
    } else if n.starts_with("MiddleFinger") {
        Some("Middle")
    } else if n.starts_with("RingFinger") {
        Some("Ring")
    } else if n.starts_with("littleFinger") {
        Some("Pinky")
    } else {
        None
    };
    if let Some(fam) = fam {
        // first digit run in the name is the joint ordinal ("01" -> 1)
        let digits: String = n.chars().skip_while(|c| !c.is_ascii_digit()).take_while(|c| c.is_ascii_digit()).collect();
        if let Some(d) = digits.chars().last() {
            return Some(format!("Bone_{}{}{}", if l { "L" } else { "R" }, fam, d));
        }
    }
    // spine chain: 50 Cent has 4 spine bones, Sean has 2 usable — collapse deterministically
    if n.starts_with("C1_Pelvis") {
        return Some("Bone_Hips".into());
    }
    if n.starts_with("C1_Spine3") || n.starts_with("C1_Spine2") || n.starts_with("C1_RibCage") {
        return Some("Bone_Chest".into());
    }
    if n.starts_with("C1_Spine") {
        return Some("Bone_Spine1".into());
    }
    if n.starts_with("C1_Neck") {
        return Some("Bone_Neck".into());
    }
    if n.starts_with("C1_Head") {
        return Some("Bone_Head".into());
    }
    if n.starts_with("C1_Clavicle") {
        return lr("bone_lshoulder", "bone_rshoulder");
    }
    if n.starts_with("C1_UpperArm") {
        return lr("Bone_LBicep", "Bone_RBicep");
    }
    if n.starts_with("C1_Forearm") {
        return lr("Bone_LForearm", "Bone_RForearm");
    }
    if n.starts_with("C1_Hand") {
        return lr("Bone_LHand", "Bone_RHand");
    }
    if n.starts_with("C1_Thigh") {
        return lr("Bone_LThigh", "Bone_RThigh");
    }
    if n.starts_with("C1_Calf") {
        return lr("Bone_LShin", "Bone_RShin");
    }
    if n.starts_with("C1_Foot") {
        return if l { feet[0].clone() } else { feet[2].clone() };
    }
    if n.starts_with("C1_Toe") {
        return if l { feet[1].clone() } else { feet[3].clone() };
    }
    None
}

pub struct NamedRemap {
    /// per 50 Cent joint -> Sean bone index (direct or folded)
    pub to_sean: Vec<Option<usize>>,
    /// only the DIRECT (semantically named) hits — the correspondences the alignment fit may use
    pub direct_only: Vec<Option<usize>>,
    pub n_direct: usize,
    pub n_folded: usize,
    pub n_orphan: usize,
    /// (50 Cent bone, Sean bone it was folded onto)
    pub folded: Vec<(String, String)>,
}

/// Name-map 50 Cent joints onto Sean bones, folding anything unmapped to its nearest mapped ancestor.
pub fn build_remap_named(g: &GlbMesh, sean: &[(u32, String)], sean_parents: &[i32]) -> NamedRemap {
    use std::collections::HashMap;
    let by_name: HashMap<&str, usize> = sean.iter().enumerate().map(|(i, (_, n))| (n.as_str(), i)).collect();

    // Sean's feet/toes are hash-named; resolve from his hierarchy (first child of each shin, then its child).
    let first_child = |p: usize| -> Option<usize> { (0..sean.len()).find(|&i| sean_parents.get(i).copied().unwrap_or(-1) == p as i32) };
    let chain = |shin: &str| -> (Option<String>, Option<String>) {
        let Some(&si) = by_name.get(shin) else { return (None, None) };
        let Some(f) = first_child(si) else { return (None, None) };
        (Some(sean[f].1.clone()), first_child(f).map(|t| sean[t].1.clone()))
    };
    let (lf, lt) = chain("Bone_LShin");
    let (rf, rt) = chain("Bone_RShin");
    let feet = [lf, lt, rf, rt];

    let direct_only: Vec<Option<usize>> = g
        .joint_names
        .iter()
        .map(|n| map_50cent_bone(n, &feet).and_then(|t| by_name.get(t.as_str()).copied()))
        .collect();

    let mut to_sean = vec![None; g.joint_names.len()];
    let (mut n_direct, mut n_folded, mut n_orphan) = (0, 0, 0);
    let mut folded = Vec::new();
    for ji in 0..g.joint_names.len() {
        if let Some(si) = direct_only[ji] {
            to_sean[ji] = Some(si);
            n_direct += 1;
            continue;
        }
        let mut p = g.joint_parent[ji];
        let mut hit = None;
        while let Some(pj) = p {
            if let Some(si) = direct_only[pj] {
                hit = Some(si);
                break;
            }
            p = g.joint_parent[pj];
        }
        match hit {
            Some(si) => {
                to_sean[ji] = Some(si);
                n_folded += 1;
                folded.push((g.joint_names[ji].clone(), sean[si].1.clone()));
            }
            None => n_orphan += 1,
        }
    }
    NamedRemap { to_sean, direct_only, n_direct, n_folded, n_orphan, folded }
}

/// Raw embedded image blobs from a GLB, in glTF image order.
pub fn glb_images(path: &str) -> Result<Vec<Vec<u8>>, String> {
    let (j, bin) = glb_chunks(path)?;
    let mut out = Vec::new();
    for im in j["images"].as_array().cloned().unwrap_or_default() {
        let bvi = im["bufferView"].as_i64().ok_or("GLB image has no bufferView (external image uri unsupported)")? as usize;
        let bv = &j["bufferViews"][bvi];
        let o = bv["byteOffset"].as_i64().unwrap_or(0) as usize;
        let l = bv["byteLength"].as_i64().unwrap_or(0) as usize;
        if o + l > bin.len() {
            return Err("GLB image bufferView overruns BIN chunk".into());
        }
        out.push(bin[o..o + l].to_vec());
    }
    Ok(out)
}

/// Per material: `[diffuse, specular, normal]` IMAGE indices — the `[d,s,n]` order Sean's opaque body
/// material lays its texture slice out in.
///
/// Specular is read from `KHR_materials_specular`, NOT the PBR block: this Sketchfab export leaves the
/// real 256x256 spec maps stranded in that extension while `pbrMetallicRoughness` carries only
/// baseColor, so a naive PBR-only read would silently drop spec and mis-order the slice.
pub fn glb_material_textures(path: &str) -> Result<Vec<[Option<usize>; 3]>, String> {
    let (j, _bin) = glb_chunks(path)?;
    let img_of = |ti: i64| -> Option<usize> { j["textures"][ti as usize]["source"].as_i64().map(|v| v as usize) };
    let mut out = Vec::new();
    for m in j["materials"].as_array().cloned().unwrap_or_default() {
        let d = m["pbrMetallicRoughness"]["baseColorTexture"]["index"].as_i64().and_then(&img_of);
        let s = m["extensions"]["KHR_materials_specular"]["specularTexture"]["index"].as_i64().and_then(&img_of);
        let n = m["normalTexture"]["index"].as_i64().and_then(&img_of);
        out.push([d, s, n]);
    }
    Ok(out)
}

pub fn info(f: &Flags) -> Result<(), String> {
    println!("[1] loading Mattias glTF: {}", f.gltf);
    let mm = load(&f.gltf)?;
    let nverts: usize = mm.prims.iter().map(|p| p.positions.len()).sum();
    let ntris: usize = mm.prims.iter().map(|p| p.indices.len() / 3).sum();
    let mut mats: Vec<i64> = mm.prims.iter().map(|p| p.material).collect();
    mats.sort_unstable();
    mats.dedup();
    let mut bb_min = [f32::MAX; 3];
    let mut bb_max = [f32::MIN; 3];
    let mut wsum_bad = 0usize;
    for p in &mm.prims {
        for v in &p.positions {
            for k in 0..3 {
                bb_min[k] = bb_min[k].min(v[k]);
                bb_max[k] = bb_max[k].max(v[k]);
            }
        }
        for w in &p.weights {
            let s: f32 = w.iter().sum();
            if (s - 1.0).abs() > 0.05 && s > 0.0 {
                wsum_bad += 1;
            }
        }
    }
    println!(
        "    {} primitives, {} verts, {} tris, {} materials, {} skin joints",
        mm.prims.len(),
        nverts,
        ntris,
        mats.len(),
        mm.joint_hashes.len()
    );
    println!(
        "    bbox  X[{:.2},{:.2}]  Y[{:.2},{:.2}]  Z[{:.2},{:.2}]   ({} verts with non-unit weight sum)",
        bb_min[0], bb_max[0], bb_min[1], bb_max[1], bb_min[2], bb_max[2], wsum_bad
    );

    println!("[2] bone hash-remap onto Sean's rig: {}", f.skel);
    let sean = load_sean_skel(&f.skel)?;
    println!("    Sean skeleton: {} bones", sean.len());
    let r = build_remap(&mm, &sean);
    println!(
        "    remap: {} direct, {} folded-to-ancestor, {} orphan   (of {} Mattias joints)",
        r.direct,
        r.folded,
        r.orphan,
        mm.joint_hashes.len()
    );
    // show a few core-bone matches by Sean name
    let sean_by_hash: std::collections::HashMap<u32, &str> = sean.iter().map(|(h, n)| (*h, n.as_str())).collect();
    let mut shown = 0;
    for ji in 0..mm.joint_hashes.len() {
        if let Some(si) = r.to_sean[ji] {
            let nm = sean[si].1.as_str();
            if !nm.starts_with("bone_") && shown < 10 {
                println!("      Mattias joint {:3} -> Sean '{}'", ji, nm);
                shown += 1;
            }
        }
    }
    let _ = sean_by_hash;

    if r.orphan == 0 {
        println!("\nPASS — every Mattias joint maps to a Sean bone (no orphans). Retarget is a clean hash join.");
    } else {
        return Err(format!("{} orphan joints have no Sean target — retarget would drop weights", r.orphan));
    }
    Ok(())
}
