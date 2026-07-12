//! sab_mesh — extract the renderable, skinned character MESH geometry from The Saboteur
//! (2009) and emit (1) a compact binary geometry dump `SMSH` and (2) a standalone skinned
//! bind-pose glTF (`.glb`) — mesh + 191-bone skeleton + skin — for immediate visual
//! validation (open in Blender -> Sean's body in its modeled/bind pose).
//!
//! Pipeline (empirically validated against `Global/Dynamic0.megapack`, PC/GOG build):
//!
//!   .megapack ("00PM", 64-bit index)                                        [container]
//!     -> SBLA sub-pack ("ALBS")                                             [uncompressed]
//!         -> MSHA wrapper ("AHSM"): 276-byte header (sizes + 256B name)     [uncompressed]
//!             -> MESH body   : zlib (compressedSize0 -> uncompressedSize0)   [flat MESH + skeleton + tail]
//!             -> companion .dat (VB/IB): zlib (compressedSize1 -> uncompressedSize1)
//!
//! The container + MESH header + skeleton parsing are copied verbatim from `sab_skeleton`.
//! The NEW work is the MESH tail (BoneRemaps / Streams / Primitives / DrawCalls), the .dat
//! vertex/index decode, the per-vertex bone-index -> global skeleton-bone remap, and the
//! two emitters.
//!
//! Layout confirmed from PredatorCZ/SaboteurToolset (`mesh/mesh_to_gltf.cpp` struct Read()
//! methods + the format proxy table + ProcessStream/ProcessMesh) and cross-checked
//! byte-for-byte against real assets (see MESH_GEOMETRY_FORMAT.md).

// Several parsed fields/helpers document the on-disk MESH format without being
// read on the extraction hot path.
#![allow(dead_code)]

use std::io::Read;

// ---------------------------------------------------------------------------
// Little-endian scalar readers
// ---------------------------------------------------------------------------
fn u16(b: &[u8], o: usize) -> u16 { u16::from_le_bytes([b[o], b[o + 1]]) }
fn u32(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn i16(b: &[u8], o: usize) -> i16 { i16::from_le_bytes([b[o], b[o + 1]]) }
fn i32(b: &[u8], o: usize) -> i32 { i32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn u64(b: &[u8], o: usize) -> u64 {
    u64::from_le_bytes([b[o], b[o+1], b[o+2], b[o+3], b[o+4], b[o+5], b[o+6], b[o+7]])
}
fn f32a(b: &[u8], o: usize) -> f32 { f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }

/// IEEE half-float (R16) -> f32. Positions/UVs are stored as half.
fn half_to_f32(h: u16) -> f32 {
    let sign = ((h >> 15) & 1) as u32;
    let exp = ((h >> 10) & 0x1f) as u32;
    let mant = (h & 0x3ff) as u32;
    let bits = if exp == 0 {
        if mant == 0 {
            sign << 31
        } else {
            // subnormal
            let mut e = -1i32;
            let mut m = mant;
            loop { e += 1; m <<= 1; if m & 0x400 != 0 { break; } }
            let m = m & 0x3ff;
            (sign << 31) | (((127 - 15 - e) as u32) << 23) | (m << 13)
        }
    } else if exp == 0x1f {
        (sign << 31) | (0xff << 23) | (mant << 13) // inf/nan
    } else {
        (sign << 31) | ((exp + (127 - 15)) << 23) | (mant << 13)
    };
    f32::from_bits(bits)
}
fn half_at(b: &[u8], o: usize) -> f32 { half_to_f32(u16(b, o)) }

// ---------------------------------------------------------------------------
// 4x4 matrix math (copied from sab_skeleton). Storage note: on-disk `localTMS` is 16 f32
// row-major with the translation in the LAST ROW (12,13,14). We transpose on load to
// column-vector math (translation -> column 3). world = parent_world * local; inv = inverse.
// ---------------------------------------------------------------------------
#[derive(Clone, Copy)]
struct Mat4 { m: [[f32; 4]; 4] }

impl Mat4 {
    fn identity() -> Mat4 {
        let mut m = [[0.0f32; 4]; 4];
        for i in 0..4 { m[i][i] = 1.0; }
        Mat4 { m }
    }
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
    /// Column-major flatten (glTF matrices are column-major, 16 floats).
    fn flat_colmajor(&self) -> [f32; 16] {
        let mut o = [0.0f32; 16];
        for c in 0..4 { for r in 0..4 { o[c * 4 + r] = self.m[r][c]; } }
        o
    }
    fn translation(&self) -> [f32; 3] { [self.m[0][3], self.m[1][3], self.m[2][3]] }
    fn det3(&self) -> f32 {
        let m = &self.m;
        m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])
        - m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])
        + m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0])
    }
    fn flat_rowmajor(&self) -> [f32; 16] {
        let mut o = [0.0f32; 16];
        for r in 0..4 { for c in 0..4 { o[r * 4 + c] = self.m[r][c]; } }
        o
    }
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
    /// Decompose into translation / rotation(quaternion xyzw) / scale (assumes no shear).
    fn decompose(&self) -> ([f32; 3], [f32; 4], [f32; 3]) {
        let t = self.translation();
        let col = |c: usize| [self.m[0][c], self.m[1][c], self.m[2][c]];
        let len = |v: [f32; 3]| (v[0]*v[0] + v[1]*v[1] + v[2]*v[2]).sqrt();
        let (mut sx, sy, sz) = (len(col(0)), len(col(1)), len(col(2)));
        if self.det3() < 0.0 { sx = -sx; }
        let (sx, sy, sz) = (if sx == 0.0 {1e-8} else {sx}, if sy==0.0 {1e-8} else {sy}, if sz==0.0 {1e-8} else {sz});
        let r = [
            [self.m[0][0]/sx, self.m[0][1]/sy, self.m[0][2]/sz],
            [self.m[1][0]/sx, self.m[1][1]/sy, self.m[1][2]/sz],
            [self.m[2][0]/sx, self.m[2][1]/sy, self.m[2][2]/sz],
        ];
        (t, quat_from_rot(&r), [sx, sy, sz])
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
// Container: megapack index + MSHA scan + zlib (copied from sab_skeleton)
// ---------------------------------------------------------------------------
struct MeshHit { name: String, file_off: usize, unc0: u32, comp0: u32, unc1: u32, comp1: u32, num_bones0: u32, body: Vec<u8>, dat: Vec<u8> }

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
    match d.read_to_end(&mut out) { Ok(_) => Some(out), Err(_) => None }
}

