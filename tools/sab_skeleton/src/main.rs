//! sab_skeleton — extract a character SKELETON (bone hierarchy + bind pose) from
//! The Saboteur (2009) MESH assets, so a decoded Havok animation can be rigged onto it.
//!
//! Pipeline (all empirically validated against `Global/Dynamic0.megapack`, PC/GOG build):
//!
//!   .megapack (magic "00PM", 64-bit index)                                  [container]
//!     -> SBLA sub-pack ("ALBS")                                             [uncompressed container]
//!         -> MSHA wrapper ("AHSM"): 20-byte header + 256-byte ASCII name    [uncompressed]
//!             -> MESH body (zlib, header 0x78 0x01) -> flat MESH + skeleton  [compressed]
//!
//! The MSHA header (magic, sizes, and the 256-byte asset name) is stored *uncompressed*
//! inside the SBLA sub-pack, so this tool locates meshes by scanning the raw megapack for
//! the "AHSM" magic and reading the ASCII name directly — no external string dictionary or
//! `global.map` navigation required. Character meshes are named `CH_AL_<Name>_<part>`.
//!
//! Layout confirmed from PredatorCZ/SaboteurToolset (`mesh/mesh_to_gltf.cpp`,
//! `include/meshpack.hpp`) and cross-checked byte-for-byte against real assets. The engine
//! codename is "WildStar" (WS* classes; e.g. WSSkeletonBone @ decomp VA 0x0132b22c).
//!
//! name_hash == boneName0 == pandemic_hash(bone name). Verified: 0xCBC1EB51="GlobalSRT" (root),
//! 0x24C5009C="Bone_Hips", 0x4C7733ED="Bone_Chest", 0x705C4508="Bone_Head", etc., and these
//! exact hashes are the keys the animation system uses (they appear in Animations.pack's ANIM
//! bone list, e.g. offset ~1807).

use std::io::Read;

