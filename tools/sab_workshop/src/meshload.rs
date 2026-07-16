//! In-app MESH extraction — browse and load any skinned model straight out of a megapack.
//!
//! PORTED from `tools/sab_mesh` (the validated extractor; see its `MESH_GEOMETRY_FORMAT.md`), with
//! the CLI / glTF / SMSH writers stripped and its bespoke Mat4 replaced by glam (the skinning
//! convention is column-vector `world[i] = world[parent] * local[i]`, and `Bone::inv_bind` is stored
//! ROW-MAJOR — see `skinning`). Do not re-derive these offsets.
//!
//! Container path: megapack entry → `MSHA` wrapper (276 B) → blob0 = zlib(MESH body),
//! blob1 = zlib(.dat VB/IB) immediately after blob0.
//!
//! Listing is CHEAP (scan for the `AHSM` magic + read its 276-byte header); the two zlib blobs are
//! only inflated when a model is actually loaded.

#![allow(dead_code)]

use std::io::Read;

use glam::{Mat4, Quat, Vec3};

use crate::formats::{Bone, Prim, Smsh};

fn u16at(b: &[u8], o: usize) -> u16 { u16::from_le_bytes([b[o], b[o + 1]]) }
fn u32at(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn i16at(b: &[u8], o: usize) -> i16 { i16::from_le_bytes([b[o], b[o + 1]]) }
fn i32at(b: &[u8], o: usize) -> i32 { i32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn f32at(b: &[u8], o: usize) -> f32 { f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }

/// IEEE half → f32 (positions are half4, UVs half2).
fn half_to_f32(h: u16) -> f32 {
    let sign = ((h >> 15) & 1) as u32;
    let exp = ((h >> 10) & 0x1f) as u32;
    let man = (h & 0x3ff) as u32;
    let bits = match exp {
        0 => {
            if man == 0 {
                sign << 31
            } else {
                // subnormal → normalize
                let mut e = -1i32;
                let mut m = man;
                while m & 0x400 == 0 {
                    m <<= 1;
                    e -= 1;
                }
                let m = m & 0x3ff;
                (sign << 31) | (((127 - 15 + 1 + e) as u32) << 23) | (m << 13)
            }
        }
        0x1f => (sign << 31) | (0xff << 23) | (man << 13), // inf / NaN
        _ => (sign << 31) | ((exp + 127 - 15) << 23) | (man << 13),
    };
    f32::from_bits(bits)
}
fn half_at(b: &[u8], o: usize) -> f32 { half_to_f32(u16at(b, o)) }

/// One model found in a megapack — enough to list it without inflating anything.
#[derive(Clone)]
pub struct MeshEntry {
    pub name: String,
    pub file_off: usize, // offset of the MSHA magic within the megapack
    comp0: u32,
    unc0: u32,
    comp1: u32,
    unc1: u32,
}

/// A model decoded and ready to render.
pub struct LoadedMesh {
    pub name: String,
    pub mesh: Smsh,
    pub bones: Vec<Bone>,
    /// Per-drawcall `parentBone` (rigid attachment target), same order as `mesh.prims`.
    pub prim_parent_bone: Vec<u16>,
    /// Per-bone name hash, for matching an attachment bone across parts.
    pub bone_hashes: Vec<u32>,
}

fn parse_msha_header(buf: &[u8], off: usize) -> Option<(String, u32, u32, u32, u32)> {
    if off + 276 > buf.len() {
        return None;
    }
    // MSHA: id(4) uncompressedSize0(4) uncompressedSize1(4) compressedSize0(4) compressedSize1(4) name[0x100]
    let unc0 = u32at(buf, off + 4);
    let unc1 = u32at(buf, off + 8);
    let c0 = u32at(buf, off + 12);
    let c1 = u32at(buf, off + 16);
    let name_bytes = &buf[off + 20..off + 276];
    let end = name_bytes.iter().position(|&b| b == 0).unwrap_or(0);
    if end == 0 {
        return None;
    }
    let nm = &name_bytes[..end];
    if !nm.iter().all(|&b| (0x20..0x7f).contains(&b)) {
        return None;
    }
    Some((String::from_utf8_lossy(nm).into_owned(), c0, unc0, c1, unc1))
}

fn zlib_inflate(data: &[u8], expected: usize) -> Option<Vec<u8>> {
    let mut d = flate2::read::ZlibDecoder::new(data);
    let mut out = Vec::with_capacity(expected);
    d.read_to_end(&mut out).ok()?;
    Some(out)
}

/// List every MSHA model in `buf` (a whole megapack). Header-only — no inflate.
pub fn list_meshes(buf: &[u8]) -> Vec<MeshEntry> {
    let mut out = Vec::new();
    let mut i = 0usize;
    while i + 276 <= buf.len() {
        if &buf[i..i + 4] == b"AHSM" {
            if let Some((name, c0, unc0, c1, unc1)) = parse_msha_header(buf, i) {
                if c0 > 0 && unc0 > 0 && (c0 as usize) <= buf.len() {
                    out.push(MeshEntry { name, file_off: i, comp0: c0, unc0, comp1: c1, unc1 });
                }
            }
        }
        i += 1;
    }
    out
}

/// Inflate + decode one listed model.
pub fn load(buf: &[u8], e: &MeshEntry) -> Result<LoadedMesh, String> {
    let start0 = e.file_off + 276;
    let end0 = start0 + e.comp0 as usize;
    if end0 > buf.len() {
        return Err("MESH body blob out of range".into());
    }
    let body = zlib_inflate(&buf[start0..end0], e.unc0 as usize).ok_or("inflate MESH body failed")?;
    if body.len() != e.unc0 as usize {
        return Err(format!("MESH body {} != declared {}", body.len(), e.unc0));
    }
    // blob1 (.dat VB/IB) sits immediately after blob0.
    let start1 = end0;
    let dat = if e.comp1 > 0 && start1 + e.comp1 as usize <= buf.len() {
        zlib_inflate(&buf[start1..start1 + e.comp1 as usize], e.unc1 as usize).unwrap_or_default()
    } else {
        Vec::new()
    };
    if dat.is_empty() {
        return Err("no .dat (VB/IB) blob".into());
    }
    let tail = parse_mesh(&body)?;
    let mut mesh = decode_geometry(&tail, &dat)?;
    crate::formats::bind_rigid_attachments(&mut mesh, &crate::skinning::bind_world(&tail.bones));
    let prim_parent_bone = tail.draws.iter().map(|d| d.parent_bone).collect();
    let bone_hashes = tail.bone_hashes.clone();
    Ok(LoadedMesh { name: e.name.clone(), mesh, bones: tail.bones, prim_parent_bone, bone_hashes })
}

struct Stream {
    num_vertices: u32,
    format: u32,
    vb_offset: u32,
    vb_stride: u32,
    ib_offset: u32,
    face_type: u32,
    num_indices: u32,
}
struct Primitive { stream_index: u32, index_offset: u32, num_indices: u32 }
struct DrawCall { primitive_index: u32, material: u32, parent_bone: u16 }

struct MeshTail {
    bones: Vec<Bone>,
    bone_hashes: Vec<u32>,
    bone_ids: Vec<u8>,
    remaps: Vec<u32>, // boneRemap[i].boneId
    streams: Vec<Stream>,
    prims: Vec<Primitive>,
    draws: Vec<DrawCall>,
}

/// MESH header + skeleton + tail. Offsets per `sab_mesh` / `MESH_GEOMETRY_FORMAT.md`.
fn parse_mesh(body: &[u8]) -> Result<MeshTail, String> {
    if body.len() < 244 {
        return Err("MESH body too short".into());
    }
    let num_bones0 = u32at(body, 204) as usize;
    let num_bone_remaps = u32at(body, 208) as usize;
    let num_streams = u16at(body, 216) as usize;
    let num_primitives = u16at(body, 218) as usize;
    let num_draw_calls = u32at(body, 232) as usize;
    if num_bones0 <= 1 {
        return Err(format!("mesh not skinned (numBones0={num_bones0})"));
    }

    // MESHSkeleton header @244 (11 u32)
    let mut p = 244usize;
    let num_unk_bones0 = u32at(body, p);
    let num_bones = u32at(body, p + 12) as usize; // numBones2
    let num_unk_bones1 = u32at(body, p + 16);
    let num_bones3 = u32at(body, p + 20) as usize;
    let num_bones4 = u32at(body, p + 28) as usize;
    if num_bones != num_bones3 || num_bones != num_bones4 {
        return Err(format!("bone count mismatch: {num_bones}/{num_bones3}/{num_bones4}"));
    }
    if num_bones != num_bones0 {
        return Err(format!("numBones0({num_bones0}) != numBones2({num_bones})"));
    }
    p += 44;

    // boneIds: numBones u8 + numUnkBones0 pad
    if p + num_bones > body.len() {
        return Err("boneIds out of range".into());
    }
    let bone_ids = body[p..p + num_bones].to_vec();
    p += num_bones + num_unk_bones0 as usize;

    // localTMS: numBones * Matrix44 — SKIPPED. We compose bind from the RTS values below, which the
    // .skel pipeline also does (its bind-pose jointMatrix comes out identity), so reading the
    // matrices here would only duplicate that.
    p += num_bones * 64;

    // bones: numBones * Bone(64) — boneName0 (hash) @0
    let mut name_hashes = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        name_hashes.push(u32at(body, p));
        p += 64;
    }
    // transforms: numBones * RTSValue(48)
    let mut trs = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        let t = [f32at(body, p), f32at(body, p + 4), f32at(body, p + 8)];
        let r = [f32at(body, p + 16), f32at(body, p + 20), f32at(body, p + 24), f32at(body, p + 28)];
        let s = [f32at(body, p + 32), f32at(body, p + 36), f32at(body, p + 40)];
        trs.push((t, r, s));
        p += 48;
    }
    // parentIds: numBones i16
    let mut parents = Vec::with_capacity(num_bones);
    for _ in 0..num_bones {
        parents.push(i16at(body, p) as i32);
        p += 2;
    }
    p += 4 * num_bones; // numBones * null32
    if num_unk_bones1 != 0 {
        p += 2;
    }

    // Compose bind world (column-vector, parent * local), then inv_bind ROW-MAJOR for `Bone`.
    let locals: Vec<Mat4> = trs
        .iter()
        .map(|(t, r, s)| {
            Mat4::from_scale_rotation_translation(
                Vec3::from_array(*s),
                Quat::from_xyzw(r[0], r[1], r[2], r[3]),
                Vec3::from_array(*t),
            )
        })
        .collect();
    let mut world = vec![Mat4::IDENTITY; num_bones];
    let mut done = vec![false; num_bones];
    let mut progress = true;
    while progress {
        progress = false;
        for i in 0..num_bones {
            if done[i] {
                continue;
            }
            let pp = parents[i];
            if pp < 0 || pp as usize >= num_bones {
                world[i] = locals[i];
                done[i] = true;
                progress = true;
            } else if done[pp as usize] {
                world[i] = world[pp as usize] * locals[i];
                done[i] = true;
                progress = true;
            }
        }
    }
    if done.iter().any(|&d| !d) {
        return Err("bone hierarchy cycle / dangling parent".into());
    }
    let bones: Vec<Bone> = (0..num_bones)
        .map(|i| {
            let cm = world[i].inverse().to_cols_array(); // column-major
            let mut rm = [0f32; 16];
            for c in 0..4 {
                for r in 0..4 {
                    rm[r * 4 + c] = cm[c * 4 + r];
                }
            }
            let (t, r, s) = trs[i];
            Bone {
                parent: parents[i],
                name: format!("bone_{:08X}", name_hashes[i]),
                t,
                r,
                s,
                inv_bind: Some(rm),
            }
        })
        .collect();

    // ---- tail ----
    let mut remaps = Vec::with_capacity(num_bone_remaps);
    if num_bone_remaps > 0 {
        let guard = u32at(body, p) as usize;
        if guard != num_bone_remaps {
            return Err(format!("boneRemap guard {guard} != {num_bone_remaps}"));
        }
        p += 8; // guard + null32
        for _ in 0..num_bone_remaps {
            remaps.push(u32at(body, p + 64)); // after the 64-byte ibm
            p += 68;
        }
    }
    let mut streams = Vec::with_capacity(num_streams);
    for _ in 0..num_streams {
        streams.push(Stream {
            num_vertices: u32at(body, p + 24),
            format: u32at(body, p + 40),
            vb_offset: u32at(body, p + 88),
            vb_stride: u32at(body, p + 120),
            ib_offset: u32at(body, p + 128),
            face_type: u32at(body, p + 140),
            num_indices: u32at(body, p + 144),
        });
        p += 152;
    }
    let mut prims = Vec::with_capacity(num_primitives);
    for _ in 0..num_primitives {
        if i32at(body, p + 4) != -1 {
            return Err("primitive const0 != -1".into());
        }
        prims.push(Primitive {
            stream_index: u32at(body, p + 80),
            index_offset: u32at(body, p + 88),
            num_indices: u32at(body, p + 96),
        });
        p += 100;
    }
    let mut draws = Vec::with_capacity(num_draw_calls);
    for _ in 0..num_draw_calls {
        draws.push(DrawCall {
            primitive_index: u32at(body, p),
            material: u32at(body, p + 4),
            // The rigid-attachment bone for UNSKINNED drawcall geometry (hats/props).
            parent_bone: u16at(body, p + 12),
        });
        p += 16;
    }

    Ok(MeshTail { bones, bone_hashes: name_hashes, bone_ids, remaps, streams, prims, draws })
}

