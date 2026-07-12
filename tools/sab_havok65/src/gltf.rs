//! Minimal, dependency-free glTF 2.0 (.glb) exporter for decoded spline clips.
//!
//! Emits one animated node per transform track, each driven by the decoded
//! per-frame local hkQsTransform (translation / rotation / scale) as a LINEAR
//! animation. No coordinate conversion: Havok and glTF are both right-handed,
//! +Y up, metres, quaternion (x,y,z,w) — so values export verbatim.
//!
//! v1 limitation (documented): the bones are emitted FLAT (all under one root),
//! because the parent hierarchy + bind pose live in the character MESH skeleton,
//! not the animation pack. A viewer will show every bone animating in its own
//! local frame (a moving "joint rig"), which proves the decode. A properly
//! NESTED, skinned rig needs the MSHA/MESH skeleton reader (phase 2) — then the
//! same per-track TRS channels attach to the real hierarchy with no change here.

use crate::SplineAnim;

const F32: u32 = 5126; // GL FLOAT
const AB: u32 = 34962; // ARRAY_BUFFER (unused target; kept for clarity)

fn push_f32(buf: &mut Vec<u8>, v: f32) {
    buf.extend_from_slice(&v.to_le_bytes());
}

/// Append `n`-component vectors (from `it`) to `bin`, 4-byte aligned, returning
/// (byteOffset, byteLength).
fn region<I: Iterator<Item = f32>>(bin: &mut Vec<u8>, it: I) -> (usize, usize) {
    while bin.len() % 4 != 0 {
        bin.push(0);
    }
    let start = bin.len();
    for v in it {
        push_f32(bin, v);
    }
    (start, bin.len() - start)
}