fn mesh_num_bones0(body: &[u8]) -> Option<u32> {
    if body.len() < 212 { return None; }
    Some(u32(body, 204))
}

/// Scan the whole megapack for MSHA ("AHSM") and fully decode any whose name matches `filter`.
/// Decodes BOTH zlib blobs: the MESH body (blob0) and the companion .dat VB/IB (blob1).
fn scan_meshes(buf: &[u8], name_filter: &str) -> Vec<MeshHit> {
    let magic = b"AHSM";
    let mut hits = Vec::new();
    let mut i = 0usize;
    while i + 276 <= buf.len() {
        if &buf[i..i + 4] == magic {
            if let Some((name, c0, unc0, c1, unc1)) = parse_msha_header(buf, i) {
                if c0 > 0 && unc0 > 0 && c0 as usize <= buf.len()
                    && (name_filter.is_empty() || name.contains(name_filter))
                {
                    let start0 = i + 276;
                    if start0 + c0 as usize <= buf.len() {
                        if let Some(body) = zlib_inflate(&buf[start0..start0 + c0 as usize], unc0 as usize) {
                            if body.len() == unc0 as usize {
                                if let Some(nb0) = mesh_num_bones0(&body) {
                                    // blob1 (.dat) immediately follows blob0.
                                    let start1 = start0 + c0 as usize;
                                    let dat = if c1 > 0 && start1 + c1 as usize <= buf.len() {
                                        zlib_inflate(&buf[start1..start1 + c1 as usize], unc1 as usize).unwrap_or_default()
                                    } else { Vec::new() };
                                    hits.push(MeshHit {
                                        name, file_off: i, unc0, comp0: c0, unc1, comp1: c1,
                                        num_bones0: nb0, body, dat,
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
        i += 1;
    }
    hits
}

// ---------------------------------------------------------------------------
// Parsed MESH: skeleton + tail
// ---------------------------------------------------------------------------
struct Skeleton {
    num_bones: usize,
    bone_ids: Vec<u8>,          // boneIds[]: local slot -> stored bone id (identity on Sean)
    name_hashes: Vec<u32>,
    parents: Vec<i32>,
    trs: Vec<([f32;3],[f32;4],[f32;3])>, // local TRS (t / r-xyzw / s)
    world: Vec<Mat4>,          // bind world = parent_world * localTMS
    inv_bind: Vec<Mat4>,       // inverse(world)
}

struct BoneRemap { bone_id: u32 }   // ibm(64) + boneId(u32); ibm recomputed, not stored
struct Stream {
    num_vertices: u32, format: u32,
    vb_offset: u32, vb_size: u32, vb_stride: u32,
    ib_offset: u32, ib_size: u32, face_type: u32, num_indices: u32,
}
struct Primitive { stream_index: u32, index_offset: u32, num_faces: u32, num_indices: u32 }
struct DrawCall { primitive_index: u32, material: u32, parent_bone: u16 }

struct MeshTail {
    skel: Skeleton,
    remaps: Vec<BoneRemap>,
    streams: Vec<Stream>,
    prims: Vec<Primitive>,
    draws: Vec<DrawCall>,
}

/// Parse MESH header + skeleton (copied from sab_skeleton), then the tail.
/// Returns MeshTail and the byte cursor left at end-of-body (for validation).
fn parse_mesh(body: &[u8]) -> Result<(MeshTail, usize), String> {
    // ---- MESH header (244 bytes) ----
    let num_bones0 = u32(body, 204) as usize;
    let num_bone_remaps = u32(body, 208) as usize;
    let num_streams = u16(body, 216) as usize;
    let num_primitives = u16(body, 218) as usize;
    let num_draw_calls = u32(body, 232) as usize;
    if num_bones0 <= 1 { return Err(format!("mesh not skinned (numBones0={num_bones0})")); }

    // ---- MESHSkeleton header @244 (11 u32) ----
    let mut p = 244usize;
    let num_unk_bones0 = u32(body, p);
    let num_bones = u32(body, p + 12) as usize;   // numBones2
    let num_unk_bones1 = u32(body, p + 16);
    let num_bones3 = u32(body, p + 20) as usize;
    let num_bones4 = u32(body, p + 28) as usize;
    if num_bones != num_bones3 || num_bones != num_bones4 {
        return Err(format!("bone count mismatch: {num_bones}/{num_bones3}/{num_bones4}"));
    }
    if num_bones != num_bones0 {
        return Err(format!("numBones0({num_bones0}) != numBones2({num_bones})"));
    }
    p += 44;

    // ---- boneIds: numBones u8 + numUnkBones0 pad ----
    let bone_ids = body[p..p + num_bones].to_vec(); p += num_bones;
    p += num_unk_bones0 as usize;

    // ---- localTMS: numBones * Matrix44 ----
    let mut local_mats = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        let mut raw = [0.0f32; 16];
        for k in 0..16 { raw[k] = f32a(body, p + k * 4); }
        local_mats.push(Mat4::from_raw_transposed(&raw));
        p += 64;
    }
    // ---- bones: numBones * Bone (64) — boneName0 @0 ----
    let mut name_hashes = Vec::with_capacity(num_bones);
    for _ in 0..num_bones { name_hashes.push(u32(body, p)); p += 64; }
    // ---- transforms: numBones * RTSValue (48) ----
    let mut trs = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        let t = [f32a(body, p),      f32a(body, p + 4),  f32a(body, p + 8)];
        let r = [f32a(body, p + 16), f32a(body, p + 20), f32a(body, p + 24), f32a(body, p + 28)];
        let s = [f32a(body, p + 32), f32a(body, p + 36), f32a(body, p + 40)];
        trs.push((t, r, s)); p += 48;
    }
    // ---- parentIds: numBones i16 ----
    let mut parents = Vec::with_capacity(num_bones);
    for _ in 0..num_bones { parents.push(i16(body, p) as i32); p += 2; }
    // ---- numBones * null32, then optional null16 ----
    p += 4 * num_bones;
    if num_unk_bones1 != 0 { p += 2; }

    // ---- compose world (bind) matrices ----
    let mut world = vec![Mat4::identity(); num_bones];
    let mut done = vec![false; num_bones];
    let mut progress = true;
    while progress {
        progress = false;
        for i in 0..num_bones {
            if done[i] { continue; }
            let pp = parents[i];
            if pp < 0 { world[i] = local_mats[i]; done[i] = true; progress = true; }
            else if done[pp as usize] { world[i] = world[pp as usize].mul(&local_mats[i]); done[i] = true; progress = true; }
        }
    }
    if done.iter().any(|&d| !d) { return Err("bone hierarchy cycle / dangling parent".into()); }
    let inv_bind: Vec<Mat4> = world.iter().map(|w| w.inverse()).collect();

    let skel = Skeleton { num_bones, bone_ids, name_hashes, parents, trs, world, inv_bind };

    // ---- MESH tail (ProcessMesh order) ----
    // if numBoneRemaps: u32 unk0(==numBoneRemaps) + null32, then BoneRemap[ ibm(64)+boneId(4) ]
    let mut remaps = Vec::with_capacity(num_bone_remaps);
    if num_bone_remaps > 0 {
        let unk0 = u32(body, p) as usize;
        if unk0 != num_bone_remaps {
            return Err(format!("boneRemap count guard mismatch: {unk0} != {num_bone_remaps}"));
        }
        p += 8; // unk0 + null32
        for _ in 0..num_bone_remaps {
            let bone_id = u32(body, p + 64); // after the 64-byte ibm
            remaps.push(BoneRemap { bone_id });
            p += 68;
        }
    }
    // Streams[numStreams] (152 bytes each)
    let mut streams = Vec::with_capacity(num_streams);
    for _ in 0..num_streams {
        let o = p;
        let s = Stream {
            num_vertices: u32(body, o + 24),
            format: u32(body, o + 40),
            vb_offset: u32(body, o + 88),
            vb_size: u32(body, o + 104),
            vb_stride: u32(body, o + 120),
            ib_offset: u32(body, o + 128),
            ib_size: u32(body, o + 132),
            face_type: u32(body, o + 140),
            num_indices: u32(body, o + 144),
        };
        streams.push(s);
        p += 152;
    }
    // Primitives[numPrimitives] (100 bytes each)
    let mut prims = Vec::with_capacity(num_primitives);
    for _ in 0..num_primitives {
        let o = p;
        let const0 = i32(body, o + 4);
        if const0 != -1 { return Err(format!("primitive const0 != -1 (got {const0})")); }
        prims.push(Primitive {
            stream_index: u32(body, o + 80),
            index_offset: u32(body, o + 88),
            num_faces: u32(body, o + 92),
            num_indices: u32(body, o + 96),
        });
        p += 100;
    }
    // DrawCalls[numDrawCalls] (16 bytes each)
    let mut draws = Vec::with_capacity(num_draw_calls);
    for _ in 0..num_draw_calls {
        let o = p;
        draws.push(DrawCall {
            primitive_index: u32(body, o),
            material: u32(body, o + 4),
            parent_bone: u16(body, o + 12),
        });
        p += 16;
    }

    Ok((MeshTail { skel, remaps, streams, prims, draws }, p))
}

// ---------------------------------------------------------------------------
// Vertex format bitfield decode -> attribute list (reproduces the toolset proxy table).
// format = positionType:2 | skinType:2 | numColors:4 | numUVs:4 | normal:1 | tangent:1 | .. | constTag:8(0x1B)
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq)]
enum Attr { Position, BoneWeights, BoneIndices, Color, Uv, Normal, Tangent }

fn attr_size(a: Attr) -> usize {
    match a {
        Attr::Position    => 8,  // R16G16B16A16 FLOAT (half4)
        Attr::BoneWeights => 4,  // R8G8B8A8 UNORM
        Attr::BoneIndices => 4,  // R8G8B8A8 UINT
        Attr::Color       => 4,  // R8G8B8A8 UNORM
        Attr::Uv          => 4,  // R16G16 FLOAT (half2)
        Attr::Normal      => 12, // R32G32B32 FLOAT
        Attr::Tangent     => 4,  // R8G8B8A8 UNORM
    }
}

/// Decode a format code into an ordered attribute list with per-attribute byte offsets.
fn decode_format(fmt: u32) -> Result<Vec<(Attr, usize)>, String> {
    let const_tag = (fmt >> 24) & 0xff;
    if const_tag != 0x1b { return Err(format!("unexpected constTag 0x{:02x} in format 0x{:08x}", const_tag, fmt)); }
    let position_type = fmt & 0x3;
    let skin_type = (fmt >> 2) & 0x3;
    let num_colors = (fmt >> 4) & 0xf;
    let num_uvs = (fmt >> 8) & 0xf;
    let has_normal = (fmt >> 12) & 1;
    let has_tangent = (fmt >> 13) & 1;
    if position_type != 2 {
        return Err(format!("unsupported positionType {position_type} (only half4=2 known) in 0x{:08x}", fmt));
    }
    let mut list = vec![Attr::Position];
    if skin_type != 0 { list.push(Attr::BoneWeights); list.push(Attr::BoneIndices); }
    for _ in 0..num_colors { list.push(Attr::Color); }
    for _ in 0..num_uvs { list.push(Attr::Uv); }
    if has_normal != 0 { list.push(Attr::Normal); }
    if has_tangent != 0 { list.push(Attr::Tangent); }
    // cumulative offsets
    let mut out = Vec::with_capacity(list.len());
    let mut off = 0usize;
    for a in list { out.push((a, off)); off += attr_size(a); }
    Ok(out)
}

// ---------------------------------------------------------------------------
// Decoded geometry (single interleaved vertex pool + global-index remap applied)
// ---------------------------------------------------------------------------
struct Geometry {
    positions: Vec<[f32; 3]>,
    normals: Vec<[f32; 3]>,
    uvs: Vec<[f32; 2]>,
    joints: Vec<[u16; 4]>,   // GLOBAL skeleton bone indices (0..num_bones-1)
    weights: Vec<[f32; 4]>,  // normalized, sum ~= 1
    indices: Vec<u32>,       // triangle list (concatenation of all streams' index buffers)
    prims: Vec<SmshPrim>,    // one per drawcall (faithful draw list; may overlap)
    stream_ranges: Vec<(u32, u32)>, // (index_start, index_count) per stream — non-overlapping full coverage
    has_skin: bool,
    has_normal: bool,
    has_uv: bool,
}
struct SmshPrim { index_start: u32, index_count: u32, material: u32, flags: u32 }

/// Decode all streams from the .dat, resolve per-vertex bone indices to GLOBAL skeleton bones
/// via the boneRemap palette: global = boneIds[ boneRemaps[localIndex].boneId ].
fn decode_geometry(tail: &MeshTail, dat: &[u8], remap: Option<&std::collections::HashMap<u32, u16>>) -> Result<Geometry, String> {
    let mut g = Geometry {
        positions: Vec::new(), normals: Vec::new(), uvs: Vec::new(),
        joints: Vec::new(), weights: Vec::new(), indices: Vec::new(),
        prims: Vec::new(), stream_ranges: Vec::new(), has_skin: false, has_normal: false, has_uv: false,
    };
    // Per-stream: base vertex (into global pool) and base index (into global index buffer).
    let mut stream_vbase = Vec::with_capacity(tail.streams.len());
    let mut stream_ibase = Vec::with_capacity(tail.streams.len());

    for s in &tail.streams {
        if s.face_type != 1 {
            return Err(format!("unexpected faceType {} (only triangle-list=1 supported)", s.face_type));
        }
        let layout = decode_format(s.format)?;
        let stride = s.vb_stride as usize;
        let nverts = s.num_vertices as usize;
        let vb = s.vb_offset as usize;
        if vb + nverts * stride > dat.len() {
            return Err(format!("vertex buffer OOB (off {vb} + {nverts}*{stride} > dat {})", dat.len()));
        }
        let vbase = g.positions.len() as u32;
        stream_vbase.push(vbase);

        for v in 0..nverts {
            let base = vb + v * stride;
            let mut pos = [0.0f32; 3];
            let mut nrm = [0.0f32; 3];
            let mut uv = [0.0f32; 2];
            let mut jnt = [0u16; 4];
            let mut wgt = [0.0f32; 4];
            let mut got_uv = false;
            for &(a, ao) in &layout {
                let o = base + ao;
                match a {
                    Attr::Position => { pos = [half_at(dat, o), half_at(dat, o + 2), half_at(dat, o + 4)]; }
                    Attr::Normal   => { nrm = [f32a(dat, o), f32a(dat, o + 4), f32a(dat, o + 8)]; g.has_normal = true; }
                    Attr::Uv       => { if !got_uv { uv = [half_at(dat, o), half_at(dat, o + 2)]; got_uv = true; g.has_uv = true; } }
                    Attr::BoneWeights => {
                        let raw = [dat[o], dat[o+1], dat[o+2], dat[o+3]];
                        for k in 0..4 { wgt[k] = raw[k] as f32 / 255.0; }
                        g.has_skin = true;
                    }
                    Attr::BoneIndices => {
                        let raw = [dat[o], dat[o+1], dat[o+2], dat[o+3]];
                        for k in 0..4 {
                            let local = raw[k] as usize;
                            // Resolve local palette index -> this part's skeleton bone.
                            let global = if local < tail.remaps.len() {
                                let bone_id = tail.remaps[local].bone_id as usize;
                                *tail.skel.bone_ids.get(bone_id).unwrap_or(&0) as u16
                            } else { 0 };
                            // Optionally re-key onto a target skeleton by bone name-hash
                            // (so parts with different local skeletons merge correctly).
                            jnt[k] = match remap {
                                Some(m) => {
                                    let h = tail.skel.name_hashes.get(global as usize).copied().unwrap_or(0);
                                    m.get(&h).copied().unwrap_or(global)
                                }
                                None => global,
                            };
                        }
                    }
                    Attr::Color | Attr::Tangent => { /* not exported in v1 */ }
                }
            }
            // Zero the joint index of any zero-weight influence (matches toolset), and renormalize.
            if g.has_skin {
                for k in 0..4 { if wgt[k] == 0.0 { jnt[k] = 0; } }
                let sum: f32 = wgt.iter().sum();
                if sum > 0.0 { for k in 0..4 { wgt[k] /= sum; } }
            }
            g.positions.push(pos);
            g.normals.push(nrm);
            g.uvs.push(uv);
            g.joints.push(jnt);
            g.weights.push(wgt);
        }

        // index buffer (u16 triangle list), rebased to the global vertex pool.
        let ibase = g.indices.len() as u32;
        stream_ibase.push(ibase);
        let ib = s.ib_offset as usize;
        let nidx = s.num_indices as usize;
        if ib + nidx * 2 > dat.len() {
            return Err(format!("index buffer OOB (off {ib} + {nidx}*2 > dat {})", dat.len()));
        }
        for k in 0..nidx {
            let idx = u16(dat, ib + k * 2) as u32;
            g.indices.push(idx + vbase);
        }
        g.stream_ranges.push((ibase, nidx as u32));
    }

    // Build SMSH prims from drawcalls: each drawcall -> a sub-range of its primitive's stream index buffer.
    for d in &tail.draws {
        let prim = tail.prims.get(d.primitive_index as usize)
            .ok_or_else(|| format!("drawcall references primitive {} of {}", d.primitive_index, tail.prims.len()))?;
        let ibase = stream_ibase[prim.stream_index as usize];
        g.prims.push(SmshPrim {
            index_start: ibase + prim.index_offset,
            index_count: prim.num_indices,
            material: d.material,
            flags: d.primitive_index,
        });
    }
    Ok(g)
}

// ---------------------------------------------------------------------------
// SMSH writer
// ---------------------------------------------------------------------------
fn write_smsh(g: &Geometry) -> Vec<u8> {
    let mut o = Vec::new();
    let nv = g.positions.len() as u32;
    let ni = g.indices.len() as u32;
    let np = g.prims.len() as u32;
    o.extend_from_slice(b"SMSH");
    o.extend_from_slice(&1u32.to_le_bytes());
    o.extend_from_slice(&nv.to_le_bytes());
    o.extend_from_slice(&ni.to_le_bytes());
    o.extend_from_slice(&np.to_le_bytes());
    for p in &g.positions { for c in p { o.extend_from_slice(&c.to_le_bytes()); } }
    for n in &g.normals   { for c in n { o.extend_from_slice(&c.to_le_bytes()); } }
    for u in &g.uvs       { for c in u { o.extend_from_slice(&c.to_le_bytes()); } }
    for j in &g.joints    { for c in j { o.extend_from_slice(&c.to_le_bytes()); } }
    for w in &g.weights   { for c in w { o.extend_from_slice(&c.to_le_bytes()); } }
    for &i in &g.indices  { o.extend_from_slice(&i.to_le_bytes()); }
    for p in &g.prims {
        o.extend_from_slice(&p.index_start.to_le_bytes());
        o.extend_from_slice(&p.index_count.to_le_bytes());
        o.extend_from_slice(&p.material.to_le_bytes());
        o.extend_from_slice(&p.flags.to_le_bytes());
    }
    o
}

// ---------------------------------------------------------------------------
// Minimal GLB (glTF 2.0 binary) writer: skinned bind-pose mesh + skeleton.
// JOINTS_0 carry GLOBAL bone indices; skin.joints is the identity list [0..N), so
// nodeWorld[b] * inverseBindMatrices[b] = identity at bind -> verts render at authored pose.
// ---------------------------------------------------------------------------
fn write_glb(g: &Geometry, skel: &Skeleton, mesh_name: &str) -> Vec<u8> {
    let nv = g.positions.len();
    let nb = skel.num_bones;

    // ---- assemble BIN buffer with 4-byte-aligned sections ----
    let mut bin: Vec<u8> = Vec::new();
    let align = |b: &mut Vec<u8>| while b.len() % 4 != 0 { b.push(0); };

    // POSITION
    let pos_off = bin.len();
    let mut pmin = [f32::MAX; 3]; let mut pmax = [f32::MIN; 3];
    for p in &g.positions {
        for k in 0..3 { pmin[k] = pmin[k].min(p[k]); pmax[k] = pmax[k].max(p[k]); bin.extend_from_slice(&p[k].to_le_bytes()); }
    }
    align(&mut bin);
    // NORMAL
    let nrm_off = bin.len();
    for n in &g.normals { for k in 0..3 { bin.extend_from_slice(&n[k].to_le_bytes()); } }
    align(&mut bin);
    // TEXCOORD_0
    let uv_off = bin.len();
    for u in &g.uvs { for k in 0..2 { bin.extend_from_slice(&u[k].to_le_bytes()); } }
    align(&mut bin);
    // JOINTS_0 (u16 x4)
    let jnt_off = bin.len();
    for j in &g.joints { for k in 0..4 { bin.extend_from_slice(&j[k].to_le_bytes()); } }
    align(&mut bin);
    // WEIGHTS_0 (f32 x4)
    let wgt_off = bin.len();
    for w in &g.weights { for k in 0..4 { bin.extend_from_slice(&w[k].to_le_bytes()); } }
    align(&mut bin);
    // indices (u32)
    let idx_off = bin.len();
    for &i in &g.indices { bin.extend_from_slice(&i.to_le_bytes()); }
    align(&mut bin);
    // inverseBindMatrices (f32 x16, column-major) per bone
    let ibm_off = bin.len();
    for b in 0..nb { for c in skel.inv_bind[b].flat_colmajor() { bin.extend_from_slice(&c.to_le_bytes()); } }
    align(&mut bin);

    let ni = g.indices.len();

    // ---- JSON ----
    // bufferViews: 0 pos,1 nrm,2 uv,3 jnt,4 wgt,5 idx,6 ibm
    let mut bv = String::new();
    let mut push_bv = |s: &mut String, off: usize, len: usize, target: Option<u32>| {
        if !s.is_empty() { s.push(','); }
        s.push_str(&format!("{{\"buffer\":0,\"byteOffset\":{off},\"byteLength\":{len}"));
        if let Some(t) = target { s.push_str(&format!(",\"target\":{t}")); }
        s.push('}');
    };
    push_bv(&mut bv, pos_off, nv*12, Some(34962));
    push_bv(&mut bv, nrm_off, nv*12, Some(34962));
    push_bv(&mut bv, uv_off,  nv*8,  Some(34962));
    push_bv(&mut bv, jnt_off, nv*8,  Some(34962));
    push_bv(&mut bv, wgt_off, nv*16, Some(34962));
    push_bv(&mut bv, idx_off, ni*4,  Some(34963));
    push_bv(&mut bv, ibm_off, nb*64, None);

    // accessors: 0 pos,1 nrm,2 uv,3 jnt,4 wgt,5 idx,6 ibm
    let fmt_f = |x: f32| if x == 0.0 { "0".to_string() } else { format!("{}", x) };
    let mut acc = String::new();
    // POSITION with min/max
    acc.push_str(&format!(
        "{{\"bufferView\":0,\"componentType\":5126,\"count\":{nv},\"type\":\"VEC3\",\"min\":[{},{},{}],\"max\":[{},{},{}]}}",
        fmt_f(pmin[0]), fmt_f(pmin[1]), fmt_f(pmin[2]), fmt_f(pmax[0]), fmt_f(pmax[1]), fmt_f(pmax[2])));
    acc.push_str(&format!(",{{\"bufferView\":1,\"componentType\":5126,\"count\":{nv},\"type\":\"VEC3\"}}"));
    acc.push_str(&format!(",{{\"bufferView\":2,\"componentType\":5126,\"count\":{nv},\"type\":\"VEC2\"}}"));
    acc.push_str(&format!(",{{\"bufferView\":3,\"componentType\":5123,\"count\":{nv},\"type\":\"VEC4\"}}"));
    acc.push_str(&format!(",{{\"bufferView\":4,\"componentType\":5126,\"count\":{nv},\"type\":\"VEC4\"}}"));
    acc.push_str(&format!(",{{\"bufferView\":5,\"componentType\":5125,\"count\":{ni},\"type\":\"SCALAR\"}}"));
    acc.push_str(&format!(",{{\"bufferView\":6,\"componentType\":5126,\"count\":{nb},\"type\":\"MAT4\"}}"));

    // mesh primitives: attributes -> {POSITION,NORMAL,TEXCOORD_0,JOINTS_0,WEIGHTS_0}, one primitive
    // per drawcall (indices sub-accessor). To keep the JSON compact we reuse accessor 5 with
    // byteOffset via extra accessors appended below.
    let mut extra_acc = String::new();
    let mut prim_json = String::new();
    let attrs = {
        let mut a = String::from("\"POSITION\":0,\"NORMAL\":1,\"TEXCOORD_0\":2");
        if g.has_skin { a.push_str(",\"JOINTS_0\":3,\"WEIGHTS_0\":4"); }
        a
    };
    // The GLB renders one primitive per STREAM (its full, non-overlapping index range) so every
    // triangle draws exactly once — clean bind-pose validation. (The SMSH keeps the faithful
    // per-drawcall prim list with materials for the downstream glTF assembler.)
    let mut next_acc = 7u32;
    for &(start, count) in &g.stream_ranges {
        if !extra_acc.is_empty() { extra_acc.push(','); }
        extra_acc.push_str(&format!(
            "{{\"bufferView\":5,\"byteOffset\":{},\"componentType\":5125,\"count\":{},\"type\":\"SCALAR\"}}",
            (start as usize) * 4, count));
        if !prim_json.is_empty() { prim_json.push(','); }
        prim_json.push_str(&format!("{{\"attributes\":{{{attrs}}},\"indices\":{next_acc}}}"));
        next_acc += 1;
    }
    if !extra_acc.is_empty() { acc.push(','); acc.push_str(&extra_acc); }

    // ---- nodes: 0..nb-1 bone nodes, node nb = skinned mesh node ----
    let mut children: Vec<Vec<usize>> = vec![Vec::new(); nb];
    let mut roots: Vec<usize> = Vec::new();
    for b in 0..nb {
        let par = skel.parents[b];
        if par < 0 { roots.push(b); } else { children[par as usize].push(b); }
    }
    let mut nodes = String::new();
    for b in 0..nb {
        if b > 0 { nodes.push(','); }
        let (t, r, s) = skel.trs[b];
        nodes.push_str(&format!(
            "{{\"translation\":[{},{},{}],\"rotation\":[{},{},{},{}],\"scale\":[{},{},{}]",
            fmt_f(t[0]), fmt_f(t[1]), fmt_f(t[2]),
            fmt_f(r[0]), fmt_f(r[1]), fmt_f(r[2]), fmt_f(r[3]),
            fmt_f(s[0]), fmt_f(s[1]), fmt_f(s[2])));
        if !children[b].is_empty() {
            let cs: Vec<String> = children[b].iter().map(|c| c.to_string()).collect();
            nodes.push_str(&format!(",\"children\":[{}]", cs.join(",")));
        }
        nodes.push('}');
    }
    // mesh node
    nodes.push(',');
    if g.has_skin {
        nodes.push_str(&format!("{{\"name\":\"{mesh_name}\",\"mesh\":0,\"skin\":0}}"));
    } else {
        nodes.push_str(&format!("{{\"name\":\"{mesh_name}\",\"mesh\":0}}"));
    }
    let mesh_node = nb;

    // skin: joints = identity [0..nb), IBM accessor 6, skeleton = first root
    let joints_list: Vec<String> = (0..nb).map(|b| b.to_string()).collect();
    let skin = format!(
        "{{\"inverseBindMatrices\":6,\"skeleton\":{},\"joints\":[{}]}}",
        roots.get(0).copied().unwrap_or(0), joints_list.join(","));

    // scene: roots + mesh node
    let mut scene_nodes: Vec<String> = roots.iter().map(|r| r.to_string()).collect();
    scene_nodes.push(mesh_node.to_string());

    let json = format!(
        "{{\"asset\":{{\"version\":\"2.0\",\"generator\":\"sab_mesh\"}},\
\"scene\":0,\"scenes\":[{{\"nodes\":[{}]}}],\
\"nodes\":[{}],\
\"meshes\":[{{\"name\":\"{}\",\"primitives\":[{}]}}],\
\"skins\":[{}],\
\"accessors\":[{}],\
\"bufferViews\":[{}],\
\"buffers\":[{{\"byteLength\":{}}}]}}",
        scene_nodes.join(","), nodes, mesh_name, prim_json, skin, acc, bv, bin.len());

    // ---- GLB container ----
    let mut json_bytes = json.into_bytes();
    while json_bytes.len() % 4 != 0 { json_bytes.push(b' '); }
    while bin.len() % 4 != 0 { bin.push(0); }
    let total = 12 + 8 + json_bytes.len() + 8 + bin.len();
    let mut glb = Vec::with_capacity(total);
    glb.extend_from_slice(b"glTF");
    glb.extend_from_slice(&2u32.to_le_bytes());
    glb.extend_from_slice(&(total as u32).to_le_bytes());
    glb.extend_from_slice(&(json_bytes.len() as u32).to_le_bytes());
    glb.extend_from_slice(b"JSON");
    glb.extend_from_slice(&json_bytes);
    glb.extend_from_slice(&(bin.len() as u32).to_le_bytes());
    glb.extend_from_slice(b"BIN\0");
    glb.extend_from_slice(&bin);
    glb
}

// ---------------------------------------------------------------------------
// Megapack index (for reporting the containing entry)
// ---------------------------------------------------------------------------
struct Entry { crc: u32, index: u32, size: u32, offset: u64 }
fn read_megapack_index(buf: &[u8]) -> Vec<Entry> {
    if buf.len() < 8 || &buf[0..4] != b"00PM" { return Vec::new(); }
    let count = u32(buf, 4) as usize;
    let mut v = Vec::with_capacity(count);
    let mut p = 8usize;
    for _ in 0..count {
        if p + 20 > buf.len() { break; }
        v.push(Entry { crc: u32(buf, p), index: u32(buf, p + 4), size: u32(buf, p + 8), offset: u64(buf, p + 12) });
        p += 20;
    }
    v
}
fn containing_entry(entries: &[Entry], off: usize) -> Option<(u32, u32, u64, u32)> {
    for e in entries {
        let start = e.offset as usize; let end = start + e.size as usize;
        if (start..end).contains(&off) { return Some((e.crc, e.index, e.offset, e.size)); }
    }
    None
}

/// Parse a sab_skeleton JSON into a bone-name-hash -> index map (std-only, tolerant).
/// The `bones` array is index-ordered, so the n-th `name_hash` has index n.
fn parse_target_skeleton(text: &str) -> std::collections::HashMap<u32, u16> {
    let b = text.as_bytes();
    let key = b"\"name_hash\"";
    let mut map = std::collections::HashMap::new();
    let mut idx: u16 = 0;
    let mut i = 0usize;
    while let Some(rel) = b[i..].windows(key.len()).position(|w| w == key) {
        let mut p = i + rel + key.len();
        while p < b.len() && !(b[p] as char).is_ascii_digit() { p += 1; }
        let mut val: u64 = 0; let mut any = false;
        while p < b.len() && (b[p] as char).is_ascii_digit() { val = val * 10 + (b[p] - b'0') as u64; p += 1; any = true; }
        i = p;
        if any { map.entry(val as u32).or_insert(idx); idx += 1; }
    }
    map
}

fn main() {
    let mut args: Vec<String> = std::env::args().collect();
    // Optional: `--remap <target_skel.json>` re-keys JOINTS_0 onto a target skeleton
    // by bone name-hash, so a character's parts all share one skeleton for merging.
    let remap_map = if let Some(i) = args.iter().position(|a| a == "--remap") {
        let p = args.get(i + 1).cloned().expect("--remap needs a path");
        let m = parse_target_skeleton(&std::fs::read_to_string(&p).unwrap_or_else(|e| { eprintln!("read {p}: {e}"); std::process::exit(1); }));
        args.drain(i..=i + 1);
        eprintln!("[*] remap: joints -> target skeleton ({} bones) from {p}", m.len());
        Some(m)
    } else { None };
    if args.len() < 3 {
        eprintln!("usage: sab_mesh <megapack> [name_substr] <out.smsh> [out.glb]");
        eprintln!("  default name_substr = \"CH_AL_SeanDevlin_01_GR\"");
        eprintln!("  e.g. sab_mesh Dynamic0.megapack sean.smsh sean.glb");
        std::process::exit(2);
    }
    // Flexible arg parsing: <megapack> [name] <out.smsh> [out.glb]
    let path = args[1].clone();
    let (name_filter, smsh_path, glb_path): (String, String, Option<String>) = {
        // find the .smsh arg
        let rest = &args[2..];
        let smsh_idx = rest.iter().position(|a| a.ends_with(".smsh"));
        match smsh_idx {
            Some(i) => {
                let name = if i == 0 { "CH_AL_SeanDevlin_01_GR".to_string() } else { rest[0].clone() };
                let smsh = rest[i].clone();
                let glb = rest.get(i + 1).cloned();
                (name, smsh, glb)
            }
            None => {
                // no .smsh extension given: treat arg2 as smsh path, optional name absent
                ("CH_AL_SeanDevlin_01_GR".to_string(), rest[0].clone(), rest.get(1).cloned())
            }
        }
    };

    eprintln!("[*] reading {path} ...");
    let buf = std::fs::read(&path).unwrap_or_else(|e| { eprintln!("read error: {e}"); std::process::exit(1); });
    eprintln!("[*] {} bytes", buf.len());
    let entries = read_megapack_index(&buf);
    if !entries.is_empty() { eprintln!("[*] megapack index: {} SBLA entries", entries.len()); }

    eprintln!("[*] scanning MSHA meshes matching \"{name_filter}\" ...");
    let hits = scan_meshes(&buf, &name_filter);
    if hits.is_empty() { eprintln!("no MSHA mesh matched \"{name_filter}\""); std::process::exit(1); }
    let chosen = hits.iter().max_by_key(|h| h.num_bones0).unwrap();
    eprintln!("[*] chosen: {} (numBones0={}) @ file offset {}", chosen.name, chosen.num_bones0, chosen.file_off);
    eprintln!("[*] MESH body {}->{} B, .dat {}->{} B", chosen.comp0, chosen.unc0, chosen.comp1, chosen.unc1);
    if chosen.dat.is_empty() { eprintln!("!! companion .dat (VB/IB) is empty — cannot extract geometry"); std::process::exit(1); }

    let (tail, end_p) = parse_mesh(&chosen.body).unwrap_or_else(|e| { eprintln!("mesh parse failed: {e}"); std::process::exit(1); });
    eprintln!("[*] tail parse cursor ended at {} of {} body bytes ({} leftover)", end_p, chosen.body.len(), chosen.body.len() as i64 - end_p as i64);

    let g = decode_geometry(&tail, &chosen.dat, remap_map.as_ref()).unwrap_or_else(|e| { eprintln!("geometry decode failed: {e}"); std::process::exit(1); });

    // ---------------- VALIDATION ----------------
    let nb = tail.skel.num_bones;
    let mut min = [f32::MAX; 3]; let mut max = [f32::MIN; 3]; let mut finite = true;
    for p in &g.positions { for k in 0..3 { if !p[k].is_finite() { finite = false; } min[k]=min[k].min(p[k]); max[k]=max[k].max(p[k]); } }
    let mut w_min = f32::MAX; let mut w_max = f32::MIN; let mut j_max = 0u16; let mut j_bad = 0usize;
    for i in 0..g.positions.len() {
        let s: f32 = g.weights[i].iter().sum();
        w_min = w_min.min(s); w_max = w_max.max(s);
        for k in 0..4 { let j = g.joints[i][k]; if (j as usize) >= nb { j_bad += 1; } j_max = j_max.max(j); }
    }
    let idx_max = g.indices.iter().copied().max().unwrap_or(0);
    let tris = g.indices.len() / 3;

    eprintln!("\n=== VALIDATION ===");
    eprintln!("streams:              {}", tail.streams.len());
    for (si, s) in tail.streams.iter().enumerate() {
        eprintln!("  stream {si}: fmt=0x{:08X} verts={} stride={} indices={} faceType={}", s.format, s.num_vertices, s.vb_stride, s.num_indices, s.face_type);
    }
    eprintln!("vertices:             {}", g.positions.len());
    eprintln!("triangles:            {} ({} indices)", tris, g.indices.len());
    eprintln!("primitives (drawcalls): {}", g.prims.len());
    eprintln!("boneRemaps (palette): {}", tail.remaps.len());
    eprintln!("position finite:      {}", finite);
    eprintln!("bbox min:             [{:.3},{:.3},{:.3}]", min[0], min[1], min[2]);
    eprintln!("bbox max:             [{:.3},{:.3},{:.3}]", max[0], max[1], max[2]);
    eprintln!("bbox span:            [{:.3},{:.3},{:.3}] (Y height {:.3} m)", max[0]-min[0], max[1]-min[1], max[2]-min[2], max[1]-min[1]);
    eprintln!("weight sum min/max:   {:.4} / {:.4}  {}", w_min, w_max, if (w_min-1.0).abs()<1e-3 && (w_max-1.0).abs()<1e-3 { "OK (~1.0)" } else if g.has_skin {"!!"} else {"(no skin)"});
    eprintln!("joint index max:      {} (< {} bones? {})", j_max, nb, if (j_max as usize) < nb {"YES"} else {"NO"});
    eprintln!("joints out of range:  {}", j_bad);
    eprintln!("index max:            {} (< {} verts? {})", idx_max, g.positions.len(), if (idx_max as usize) < g.positions.len() {"YES"} else {"NO"});
    if let Some((crc, index, off, size)) = containing_entry(&entries, chosen.file_off) {
        eprintln!("containing entry:     index=0x{:08X} crc=0x{:08X} offset={} size={}", index, crc, off, size);
    }

    // ---------------- EMIT ----------------
    let smsh = write_smsh(&g);
    std::fs::write(&smsh_path, &smsh).unwrap_or_else(|e| { eprintln!("write error: {e}"); std::process::exit(1); });
    eprintln!("\n[*] wrote {smsh_path} ({} bytes)", smsh.len());

    if let Some(glb) = glb_path {
        let bytes = write_glb(&g, &tail.skel, &chosen.name);
        std::fs::write(&glb, &bytes).unwrap_or_else(|e| { eprintln!("write error: {e}"); std::process::exit(1); });
        eprintln!("[*] wrote {glb} ({} bytes, {} bones, skinned bind-pose glTF)", bytes.len(), nb);
    }
}
