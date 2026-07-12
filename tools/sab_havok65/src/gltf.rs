//! Minimal, dependency-free glTF 2.0 (.glb) exporter for decoded spline clips.
//!
//! No coordinate conversion: Havok and glTF are both right-handed, +Y up, metres,
//! quaternion (x,y,z,w) — so decoded transforms export verbatim.
//!
//! Two modes:
//!   * [`export_glb`]        — FLAT: one node per transform track under a single
//!     root, each driven by its local TRS. Proves the decode with no skeleton.
//!   * [`export_glb_rigged`] — NESTED: nodes parented per a supplied skeleton,
//!     each bone's rest = its bind pose, animation channel i bound to bone i
//!     (Saboteur clips are authored track-order == skeleton bone-order). This is
//!     the real posed preview.

use crate::SplineAnim;

const F32: u32 = 5126; // GL FLOAT

/// One skeleton bone (rest/bind pose, parent link). See the `.skel` reader.
pub struct Bone {
    pub parent: i32, // -1 for a root
    pub name: String,
    pub t: [f32; 3],
    pub r: [f32; 4], // xyzw
    pub s: [f32; 3],
    pub inv_bind: Option<[f32; 16]>, // row-major inverse bind matrix (for skinning)
}

/// Accumulates the .glb binary buffer + accessors/bufferViews.
struct GlbBuilder {
    bin: Vec<u8>,
    accessors: Vec<String>,
    buffer_views: Vec<String>,
}
impl GlbBuilder {
    fn new() -> Self {
        GlbBuilder { bin: Vec::new(), accessors: Vec::new(), buffer_views: Vec::new() }
    }
    fn region<I: Iterator<Item = f32>>(&mut self, it: I) -> (usize, usize) {
        while self.bin.len() % 4 != 0 {
            self.bin.push(0);
        }
        let start = self.bin.len();
        for v in it {
            self.bin.extend_from_slice(&v.to_le_bytes());
        }
        (start, self.bin.len() - start)
    }
    fn accessor(&mut self, off: usize, len: usize, count: usize, kind: &str, mm: Option<(String, String)>) -> usize {
        self.accessor_ct(off, len, count, F32, kind, mm)
    }
    fn accessor_ct(&mut self, off: usize, len: usize, count: usize, comp: u32, kind: &str, mm: Option<(String, String)>) -> usize {
        let bv = self.buffer_views.len();
        self.buffer_views
            .push(format!(r#"{{"buffer":0,"byteOffset":{off},"byteLength":{len}}}"#));
        let mms = match mm {
            Some((a, b)) => format!(r#","min":{a},"max":{b}"#),
            None => String::new(),
        };
        let idx = self.accessors.len();
        self.accessors.push(format!(
            r#"{{"bufferView":{bv},"componentType":{comp},"count":{count},"type":"{kind}"{mms}}}"#
        ));
        idx
    }
    fn region_bytes(&mut self, bytes: &[u8]) -> (usize, usize) {
        while self.bin.len() % 4 != 0 {
            self.bin.push(0);
        }
        let start = self.bin.len();
        self.bin.extend_from_slice(bytes);
        (start, bytes.len())
    }
    /// VEC4 of u16 (JOINTS_0). componentType 5123 = UNSIGNED_SHORT.
    fn joints_u16(&mut self, quads: &[[u16; 4]]) -> usize {
        let mut b = Vec::with_capacity(quads.len() * 8);
        for q in quads {
            for &c in q {
                b.extend_from_slice(&c.to_le_bytes());
            }
        }
        let (o, l) = self.region_bytes(&b);
        self.accessor_ct(o, l, quads.len(), 5123, "VEC4", None)
    }
    /// SCALAR of u32 (indices). componentType 5125 = UNSIGNED_INT.
    fn indices_u32(&mut self, idx: &[u32]) -> usize {
        let mut b = Vec::with_capacity(idx.len() * 4);
        for &i in idx {
            b.extend_from_slice(&i.to_le_bytes());
        }
        let (o, l) = self.region_bytes(&b);
        self.accessor_ct(o, l, idx.len(), 5125, "SCALAR", None)
    }
    /// A shared time (input) accessor with the required min/max.
    fn times(&mut self, n: usize, fd: f32) -> usize {
        let (o, l) = self.region((0..n).map(|f| f as f32 * fd));
        let last = (n.saturating_sub(1)) as f32 * fd;
        self.accessor(o, l, n, "SCALAR", Some((format!("[{:.6}]", 0.0), format!("[{:.6}]", last))))
    }
    fn vecn(&mut self, vals: impl Iterator<Item = f32>, count: usize, kind: &str) -> usize {
        let (o, l) = self.region(vals);
        self.accessor(o, l, count, kind, None)
    }
}

/// Per-track T/R/S sampler+channel emission shared by flat and rigged modes.
/// Appends to `samplers`/`channels`; returns the 3 accessor indices unused
/// (they are wired internally). `node_id` is the glTF node the channels target.
fn emit_track_anim(
    b: &mut GlbBuilder, frames: &[Vec<crate::QsTransform>], t: usize, n: usize,
    times_acc: usize, node_id: usize, samplers: &mut Vec<String>, channels: &mut Vec<String>,
) {
    let a_t = b.vecn(frames.iter().flat_map(|fr| fr[t].t[..3].iter().copied()), n, "VEC3");
    let a_r = b.vecn(frames.iter().flat_map(|fr| fr[t].r.iter().copied()), n, "VEC4");
    let a_s = b.vecn(frames.iter().flat_map(|fr| fr[t].s[..3].iter().copied()), n, "VEC3");
    let s0 = samplers.len();
    for out in [a_t, a_r, a_s] {
        samplers.push(format!(
            r#"{{"input":{times_acc},"interpolation":"LINEAR","output":{out}}}"#
        ));
    }
    for (k, path) in ["translation", "rotation", "scale"].iter().enumerate() {
        channels.push(format!(
            r#"{{"sampler":{},"target":{{"node":{node_id},"path":"{path}"}}}}"#,
            s0 + k
        ));
    }
}

fn frame_dur(anim: &SplineAnim) -> f32 {
    if anim.frame_duration.is_finite() && anim.frame_duration > 0.0 {
        anim.frame_duration
    } else {
        1.0 / 30.0
    }
}

/// FLAT export: bones under one root, no hierarchy.
pub fn export_glb(anim: &SplineAnim, blob: &[u8], names: Option<&[String]>) -> Vec<u8> {
    let frames = anim.sample(blob);
    let n = frames.len().max(1);
    let nt = anim.num_transform_tracks;
    let fd = frame_dur(anim);

    let mut b = GlbBuilder::new();
    let times_acc = b.times(n, fd);
    let mut samplers = Vec::new();
    let mut channels = Vec::new();
    let mut nodes = Vec::new();
    let mut children = Vec::new();

    for t in 0..nt {
        emit_track_anim(&mut b, &frames, t, n, times_acc, t + 1, &mut samplers, &mut channels);
        let f0 = &frames[0][t];
        let label = names.and_then(|ns| ns.get(t).cloned()).unwrap_or_else(|| format!("track_{t}"));
        nodes.push(node_json(&label, [f0.t[0], f0.t[1], f0.t[2]], f0.r, [f0.s[0], f0.s[1], f0.s[2]], None));
        children.push((t + 1).to_string());
    }
    let root = format!(r#"{{"name":"clip","children":[{}]}}"#, children.join(","));
    let all_nodes = std::iter::once(root).chain(nodes).collect::<Vec<_>>().join(",");
    finish(&mut b, &all_nodes, &samplers, &channels, None)
}

/// RIGGED export: nodes nested per `skel`; animation bound track -> bone.
///
/// `track_to_bone`: for each animation track, the skeleton bone index it drives
/// (`< 0` = unbound, skipped). Empty = positional fallback (track i -> bone i).
/// This is the AP0L `ANIM` bone list (biped clips store per-track bone indices).
pub fn export_glb_rigged(anim: &SplineAnim, blob: &[u8], skel: &[Bone], track_to_bone: &[i32]) -> Vec<u8> {
    let frames = anim.sample(blob);
    let n = frames.len().max(1);
    let nt = anim.num_transform_tracks;
    let fd = frame_dur(anim);
    let nb = skel.len();

    let mut b = GlbBuilder::new();
    let times_acc = b.times(n, fd);
    let mut samplers = Vec::new();
    let mut channels = Vec::new();

    // child lists from parent links
    let mut kids: Vec<Vec<usize>> = vec![Vec::new(); nb];
    let mut roots: Vec<usize> = Vec::new();
    for (i, bone) in skel.iter().enumerate() {
        if bone.parent >= 0 && (bone.parent as usize) < nb {
            kids[bone.parent as usize].push(i);
        } else {
            roots.push(i);
        }
    }

    // one node per bone (nested at bind pose)
    let mut nodes = Vec::with_capacity(nb);
    for (i, bone) in skel.iter().enumerate() {
        let ch = if kids[i].is_empty() {
            None
        } else {
            Some(kids[i].iter().map(|k| k.to_string()).collect::<Vec<_>>().join(","))
        };
        nodes.push(node_json(&bone.name, bone.t, bone.r, bone.s, ch));
    }

    // bind each track to its skeleton bone node
    for t in 0..nt {
        let node = if track_to_bone.is_empty() {
            t as i32 // positional fallback
        } else if t < track_to_bone.len() {
            track_to_bone[t]
        } else {
            -1
        };
        if node < 0 || (node as usize) >= nb {
            continue; // unbound track (0xFFFFFFFF) or out of range
        }
        emit_track_anim(&mut b, &frames, t, n, times_acc, node as usize, &mut samplers, &mut channels);
    }

    let all_nodes = nodes.join(",");
    let scene_roots = roots.iter().map(|r| r.to_string()).collect::<Vec<_>>().join(",");
    finish(&mut b, &all_nodes, &samplers, &channels, Some(&scene_roots))
}

/// Static bind-pose skeleton (no animation) — nested nodes at their rest pose.
/// Use to visually confirm an extracted skeleton is a valid rig.
pub fn export_skeleton_glb(skel: &[Bone]) -> Vec<u8> {
    let nb = skel.len();
    let mut kids: Vec<Vec<usize>> = vec![Vec::new(); nb];
    let mut roots: Vec<usize> = Vec::new();
    for (i, bone) in skel.iter().enumerate() {
        if bone.parent >= 0 && (bone.parent as usize) < nb {
            kids[bone.parent as usize].push(i);
        } else {
            roots.push(i);
        }
    }
    let mut nodes = Vec::with_capacity(nb);
    for (i, bone) in skel.iter().enumerate() {
        let ch = if kids[i].is_empty() {
            None
        } else {
            Some(kids[i].iter().map(|k| k.to_string()).collect::<Vec<_>>().join(","))
        };
        nodes.push(node_json(&bone.name, bone.t, bone.r, bone.s, ch));
    }
    let mut b = GlbBuilder::new();
    let scene_roots = roots.iter().map(|r| r.to_string()).collect::<Vec<_>>().join(",");
    finish(&mut b, &nodes.join(","), &[], &[], Some(&scene_roots))
}

fn node_json(name: &str, t: [f32; 3], r: [f32; 4], s: [f32; 3], children: Option<String>) -> String {
    let ch = match children {
        Some(c) => format!(r#","children":[{c}]"#),
        None => String::new(),
    };
    let esc = name.replace('\\', "_").replace('"', "_");
    format!(
        r#"{{"name":"{esc}","translation":[{:.6},{:.6},{:.6}],"rotation":[{:.6},{:.6},{:.6},{:.6}],"scale":[{:.6},{:.6},{:.6}]{ch}}}"#,
        t[0], t[1], t[2], r[0], r[1], r[2], r[3], s[0], s[1], s[2]
    )
}

fn finish(b: &mut GlbBuilder, nodes: &str, samplers: &[String], channels: &[String], scene_nodes: Option<&str>) -> Vec<u8> {
    let scene = scene_nodes.unwrap_or("0");
    // animation + buffer sections are optional (skeleton-only export has neither)
    let anim = if samplers.is_empty() {
        String::new()
    } else {
        format!(
            r#""animations":[{{"name":"clip","samplers":[{}],"channels":[{}]}}],"#,
            samplers.join(","), channels.join(",")
        )
    };
    let buffers = if b.bin.is_empty() {
        String::new()
    } else {
        format!(
            r#""buffers":[{{"byteLength":{}}}],"bufferViews":[{}],"accessors":[{}],"#,
            b.bin.len(), b.buffer_views.join(","), b.accessors.join(",")
        )
    };
    let json = format!(
        concat!(
            r#"{{"asset":{{"version":"2.0","generator":"sab_havok65"}},"#,
            r#""scene":0,"scenes":[{{"nodes":[{scene}]}}],"#,
            r#""nodes":[{nodes}],{anim}{buffers}"#,
            r#""_note":"generated by sab_havok65"}}"#
        ),
        scene = scene, nodes = nodes, anim = anim, buffers = buffers,
    );
    pack_glb(json.as_bytes(), &b.bin)
}

/// Assemble a binary glTF container (header + JSON chunk + BIN chunk).
fn pack_glb(json: &[u8], bin: &[u8]) -> Vec<u8> {
    let mut jc = json.to_vec();
    while jc.len() % 4 != 0 {
        jc.push(b' ');
    }
    let mut bc = bin.to_vec();
    while bc.len() % 4 != 0 {
        bc.push(0);
    }
    let total = 12 + 8 + jc.len() + 8 + bc.len();
    let mut out = Vec::with_capacity(total);
    out.extend_from_slice(&0x4654_6C67u32.to_le_bytes()); // 'glTF'
    out.extend_from_slice(&2u32.to_le_bytes());
    out.extend_from_slice(&(total as u32).to_le_bytes());
    out.extend_from_slice(&(jc.len() as u32).to_le_bytes());
    out.extend_from_slice(&0x4E4F_534Au32.to_le_bytes()); // 'JSON'
    out.extend_from_slice(&jc);
    out.extend_from_slice(&(bc.len() as u32).to_le_bytes());
    out.extend_from_slice(&0x004E_4942u32.to_le_bytes()); // 'BIN\0'
    out.extend_from_slice(&bc);
    out
}

/// Decoded SMSH geometry (from tools/sab_mesh).
pub struct Smsh {
    pub positions: Vec<[f32; 3]>,
    pub normals: Vec<[f32; 3]>,
    pub uvs: Vec<[f32; 2]>,
    pub joints: Vec<[u16; 4]>,  // GLOBAL skeleton bone indices
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

/// FULL PREVIEW: skinned mesh + skeleton + animation, all in one glTF.
/// Bone node = bone index; skin.joints = [0..nb); JOINTS_0 carry global bone
/// indices (== skin joint indices). Animation binds track -> bone via track_to_bone.
pub fn export_preview(anim: &SplineAnim, blob: &[u8], skel: &[Bone], track_to_bone: &[i32], mesh: &Smsh) -> Vec<u8> {
    let frames = anim.sample(blob);
    let n = frames.len().max(1);
    let nt = anim.num_transform_tracks;
    let fd = frame_dur(anim);
    let nb = skel.len();

    let mut b = GlbBuilder::new();
    let times_acc = b.times(n, fd);
    let mut samplers = Vec::new();
    let mut channels = Vec::new();

    // --- animation channels: track -> bone node ---
    for t in 0..nt {
        let node = if track_to_bone.is_empty() { t as i32 }
                   else if t < track_to_bone.len() { track_to_bone[t] } else { -1 };
        if node < 0 || (node as usize) >= nb { continue; }
        emit_track_anim(&mut b, &frames, t, n, times_acc, node as usize, &mut samplers, &mut channels);
    }

    // --- bone nodes (nested at bind pose) ---
    let mut kids: Vec<Vec<usize>> = vec![Vec::new(); nb];
    let mut roots: Vec<usize> = Vec::new();
    for (i, bone) in skel.iter().enumerate() {
        if bone.parent >= 0 && (bone.parent as usize) < nb { kids[bone.parent as usize].push(i); }
        else { roots.push(i); }
    }
    let mut nodes: Vec<String> = Vec::with_capacity(nb + 1);
    for (i, bone) in skel.iter().enumerate() {
        let ch = if kids[i].is_empty() { None }
                 else { Some(kids[i].iter().map(|k| k.to_string()).collect::<Vec<_>>().join(",")) };
        nodes.push(node_json(&bone.name, bone.t, bone.r, bone.s, ch));
    }
    let mesh_node = nb; // the skinned mesh node
    nodes.push(format!(r#"{{"name":"mesh","mesh":0,"skin":0}}"#));

    // --- mesh vertex accessors ---
    let mut pmin = [f32::MAX; 3]; let mut pmax = [f32::MIN; 3];
    for p in &mesh.positions { for k in 0..3 { pmin[k] = pmin[k].min(p[k]); pmax[k] = pmax[k].max(p[k]); } }
    let (pos_off, pos_len) = b.region(mesh.positions.iter().flat_map(|p| p.iter().copied()));
    let pos_acc = b.accessor(
        pos_off, pos_len, mesh.positions.len(), "VEC3",
        Some((format!("[{:.6},{:.6},{:.6}]", pmin[0], pmin[1], pmin[2]),
              format!("[{:.6},{:.6},{:.6}]", pmax[0], pmax[1], pmax[2]))),
    );
    let nrm_acc = b.vecn(mesh.normals.iter().flat_map(|p| p.iter().copied()), mesh.normals.len(), "VEC3");
    let uv_acc = b.vecn(mesh.uvs.iter().flat_map(|p| p.iter().copied()), mesh.uvs.len(), "VEC2");
    let jnt_acc = b.joints_u16(&mesh.joints);
    let wgt_acc = b.vecn(mesh.weights.iter().flat_map(|p| p.iter().copied()), mesh.weights.len(), "VEC4");
    let idx_acc = b.indices_u32(&mesh.indices);

    // --- inverse-bind matrices (row-major skel -> column-major glTF) ---
    let mut ibm: Vec<f32> = Vec::with_capacity(nb * 16);
    for bone in skel {
        let rm = bone.inv_bind.unwrap_or([
            1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.,
        ]);
        for c in 0..4 { for r in 0..4 { ibm.push(rm[r * 4 + c]); } } // transpose -> column-major
    }
    let ibm_acc = b.vecn(ibm.into_iter(), nb, "MAT4");
    let skin_joints = (0..nb).map(|j| j.to_string()).collect::<Vec<_>>().join(",");

    // --- assemble JSON ---
    let anim_json = if samplers.is_empty() { String::new() } else {
        format!(r#""animations":[{{"name":"clip","samplers":[{}],"channels":[{}]}}],"#,
                samplers.join(","), channels.join(","))
    };
    let scene_roots = roots.iter().map(|r| r.to_string())
        .chain(std::iter::once(mesh_node.to_string())).collect::<Vec<_>>().join(",");
    let json = format!(
        concat!(
            r#"{{"asset":{{"version":"2.0","generator":"sab_havok65"}},"#,
            r#""scene":0,"scenes":[{{"nodes":[{scene}]}}],"#,
            r#""nodes":[{nodes}],{anim}"#,
            r#""meshes":[{{"primitives":[{{"attributes":{{"POSITION":{pos},"NORMAL":{nrm},"TEXCOORD_0":{uv},"JOINTS_0":{jnt},"WEIGHTS_0":{wgt}}},"indices":{idx}}}]}}],"#,
            r#""skins":[{{"joints":[{sj}],"inverseBindMatrices":{ibm}}}],"#,
            r#""buffers":[{{"byteLength":{binlen}}}],"bufferViews":[{bvs}],"accessors":[{accs}]}}"#
        ),
        scene = scene_roots, nodes = nodes.join(","), anim = anim_json,
        pos = pos_acc, nrm = nrm_acc, uv = uv_acc, jnt = jnt_acc, wgt = wgt_acc, idx = idx_acc,
        sj = skin_joints, ibm = ibm_acc,
        binlen = b.bin.len(), bvs = b.buffer_views.join(","), accs = b.accessors.join(","),
    );
    pack_glb(json.as_bytes(), &b.bin)
}

/// Read a whitespace `.skel` file: one bone per line
/// `parent name tx ty tz rx ry rz rw sx sy sz` (name may not contain spaces).
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