// ---------------------------------------------------------------------------
// Little-endian scalar readers
// ---------------------------------------------------------------------------
fn u32(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn i16(b: &[u8], o: usize) -> i16 { i16::from_le_bytes([b[o], b[o + 1]]) }
fn u64(b: &[u8], o: usize) -> u64 {
    u64::from_le_bytes([b[o], b[o+1], b[o+2], b[o+3], b[o+4], b[o+5], b[o+6], b[o+7]])
}
fn f32a(b: &[u8], o: usize) -> f32 { f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }

/// pandemic_hash (FNV-1a variant, Pandemic Studios). Case-folded by `|0x20` on the raw byte.
/// Verified `pandemic_hash("ANY") == 0xED057225`.
fn pandemic_hash(s: &str) -> u32 {
    let mut h: u32 = 0x811C9DC5;
    for c in s.bytes() {
        h = (h ^ ((c | 0x20) as u32)).wrapping_mul(0x0100_0193);
    }
    (h ^ 0x2A).wrapping_mul(0x0100_0193)
}

// ---------------------------------------------------------------------------
// 4x4 matrix math. Storage note: the on-disk `localTMS` is 16 f32 row-major with the
// translation in the LAST ROW (indices 12,13,14). We work in column-vector math convention,
// so we transpose on load: `Mat4.m[r][c] = raw[c*4 + r]` (translation lands in column 3).
// World bind = parent_world * local. inv_bind = inverse(world).
// (Verified: transpose+column-3 translation composes to a standing humanoid; and the
//  independent `transforms` TRS array reproduces these matrices to 1.6e-7.)
// ---------------------------------------------------------------------------
#[derive(Clone, Copy)]
struct Mat4 { m: [[f32; 4]; 4] }

impl Mat4 {
    fn identity() -> Mat4 {
        let mut m = [[0.0f32; 4]; 4];
        for i in 0..4 { m[i][i] = 1.0; }
        Mat4 { m }
    }
    /// Load from 16 raw f32 (row-major, translation in last row) -> transpose to column-vector math.
    fn from_raw_transposed(raw: &[f32; 16]) -> Mat4 {
        let mut m = [[0.0f32; 4]; 4];
        for r in 0..4 { for c in 0..4 { m[r][c] = raw[c * 4 + r]; } }
        Mat4 { m }
    }
    fn mul(&self, o: &Mat4) -> Mat4 {
        let mut m = [[0.0f32; 4]; 4];
        for r in 0..4 { for c in 0..4 {
            let mut s = 0.0f32;
            for k in 0..4 { s += self.m[r][k] * o.m[k][c]; }
            m[r][c] = s;
        }}
        Mat4 { m }
    }
    fn flat_rowmajor(&self) -> [f32; 16] {
        let mut o = [0.0f32; 16];
        for r in 0..4 { for c in 0..4 { o[r * 4 + c] = self.m[r][c]; } }
        o
    }
    fn translation(&self) -> [f32; 3] { [self.m[0][3], self.m[1][3], self.m[2][3]] }
    /// Decompose into translation / rotation(quaternion xyzw) / scale (assumes no shear).
    fn decompose(&self) -> ([f32; 3], [f32; 4], [f32; 3]) {
        let t = self.translation();
        let col = |c: usize| [self.m[0][c], self.m[1][c], self.m[2][c]];
        let len = |v: [f32; 3]| (v[0]*v[0] + v[1]*v[1] + v[2]*v[2]).sqrt();
        let (mut sx, mut sy, mut sz) = (len(col(0)), len(col(1)), len(col(2)));
        // preserve handedness
        if self.det3() < 0.0 { sx = -sx; }
        if sx == 0.0 { sx = 1e-8; } if sy == 0.0 { sy = 1e-8; } if sz == 0.0 { sz = 1e-8; }
        let r = [
            [self.m[0][0]/sx, self.m[0][1]/sy, self.m[0][2]/sz],
            [self.m[1][0]/sx, self.m[1][1]/sy, self.m[1][2]/sz],
            [self.m[2][0]/sx, self.m[2][1]/sy, self.m[2][2]/sz],
        ];
        let q = quat_from_rot(&r);
        (t, q, [sx, sy, sz])
    }
    fn det3(&self) -> f32 {
        let m = &self.m;
        m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])
        - m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])
        + m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0])
    }
    /// General 4x4 inverse (Cramer's rule).
    fn inverse(&self) -> Mat4 {
        let a: [f32; 16] = self.flat_rowmajor();
        let mut inv = [0.0f32; 16];
        inv[0]  =  a[5]*a[10]*a[15]-a[5]*a[11]*a[14]-a[9]*a[6]*a[15]+a[9]*a[7]*a[14]+a[13]*a[6]*a[11]-a[13]*a[7]*a[10];
        inv[4]  = -a[4]*a[10]*a[15]+a[4]*a[11]*a[14]+a[8]*a[6]*a[15]-a[8]*a[7]*a[14]-a[12]*a[6]*a[11]+a[12]*a[7]*a[10];
        inv[8]  =  a[4]*a[9]*a[15]-a[4]*a[11]*a[13]-a[8]*a[5]*a[15]+a[8]*a[7]*a[13]+a[12]*a[5]*a[11]-a[12]*a[7]*a[9];
        inv[12] = -a[4]*a[9]*a[14]+a[4]*a[10]*a[13]+a[8]*a[5]*a[14]-a[8]*a[6]*a[13]-a[12]*a[5]*a[10]+a[12]*a[6]*a[9];
        inv[1]  = -a[1]*a[10]*a[15]+a[1]*a[11]*a[14]+a[9]*a[2]*a[15]-a[9]*a[3]*a[14]-a[13]*a[2]*a[11]+a[13]*a[3]*a[10];
        inv[5]  =  a[0]*a[10]*a[15]-a[0]*a[11]*a[14]-a[8]*a[2]*a[15]+a[8]*a[3]*a[14]+a[12]*a[2]*a[11]-a[12]*a[3]*a[10];
        inv[9]  = -a[0]*a[9]*a[15]+a[0]*a[11]*a[13]+a[8]*a[1]*a[15]-a[8]*a[3]*a[13]-a[12]*a[1]*a[11]+a[12]*a[3]*a[9];
        inv[13] =  a[0]*a[9]*a[14]-a[0]*a[10]*a[13]-a[8]*a[1]*a[14]+a[8]*a[2]*a[13]+a[12]*a[1]*a[10]-a[12]*a[2]*a[9];
        inv[2]  =  a[1]*a[6]*a[15]-a[1]*a[7]*a[14]-a[5]*a[2]*a[15]+a[5]*a[3]*a[14]+a[13]*a[2]*a[7]-a[13]*a[3]*a[6];
        inv[6]  = -a[0]*a[6]*a[15]+a[0]*a[7]*a[14]+a[4]*a[2]*a[15]-a[4]*a[3]*a[14]-a[12]*a[2]*a[7]+a[12]*a[3]*a[6];
        inv[10] =  a[0]*a[5]*a[15]-a[0]*a[7]*a[13]-a[4]*a[1]*a[15]+a[4]*a[3]*a[13]+a[12]*a[1]*a[7]-a[12]*a[3]*a[5];
        inv[14] = -a[0]*a[5]*a[14]+a[0]*a[6]*a[13]+a[4]*a[1]*a[14]-a[4]*a[2]*a[13]-a[12]*a[1]*a[6]+a[12]*a[2]*a[5];
        inv[3]  = -a[1]*a[6]*a[11]+a[1]*a[7]*a[10]+a[5]*a[2]*a[11]-a[5]*a[3]*a[10]-a[9]*a[2]*a[7]+a[9]*a[3]*a[6];
        inv[7]  =  a[0]*a[6]*a[11]-a[0]*a[7]*a[10]-a[4]*a[2]*a[11]+a[4]*a[3]*a[10]+a[8]*a[2]*a[7]-a[8]*a[3]*a[6];
        inv[11] = -a[0]*a[5]*a[11]+a[0]*a[7]*a[9]+a[4]*a[1]*a[11]-a[4]*a[3]*a[9]-a[8]*a[1]*a[7]+a[8]*a[3]*a[5];
        inv[15] =  a[0]*a[5]*a[10]-a[0]*a[6]*a[9]-a[4]*a[1]*a[10]+a[4]*a[2]*a[9]+a[8]*a[1]*a[6]-a[8]*a[2]*a[5];
        let mut det = a[0]*inv[0]+a[1]*inv[4]+a[2]*inv[8]+a[3]*inv[12];
        if det == 0.0 { det = 1e-12; }
        det = 1.0 / det;
        let mut m = [[0.0f32; 4]; 4];
        for r in 0..4 { for c in 0..4 { m[r][c] = inv[r * 4 + c] * det; } }
        Mat4 { m }
    }
}

