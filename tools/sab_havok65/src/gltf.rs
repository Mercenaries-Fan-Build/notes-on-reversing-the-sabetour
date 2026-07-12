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
        let bv = self.buffer_views.len();
        self.buffer_views
            .push(format!(r#"{{"buffer":0,"byteOffset":{off},"byteLength":{len}}}"#));
        let mms = match mm {
            Some((a, b)) => format!(r#","min":{a},"max":{b}"#),
            None => String::new(),
        };
        let idx = self.accessors.len();
        self.accessors.push(format!(
            r#"{{"bufferView":{bv},"componentType":{F32},"count":{count},"type":"{kind}"{mms}}}"#
        ));
        idx
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
        out.push(Bone {
            parent: f[0].parse().unwrap_or(-1),
            name: f[1].to_string(),
            t: [p(2), p(3), p(4)],
            r: [p(5), p(6), p(7), p(8)],
            s: [p(9), p(10), p(11)],
        });
    }
    out
}