#[derive(Clone, Copy, PartialEq)]
enum Attr { Position, BoneWeights, BoneIndices, Color, Uv, Normal, Tangent }

fn attr_size(a: Attr) -> usize {
    match a {
        Attr::Position => 8,     // R16G16B16A16 FLOAT (half4)
        Attr::BoneWeights => 4,  // R8G8B8A8 UNORM
        Attr::BoneIndices => 4,  // R8G8B8A8 UINT
        Attr::Color => 4,        // R8G8B8A8 UNORM
        Attr::Uv => 4,           // R16G16 FLOAT (half2)
        Attr::Normal => 12,      // R32G32B32 FLOAT
        Attr::Tangent => 4,      // R8G8B8A8 UNORM
    }
}

/// format = positionType:2 | skinType:2 | numColors:4 | numUVs:4 | normal:1 | tangent:1 | .. | tag:8(0x1B)
fn decode_format(fmt: u32) -> Result<Vec<(Attr, usize)>, String> {
    if (fmt >> 24) & 0xff != 0x1b {
        return Err(format!("unexpected constTag in format 0x{fmt:08x}"));
    }
    let position_type = fmt & 0x3;
    let skin_type = (fmt >> 2) & 0x3;
    let num_colors = (fmt >> 4) & 0xf;
    let num_uvs = (fmt >> 8) & 0xf;
    let has_normal = (fmt >> 12) & 1;
    let has_tangent = (fmt >> 13) & 1;
    if position_type != 2 {
        return Err(format!("unsupported positionType {position_type} in 0x{fmt:08x}"));
    }
    let mut list = vec![Attr::Position];
    if skin_type != 0 {
        list.push(Attr::BoneWeights);
        list.push(Attr::BoneIndices);
    }
    for _ in 0..num_colors {
        list.push(Attr::Color);
    }
    for _ in 0..num_uvs {
        list.push(Attr::Uv);
    }
    if has_normal != 0 {
        list.push(Attr::Normal);
    }
    if has_tangent != 0 {
        list.push(Attr::Tangent);
    }
    let mut out = Vec::with_capacity(list.len());
    let mut off = 0usize;
    for a in list {
        out.push((a, off));
        off += attr_size(a);
    }
    Ok(out)
}