fn quat_from_rot(r: &[[f32; 3]; 3]) -> [f32; 4] {
    let trace = r[0][0] + r[1][1] + r[2][2];
    let (x, y, z, w);
    if trace > 0.0 {
        let s = 0.5 / (trace + 1.0).sqrt();
        w = 0.25 / s; x = (r[2][1]-r[1][2])*s; y = (r[0][2]-r[2][0])*s; z = (r[1][0]-r[0][1])*s;
    } else if r[0][0] > r[1][1] && r[0][0] > r[2][2] {
        let s = 2.0 * (1.0 + r[0][0] - r[1][1] - r[2][2]).sqrt();
        w = (r[2][1]-r[1][2])/s; x = 0.25*s; y = (r[0][1]+r[1][0])/s; z = (r[0][2]+r[2][0])/s;
    } else if r[1][1] > r[2][2] {
        let s = 2.0 * (1.0 + r[1][1] - r[0][0] - r[2][2]).sqrt();
        w = (r[0][2]-r[2][0])/s; x = (r[0][1]+r[1][0])/s; y = 0.25*s; z = (r[1][2]+r[2][1])/s;
    } else {
        let s = 2.0 * (1.0 + r[2][2] - r[0][0] - r[1][1]).sqrt();
        w = (r[1][0]-r[0][1])/s; x = (r[0][2]+r[2][0])/s; y = (r[1][2]+r[2][1])/s; z = 0.25*s;
    }
    let n = (x*x + y*y + z*z + w*w).sqrt().max(1e-12);
    [x/n, y/n, z/n, w/n]
}