/// Build the .glb bytes for one decoded clip. `names` optionally supplies a
/// per-track label (e.g. a bone-hash string); otherwise nodes are `track_{i}`.
pub fn export_glb(anim: &SplineAnim, blob: &[u8], names: Option<&[String]>) -> Vec<u8> {
    let frames = anim.sample(blob);
    let n_frames = frames.len().max(1);
    let n_tracks = anim.num_transform_tracks;
    let fd = if anim.frame_duration.is_finite() && anim.frame_duration > 0.0 {
        anim.frame_duration
    } else {
        1.0 / 30.0
    };

    let mut bin: Vec<u8> = Vec::new();
    let mut accessors = String::new();
    let mut buffer_views = String::new();
    let mut n_acc = 0usize;

    // Helper to register a bufferView + accessor, returns accessor index.
    let add_accessor =
        |bin_off: usize, byte_len: usize, count: usize, kind: &str, minmax: Option<(String, String)>,
         buffer_views: &mut String, accessors: &mut String, n_acc: &mut usize| -> usize {
            if !buffer_views.is_empty() {
                buffer_views.push(',');
            }
            buffer_views.push_str(&format!(
                r#"{{"buffer":0,"byteOffset":{bin_off},"byteLength":{byte_len}}}"#
            ));
            let bv = *n_acc; // one bufferView per accessor -> same index
            if !accessors.is_empty() {
                accessors.push(',');
            }
            let mm = match minmax {
                Some((mn, mx)) => format!(r#","min":{mn},"max":{mx}"#),
                None => String::new(),
            };
            accessors.push_str(&format!(
                r#"{{"bufferView":{bv},"componentType":{F32},"count":{count},"type":"{kind}"{mm}}}"#
            ));
            let idx = *n_acc;
            *n_acc += 1;
            idx
        };

    // Shared time (input) accessor — required min/max.
    let (t_off, t_len) = region(&mut bin, (0..n_frames).map(|f| f as f32 * fd));
    let last_t = (n_frames.saturating_sub(1)) as f32 * fd;
    let times_acc = add_accessor(
        t_off,
        t_len,
        n_frames,
        "SCALAR",
        Some((format!("[{:.6}]", 0.0), format!("[{:.6}]", last_t))),
        &mut buffer_views,
        &mut accessors,
        &mut n_acc,
    );

    // Per-track T/R/S output accessors + samplers + channels + nodes.
    let mut samplers = String::new();
    let mut channels = String::new();
    let mut nodes = String::new();
    let mut child_ids = String::new();

    for t in 0..n_tracks {
        // gather this track's per-frame T (vec3), R (vec4), S (vec3)
        let (to, tl) = region(
            &mut bin,
            frames.iter().flat_map(|fr| {
                let q = &fr[t];
                [q.t[0], q.t[1], q.t[2]].into_iter()
            }),
        );
        let (ro, rl) = region(
            &mut bin,
            frames.iter().flat_map(|fr| {
                let q = &fr[t];
                [q.r[0], q.r[1], q.r[2], q.r[3]].into_iter()
            }),
        );
        let (so, sl) = region(
            &mut bin,
            frames.iter().flat_map(|fr| {
                let q = &fr[t];
                [q.s[0], q.s[1], q.s[2]].into_iter()
            }),
        );
        let a_t = add_accessor(to, tl, n_frames, "VEC3", None, &mut buffer_views, &mut accessors, &mut n_acc);
        let a_r = add_accessor(ro, rl, n_frames, "VEC4", None, &mut buffer_views, &mut accessors, &mut n_acc);
        let a_s = add_accessor(so, sl, n_frames, "VEC3", None, &mut buffer_views, &mut accessors, &mut n_acc);

        let node_id = t + 1; // node 0 is the root
        let s_base = t * 3;
        if !samplers.is_empty() {
            samplers.push(',');
            channels.push(',');
        }
        samplers.push_str(&format!(
            r#"{{"input":{times_acc},"interpolation":"LINEAR","output":{a_t}}},{{"input":{times_acc},"interpolation":"LINEAR","output":{a_r}}},{{"input":{times_acc},"interpolation":"LINEAR","output":{a_s}}}"#
        ));
        channels.push_str(&format!(
            r#"{{"sampler":{s},"target":{{"node":{node_id},"path":"translation"}}}},{{"sampler":{sr},"target":{{"node":{node_id},"path":"rotation"}}}},{{"sampler":{ss},"target":{{"node":{node_id},"path":"scale"}}}}"#,
            s = s_base, sr = s_base + 1, ss = s_base + 2
        ));

        // node rest transform = frame-0 local TRS (so the static pose is sensible)
        let f0 = &frames[0][t];
        let label = names
            .and_then(|ns| ns.get(t).cloned())
            .unwrap_or_else(|| format!("track_{t}"));
        if !nodes.is_empty() {
            nodes.push(',');
            child_ids.push(',');
        }
        nodes.push_str(&format!(
            r#"{{"name":"{label}","translation":[{tx:.6},{ty:.6},{tz:.6}],"rotation":[{rx:.6},{ry:.6},{rz:.6},{rw:.6}],"scale":[{sx:.6},{sy:.6},{sz:.6}]}}"#,
            tx = f0.t[0], ty = f0.t[1], tz = f0.t[2],
            rx = f0.r[0], ry = f0.r[1], rz = f0.r[2], rw = f0.r[3],
            sx = f0.s[0], sy = f0.s[1], sz = f0.s[2],
        ));
        child_ids.push_str(&node_id.to_string());
    }

    // Root node (index 0) parents every track node.
    let root = format!(r#"{{"name":"clip","children":[{child_ids}]}}"#);
    let all_nodes = if nodes.is_empty() {
        root
    } else {
        format!("{root},{nodes}")
    };

    let json = format!(
        concat!(
            r#"{{"asset":{{"version":"2.0","generator":"sab_havok65"}},"#,
            r#""scene":0,"scenes":[{{"nodes":[0]}}],"#,
            r#""nodes":[{nodes}],"#,
            r#""animations":[{{"name":"clip","samplers":[{samplers}],"channels":[{channels}]}}],"#,
            r#""buffers":[{{"byteLength":{binlen}}}],"#,
            r#""bufferViews":[{bvs}],"#,
            r#""accessors":[{accs}]}}"#
        ),
        nodes = all_nodes,
        samplers = samplers,
        channels = channels,
        binlen = bin.len(),
        bvs = buffer_views,
        accs = accessors,
    );

    let _ = AB; // silence unused-const if not referenced elsewhere
    pack_glb(json.as_bytes(), &bin)
}

/// Assemble a binary glTF container (header + JSON chunk + BIN chunk).
fn pack_glb(json: &[u8], bin: &[u8]) -> Vec<u8> {
    let mut json_chunk = json.to_vec();
    while json_chunk.len() % 4 != 0 {
        json_chunk.push(b' ');
    }
    let mut bin_chunk = bin.to_vec();
    while bin_chunk.len() % 4 != 0 {
        bin_chunk.push(0);
    }
    let total = 12 + 8 + json_chunk.len() + 8 + bin_chunk.len();
    let mut out = Vec::with_capacity(total);
    out.extend_from_slice(&0x4654_6C67u32.to_le_bytes()); // 'glTF'
    out.extend_from_slice(&2u32.to_le_bytes()); // version
    out.extend_from_slice(&(total as u32).to_le_bytes());
    // JSON chunk
    out.extend_from_slice(&(json_chunk.len() as u32).to_le_bytes());
    out.extend_from_slice(&0x4E4F_534Au32.to_le_bytes()); // 'JSON'
    out.extend_from_slice(&json_chunk);
    // BIN chunk
    out.extend_from_slice(&(bin_chunk.len() as u32).to_le_bytes());
    out.extend_from_slice(&0x004E_4942u32.to_le_bytes()); // 'BIN\0'
    out.extend_from_slice(&bin_chunk);
    out
}