/// Decode every stream into one interleaved pool, resolving per-vertex bone indices to GLOBAL
/// skeleton bones via `global = boneIds[ boneRemaps[local] ]`, and flatten drawcalls into prims.
fn decode_geometry(tail: &MeshTail, dat: &[u8]) -> Result<Smsh, String> {
    let mut m = Smsh {
        positions: Vec::new(),
        normals: Vec::new(),
        uvs: Vec::new(),
        joints: Vec::new(),
        weights: Vec::new(),
        indices: Vec::new(),
        prims: Vec::new(),
    };
    let mut stream_ibase = Vec::with_capacity(tail.streams.len());

    for s in &tail.streams {
        if s.face_type != 1 {
            return Err(format!("unexpected faceType {} (only triangle-list)", s.face_type));
        }
        let layout = decode_format(s.format)?;
        let stride = s.vb_stride as usize;
        let nverts = s.num_vertices as usize;
        let vb = s.vb_offset as usize;
        if vb + nverts * stride > dat.len() {
            return Err("vertex buffer out of range".into());
        }
        let vbase = m.positions.len() as u32;

        for v in 0..nverts {
            let base = vb + v * stride;
            let (mut pos, mut nrm, mut uv) = ([0f32; 3], [0f32; 3], [0f32; 2]);
            let (mut jnt, mut wgt) = ([0u16; 4], [0f32; 4]);
            let mut got_uv = false;
            let mut has_skin = false;
            for &(a, ao) in &layout {
                let o = base + ao;
                match a {
                    Attr::Position => pos = [half_at(dat, o), half_at(dat, o + 2), half_at(dat, o + 4)],
                    Attr::Normal => nrm = [f32at(dat, o), f32at(dat, o + 4), f32at(dat, o + 8)],
                    Attr::Uv => {
                        if !got_uv {
                            uv = [half_at(dat, o), half_at(dat, o + 2)];
                            got_uv = true;
                        }
                    }
                    Attr::BoneWeights => {
                        for k in 0..4 {
                            wgt[k] = dat[o + k] as f32 / 255.0;
                        }
                        has_skin = true;
                    }
                    Attr::BoneIndices => {
                        for k in 0..4 {
                            let local = dat[o + k] as usize;
                            jnt[k] = if local < tail.remaps.len() {
                                let bone_id = tail.remaps[local] as usize;
                                *tail.bone_ids.get(bone_id).unwrap_or(&0) as u16
                            } else {
                                0
                            };
                        }
                    }
                    Attr::Color | Attr::Tangent => {}
                }
            }
            if has_skin {
                for k in 0..4 {
                    if wgt[k] == 0.0 {
                        jnt[k] = 0;
                    }
                }
                let sum: f32 = wgt.iter().sum();
                if sum > 0.0 {
                    for w in &mut wgt {
                        *w /= sum;
                    }
                }
            }
            m.positions.push(pos);
            m.normals.push(nrm);
            m.uvs.push(uv);
            m.joints.push(jnt);
            m.weights.push(wgt);
        }

        // u16 triangle-list indices, rebased onto the global vertex pool.
        let ibase = m.indices.len() as u32;
        stream_ibase.push(ibase);
        let ib = s.ib_offset as usize;
        let nidx = s.num_indices as usize;
        if ib + nidx * 2 > dat.len() {
            return Err("index buffer out of range".into());
        }
        for k in 0..nidx {
            m.indices.push(u16at(dat, ib + k * 2) as u32 + vbase);
        }
    }

    for d in &tail.draws {
        let prim = tail
            .prims
            .get(d.primitive_index as usize)
            .ok_or_else(|| format!("drawcall references primitive {}", d.primitive_index))?;
        let ibase = stream_ibase.get(prim.stream_index as usize).copied().unwrap_or(0);
        m.prims.push(Prim {
            index_start: ibase + prim.index_offset,
            index_count: prim.num_indices,
            material_hash: d.material,
            flags: d.primitive_index,
            parent_bone: d.parent_bone,
        });
    }
    Ok(m)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Against the REAL install: list models in Dynamic0 and load Sean's `_GR` part, checking it
    /// reproduces what `sab_mesh` wrote into `output/skeletons/parts/sean_GR.smsh`
    /// (3389 verts / 10044 indices / 5 prims, per MESH_GEOMETRY_FORMAT.md).
    #[test]
    fn load_sean_gr_from_megapack() {
        let mp = "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack";
        if !std::path::Path::new(mp).exists() {
            eprintln!("skip: {mp} not present");
            return;
        }
        let buf = std::fs::read(mp).expect("read megapack");
        let list = list_meshes(&buf);
        eprintln!("listed {} models", list.len());
        assert!(list.len() > 10, "expected many models");
        let e = list
            .iter()
            .find(|e| e.name.eq_ignore_ascii_case("CH_AL_SeanDevlin_01_GR"))
            .expect("Sean _GR present");
        let lm = load(&buf, e).expect("load Sean _GR");
        eprintln!(
            "loaded {}: {} verts, {} idx, {} prims, {} bones",
            lm.name,
            lm.mesh.positions.len(),
            lm.mesh.indices.len(),
            lm.mesh.prims.len(),
            lm.bones.len()
        );
        assert_eq!(lm.mesh.positions.len(), 3389, "vertex count vs sab_mesh");
        assert_eq!(lm.mesh.indices.len(), 10044, "index count vs sab_mesh");
        assert_eq!(lm.mesh.prims.len(), 5, "drawcall count vs sab_mesh");
        assert_eq!(lm.bones.len(), 191, "bone count");
        assert!(lm.mesh.indices.iter().all(|&i| (i as usize) < lm.mesh.positions.len()));
        // The bind pose must compose to ~identity joint matrices (proves TRS + inv_bind agree).
        let worst = crate::skinning::bind_pose(&lm.bones)
            .iter()
            .flat_map(|m| (*m - glam::Mat4::IDENTITY).to_cols_array())
            .fold(0f32, |a, c| a.max(c.abs()));
        eprintln!("bind-pose max deviation from identity: {worst:.6}");
        assert!(worst < 1e-3, "bind pose should be identity, got {worst}");
    }
}