// ---------------------------------------------------------------------------
// Parsed structures
// ---------------------------------------------------------------------------
struct Bone {
    index: usize,
    name_hash: u32, // boneName0 = pandemic_hash(bone name); the key the anim system uses
    parent: i32,    // -1 for root
    local_t: [f32; 3],
    local_r: [f32; 4], // xyzw quaternion
    local_s: [f32; 3],
    world: Mat4,       // bind: parent_world * local
    inv_bind: Mat4,    // inverse(world)
}

struct MeshHit {
    name: String,
    file_off: usize,   // offset of "AHSM" in the megapack
    unc0: u32,
    comp0: u32,
    num_bones0: u32,
    body: Vec<u8>,     // decompressed MESH body
}

/// Parse one MSHA at `off` if valid; returns (name, comp0, unc0) header fields.
fn parse_msha_header(buf: &[u8], off: usize) -> Option<(String, u32, u32, u32, u32)> {
    if off + 276 > buf.len() { return None; }
    // MSHA: id(4) uncompressedSize0(4) uncompressedSize1(4) compressedSize0(4) compressedSize1(4) name[0x100]
    let u_unc0 = u32(buf, off + 4);
    let u_unc1 = u32(buf, off + 8);
    let u_c0 = u32(buf, off + 12);
    let u_c1 = u32(buf, off + 16);
    let name_bytes = &buf[off + 20..off + 276];
    let end = name_bytes.iter().position(|&b| b == 0).unwrap_or(0);
    if end == 0 { return None; }
    let nm = &name_bytes[..end];
    if !nm.iter().all(|&b| (0x20..0x7f).contains(&b)) { return None; }
    Some((String::from_utf8_lossy(nm).into_owned(), u_c0, u_unc0, u_c1, u_unc1))
}

fn zlib_inflate(data: &[u8], expected: usize) -> Option<Vec<u8>> {
    let mut d = flate2::read::ZlibDecoder::new(data);
    let mut out = Vec::with_capacity(expected);
    match d.read_to_end(&mut out) {
        Ok(_) => Some(out),
        Err(_) => None,
    }
}

/// numBones0 sits at a fixed offset (204) in the decompressed MESH body — see MESH::Read.
fn mesh_num_bones0(body: &[u8]) -> Option<u32> {
    if body.len() < 212 { return None; }
    Some(u32(body, 204))
}

/// Scan the whole megapack for MSHA ("AHSM") headers and decode any whose name matches
/// `name_filter` (substring) into a full MeshHit (with decompressed body). If `list_only`,
/// records every skinned candidate lightly (no body retained beyond header parse).
fn scan_meshes(buf: &[u8], name_filter: &str) -> Vec<MeshHit> {
    let magic = b"AHSM";
    let mut hits = Vec::new();
    let mut i = 0usize;
    while i + 276 <= buf.len() {
        if &buf[i..i + 4] == magic {
            if let Some((name, c0, unc0, _c1, _unc1)) = parse_msha_header(buf, i) {
                if c0 > 0 && unc0 > 0 && c0 as usize <= buf.len()
                    && (name_filter.is_empty() || name.contains(name_filter))
                {
                    let start = i + 276;
                    if start + c0 as usize <= buf.len() {
                        if let Some(body) = zlib_inflate(&buf[start..start + c0 as usize], unc0 as usize) {
                            if body.len() == unc0 as usize {
                                if let Some(nb0) = mesh_num_bones0(&body) {
                                    hits.push(MeshHit {
                                        name, file_off: i, unc0, comp0: c0,
                                        num_bones0: nb0, body,
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
        i += 1; // MSHA headers are byte-packed within the SBLA pack (not aligned)
    }
    hits
}

/// Parse the flat MESH skeleton from a decompressed body. Returns the bone list.
fn parse_skeleton(body: &[u8]) -> Result<Vec<Bone>, String> {
    // ---- MESH header (244 bytes) ----
    // 19*u32 null | BBOX_(Vector min 12 + Vector4 max 16 = 28) | 11*u32 null | name u32 |
    // 8*u32 null | unk0 u32 | 4*u32 null | numBones0 u32@204 | numBoneRemaps u32@208 |
    // null u32 | numStreams u16@216 numPrimitives u16@218 | 3*u32 null | numDrawCalls u32@232 | 2*u32 null
    let num_bones0 = u32(body, 204);
    if num_bones0 <= 1 { return Err(format!("mesh is not skinned (numBones0={num_bones0})")); }

    // ---- MESHSkeleton header @244 (11 u32) ----
    let mut p = 244usize;
    let num_unk_bones0 = u32(body, p); // count of trailing null8 pad after boneIds
    // p+4,p+8 = null
    let num_bones = u32(body, p + 12) as usize; // numBones2  == numBones0
    let num_unk_bones1 = u32(body, p + 16);     // if !=0, one trailing null16
    let num_bones3 = u32(body, p + 20) as usize;
    // p+24 = null
    let num_bones4 = u32(body, p + 28) as usize;
    // p+32,36,40 = null
    if num_bones != num_bones3 || num_bones != num_bones4 {
        return Err(format!("bone count mismatch: {num_bones}/{num_bones3}/{num_bones4}"));
    }
    p += 44;

    // ---- boneIds: numBones u8 ----
    let _bone_ids = &body[p..p + num_bones]; p += num_bones;
    // ---- numUnkBones0 * null8 ----
    p += num_unk_bones0 as usize;

    // ---- localTMS: numBones * Matrix44 (64 bytes each) ----
    let mut local_mats = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        let mut raw = [0.0f32; 16];
        for k in 0..16 { raw[k] = f32a(body, p + k * 4); }
        local_mats.push(Mat4::from_raw_transposed(&raw));
        p += 64;
    }

    // ---- bones: numBones * Bone (64 bytes) ----
    //   name0 u32@0 | 4*u32 null | name1 u32@20 | null u32@24 | unk0 u32@28 | bbox(8 f32)@32
    let mut name_hashes = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        name_hashes.push(u32(body, p)); // boneName0
        p += 64;
    }

    // ---- transforms: numBones * RTSValue (translation Vec4 + rotation Vec4 + scale Vec4 = 48) ----
    let mut trs = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        let t = [f32a(body, p),      f32a(body, p + 4),  f32a(body, p + 8)];   // + w @12 (unused)
        let r = [f32a(body, p + 16), f32a(body, p + 20), f32a(body, p + 24), f32a(body, p + 28)]; // xyzw
        let s = [f32a(body, p + 32), f32a(body, p + 36), f32a(body, p + 40)];  // + w @44 (unused)
        trs.push((t, r, s));
        p += 48;
    }

    // ---- parentIds: numBones * int16 ----
    let mut parents = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        parents.push(i16(body, p) as i32);
        p += 2;
    }
    // ---- numBones * null32, then optional null16 ----
    p += 4 * num_bones;
    if num_unk_bones1 != 0 { p += 2; }
    let _ = p; // remaining bytes are BoneRemaps/Streams/Primitives/DrawCalls (not needed)

    // ---- compose world (bind) matrices: world[i] = world[parent] * local[i] ----
    let mut world = vec![Mat4::identity(); num_bones];
    let mut done = vec![false; num_bones];
    let mut progress = true;
    while progress {
        progress = false;
        for i in 0..num_bones {
            if done[i] { continue; }
            let pp = parents[i];
            if pp < 0 {
                world[i] = local_mats[i]; done[i] = true; progress = true;
            } else if done[pp as usize] {
                world[i] = world[pp as usize].mul(&local_mats[i]); done[i] = true; progress = true;
            }
        }
    }
    if done.iter().any(|&d| !d) {
        return Err("bone hierarchy has a cycle or dangling parent".into());
    }

    let mut bones = Vec::with_capacity(num_bones);
    for i in 0..num_bones {
        let (t, r, s) = trs[i];
        bones.push(Bone {
            index: i,
            name_hash: name_hashes[i],
            parent: parents[i],
            local_t: t, local_r: r, local_s: s,
            world: world[i],
            inv_bind: world[i].inverse(),
        });
    }
    Ok(bones)
}

// ---------------------------------------------------------------------------
// Minimal built-in bone-name dictionary (pandemic_hash -> name) for a readable report.
// These are the canonical Saboteur biped bone names; full resolution needs the game's
// string dictionary, but this covers the major joints for validation.
// ---------------------------------------------------------------------------
fn known_bone_names() -> Vec<&'static str> {
    let mut v = vec![
        "GlobalSRT", "Bone_Attach_Root", "Bone_Root",
        "Bone_Hips", "Bone_Spine", "Bone_Spine1", "Bone_Spine2", "Bone_Chest",
        "Bone_Neck", "Bone_Neck1", "Bone_Head",
        "Bone_LThigh", "Bone_LShin", "Bone_LFoot", "Bone_LToe",
        "Bone_RThigh", "Bone_RShin", "Bone_RFoot", "Bone_RToe",
        "Bone_LClav", "Bone_LBicep", "Bone_LForearm", "Bone_LHand",
        "Bone_RClav", "Bone_RBicep", "Bone_RForearm", "Bone_RHand",
        "bone_attach_lhand", "bone_attach_rhand",
        "bone_cheek_left", "bone_cheek_right", "bone_jaw", "bone_tongue",
        "bone_eye_left", "bone_eye_right", "bone_eyelid_left", "bone_eyelid_right",
    ];
    // finger/thumb variants
    for side in ["L", "R"] {
        for f in ["Finger", "Thumb", "Index", "Middle", "Ring", "Pinky"] {
            for n in 0..4 {
                // leak a static string via Box (fine for a short-lived CLI)
                let s: &'static str = Box::leak(format!("Bone_{side}{f}{n}").into_boxed_str());
                v.push(s);
            }
        }
    }
    v
}

fn build_name_map() -> std::collections::HashMap<u32, &'static str> {
    let mut m = std::collections::HashMap::new();
    for n in known_bone_names() { m.entry(pandemic_hash(n)).or_insert(n); }
    m
}

// ---------------------------------------------------------------------------
// JSON emit (manual; no serde)
// ---------------------------------------------------------------------------
fn f(x: f32) -> String {
    if x == 0.0 { "0".into() } else { format!("{:.7}", x) }
}
fn arr3(a: [f32; 3]) -> String { format!("[{},{},{}]", f(a[0]), f(a[1]), f(a[2])) }
fn arr4(a: [f32; 4]) -> String { format!("[{},{},{},{}]", f(a[0]), f(a[1]), f(a[2]), f(a[3])) }
fn arr16(a: [f32; 16]) -> String {
    let parts: Vec<String> = a.iter().map(|&x| f(x)).collect();
    format!("[{}]", parts.join(","))
}

fn emit_json(
    source: &str, hit: &MeshHit, entry: Option<(u32, u32, u64, u32)>,
    bones: &[Bone], root_count: usize,
) -> String {
    let names = build_name_map();
    let mut s = String::new();
    s.push_str("{\n");
    s.push_str(&format!("  \"source\": {:?},\n", source));
    s.push_str(&format!("  \"mesh_name\": {:?},\n", hit.name));
    s.push_str(&format!("  \"msha_file_offset\": {},\n", hit.file_off));
    s.push_str(&format!("  \"mesh_body_compressed\": {}, \"mesh_body_uncompressed\": {},\n", hit.comp0, hit.unc0));
    if let Some((crc, index, off, size)) = entry {
        s.push_str(&format!(
            "  \"megapack_entry\": {{ \"crc\": \"0x{:08X}\", \"index\": {}, \"index_hash\": \"0x{:08X}\", \"offset\": {}, \"size\": {} }},\n",
            crc, index, index, off, size));
    }
    s.push_str(&format!("  \"num_bones0\": {},\n", hit.num_bones0));
    s.push_str(&format!("  \"root_count\": {},\n", root_count));
    s.push_str("  \"bone_naming\": \"name_hash = boneName0 = pandemic_hash(name); matches Animations.pack ANIM bone-track hashes\",\n");
    s.push_str("  \"matrix_convention\": \"world/inv_bind are 4x4 row-major, column-vector math (translation in column 3 = m[3],m[7],m[11]); world[i]=world[parent]*local[i]\",\n");
    s.push_str("  \"bones\": [\n");
    for (bi, b) in bones.iter().enumerate() {
        let resolved = names.get(&b.name_hash).copied();
        s.push_str("    {");
        s.push_str(&format!(" \"index\": {},", b.index));
        s.push_str(&format!(" \"name_hash\": {},", b.name_hash));
        s.push_str(&format!(" \"name_hash_hex\": \"0x{:08X}\",", b.name_hash));
        if let Some(n) = resolved { s.push_str(&format!(" \"name\": {:?},", n)); }
        s.push_str(&format!(" \"parent\": {},", b.parent));
        s.push_str(&format!(" \"local\": {{ \"t\": {}, \"r\": {}, \"s\": {} }},",
            arr3(b.local_t), arr4(b.local_r), arr3(b.local_s)));
        let (wt, wr, ws) = b.world.decompose();
        s.push_str(&format!(" \"world\": {{ \"t\": {}, \"r\": {}, \"s\": {}, \"m\": {} }},",
            arr3(wt), arr4(wr), arr3(ws), arr16(b.world.flat_rowmajor())));
        s.push_str(&format!(" \"inv_bind\": {{ \"m\": {} }}", arr16(b.inv_bind.flat_rowmajor())));
        s.push_str(" }");
        s.push_str(if bi + 1 < bones.len() { ",\n" } else { "\n" });
    }
    s.push_str("  ]\n}\n");
    s
}

// ---------------------------------------------------------------------------
// Megapack index (for reporting which container entry holds the chosen mesh)
// ---------------------------------------------------------------------------
struct Entry { crc: u32, index: u32, size: u32, offset: u64 }

fn read_megapack_index(buf: &[u8]) -> Result<Vec<Entry>, String> {
    if buf.len() < 8 || &buf[0..4] != b"00PM" {
        return Err(format!("not a megapack (magic {:02X?})", &buf[0..4.min(buf.len())]));
    }
    let count = u32(buf, 4) as usize;
    let mut v = Vec::with_capacity(count);
    let mut p = 8usize;
    for _ in 0..count {
        if p + 20 > buf.len() { break; }
        v.push(Entry { crc: u32(buf, p), index: u32(buf, p + 4), size: u32(buf, p + 8), offset: u64(buf, p + 12) });
        p += 20;
    }
    Ok(v)
}

fn containing_entry(entries: &[Entry], off: usize) -> Option<(u32, u32, u64, u32)> {
    for e in entries {
        let start = e.offset as usize;
        let end = start + e.size as usize;
        if (start..end).contains(&off) {
            return Some((e.crc, e.index, e.offset, e.size));
        }
    }
    None
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("usage: sab_skeleton <Dynamic0.megapack> [name_substr] [out.json]");
        eprintln!("       sab_skeleton <Dynamic0.megapack> --list");
        eprintln!("  default name_substr = \"CH_AL_SeanDevlin\"");
        std::process::exit(2);
    }
    let path = &args[1];
    let list_mode = args.iter().any(|a| a == "--list");
    let name_filter = if list_mode { "" }
        else { args.get(2).map(|s| s.as_str()).unwrap_or("CH_AL_SeanDevlin") };
    let out_path = args.get(3).cloned().unwrap_or_else(|| "skeleton.json".into());

    eprintln!("[*] reading {path} ...");
    let buf = std::fs::read(path).unwrap_or_else(|e| { eprintln!("read error: {e}"); std::process::exit(1); });
    eprintln!("[*] {} bytes", buf.len());

    let entries = read_megapack_index(&buf).unwrap_or_else(|e| { eprintln!("{e}"); Vec::new() });
    if !entries.is_empty() {
        eprintln!("[*] megapack index: {} entries (SBLA sub-packs)", entries.len());
    }

    if list_mode {
        // Light scan: enumerate CH_AL_* character meshes by name + numBones0.
        let hits = scan_meshes(&buf, "CH_AL_");
        use std::collections::BTreeMap;
        let mut best: BTreeMap<String, u32> = BTreeMap::new();
        for h in &hits {
            let e = best.entry(h.name.clone()).or_insert(0);
            if h.num_bones0 > *e { *e = h.num_bones0; }
        }
        eprintln!("[*] {} CH_AL_ mesh instances, {} unique names", hits.len(), best.len());
        for (n, nb) in best { println!("{nb:5}  {n}"); }
        return;
    }

    eprintln!("[*] scanning for MSHA meshes matching \"{name_filter}\" ...");
    let hits = scan_meshes(&buf, name_filter);
    if hits.is_empty() {
        eprintln!("no MSHA mesh matched \"{name_filter}\""); std::process::exit(1);
    }
    // Choose the richest skinned mesh (most bones) matching the filter.
    let chosen = hits.iter().max_by_key(|h| h.num_bones0).unwrap();
    eprintln!("[*] chosen: {} (numBones0={}) @ file offset {}",
        chosen.name, chosen.num_bones0, chosen.file_off);

    let bones = parse_skeleton(&chosen.body).unwrap_or_else(|e| {
        eprintln!("skeleton parse failed: {e}"); std::process::exit(1);
    });

    // ---- validation ----
    let root_count = bones.iter().filter(|b| b.parent < 0).count();
    let parents_before = bones.iter().filter(|b| b.parent >= 0 && (b.parent as usize) < b.index).count();
    let nonroot = bones.len() - root_count;
    let mut min = [f32::MAX; 3]; let mut max = [f32::MIN; 3];
    let mut finite = true;
    for b in &bones {
        let t = b.world.translation();
        for k in 0..3 {
            if !t[k].is_finite() { finite = false; }
            min[k] = min[k].min(t[k]); max[k] = max[k].max(t[k]);
        }
    }
    let names = build_name_map();
    let resolved: Vec<(usize, u32, &str)> = bones.iter()
        .filter_map(|b| names.get(&b.name_hash).map(|n| (b.index, b.name_hash, *n)))
        .collect();

    eprintln!("\n=== VALIDATION ===");
    eprintln!("bones:                {}", bones.len());
    eprintln!("root_count (parent=-1): {}  {}", root_count, if root_count == 1 { "OK" } else { "!!" });
    eprintln!("parents < own index:  {}/{}  {}", parents_before, nonroot, if parents_before == nonroot { "(pure forward tree)" } else { "(some back-refs; still acyclic)" });
    eprintln!("world positions finite: {}", finite);
    eprintln!("world bind bbox min:  [{:.3},{:.3},{:.3}]", min[0], min[1], min[2]);
    eprintln!("world bind bbox max:  [{:.3},{:.3},{:.3}]", max[0], max[1], max[2]);
    eprintln!("height (Y span):      {:.3} m", max[1] - min[1]);
    eprintln!("resolved bone names ({}):", resolved.len());
    for (i, h, n) in resolved.iter().take(24) {
        eprintln!("   idx {:>3}  0x{:08X}  {}", i, h, n);
    }

    let entry = containing_entry(&entries, chosen.file_off);
    if let Some((crc, index, off, size)) = entry {
        eprintln!("containing megapack entry: index=0x{:08X} crc=0x{:08X} offset={} size={}", index, crc, off, size);
    }

    let json = emit_json(path, chosen, entry, &bones, root_count);
    std::fs::write(&out_path, &json).unwrap_or_else(|e| { eprintln!("write error: {e}"); std::process::exit(1); });
    eprintln!("\n[*] wrote {out_path} ({} bones, {} bytes)", bones.len(), json.len());
}