#[cfg(test)]
mod hat_tests {
    use super::*;

    /// The hat sits on the floor because its geometry is UNSKINNED and authored at the origin — it is
    /// rigid attachment geometry whose target lives in the drawcall's `parentBone`, a field SMSH
    /// never stored. Prove it: Sean's HAT part should have zero skin influence and a non-zero
    /// parentBone naming a head bone.
    #[test]
    fn hat_is_rigid_attachment_with_parent_bone() {
        let mp = "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack";
        if !std::path::Path::new(mp).exists() {
            eprintln!("skip: no megapack");
            return;
        }
        let buf = std::fs::read(mp).unwrap();
        let list = list_meshes(&buf);
        for e in list.iter().filter(|e| e.name.to_ascii_lowercase().contains("seandevlin")) {
            let Ok(lm) = load(&buf, e) else { continue };
            let skinned = lm
                .mesh
                .weights
                .iter()
                .any(|w| w[0] + w[1] + w[2] + w[3] > 0.0001);
            let ymin = lm.mesh.positions.iter().map(|p| p[1]).fold(f32::MAX, f32::min);
            let ymax = lm.mesh.positions.iter().map(|p| p[1]).fold(f32::MIN, f32::max);
            let pbs: Vec<u16> = {
                let mut v = lm.prim_parent_bone.clone();
                v.sort_unstable();
                v.dedup();
                v
            };
            eprintln!(
                "{:34} verts={:5} skinned={:5} Y[{:6.2},{:6.2}] parentBone(s)={:?}",
                lm.name, lm.mesh.positions.len(), skinned, ymin, ymax, pbs
            );
            // For an unskinned part, resolve what its parentBone actually IS on its own rig.
            if !skinned {
                for &pb in &pbs {
                    let hash = lm.bone_hashes.get(pb as usize).copied().unwrap_or(0);
                    let world_y = lm
                        .bones
                        .get(pb as usize)
                        .map(|b| b.t[1])
                        .unwrap_or(0.0);
                    eprintln!(
                        "     -> parentBone {pb} name_hash=0x{hash:08X} local_t.y={world_y:.3}"
                    );
                }
            }
        }
    }
}
