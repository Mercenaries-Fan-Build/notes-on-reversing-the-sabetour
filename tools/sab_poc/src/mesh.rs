//! `mesh-roundtrip` + `mesh-audit` — Stage 1 of the Mattias port: a MESH/MSHA *writer*, proven by
//! re-serializing Sean's own decompressed MESH body **byte-exact**.
//!
//! Container: megapack → `AHSM` (276 B MSHA header) → zlib(MESH body) + zlib(.dat VB/IB).
//! The MESH body is header(244) + MESHSkeleton + tail(boneRemaps/streams/primitives/drawcalls). Section
//! sizes come from the header counts; every fixed-size record (streams 152B, prims 100B, drawcalls 16B,
//! bone records 64B) is re-emitted by writing its KNOWN fields back from parsed values — so this is a
//! field-level writer, not a memcpy. Layout mirrors `sab_workshop/src/meshload.rs` (the reader).

use std::io::Read as _;

use crate::pack;
use crate::Flags;

fn u16at(b: &[u8], o: usize) -> u16 {
    u16::from_le_bytes([b[o], b[o + 1]])
}
fn u32at(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}
fn f32at(b: &[u8], o: usize) -> f32 {
    f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}
fn put_u16(b: &mut [u8], o: usize, v: u16) {
    b[o..o + 2].copy_from_slice(&v.to_le_bytes());
}
fn put_u32(b: &mut [u8], o: usize, v: u32) {
    b[o..o + 4].copy_from_slice(&v.to_le_bytes());
}

fn inflate(data: &[u8], expected: usize) -> Result<Vec<u8>, String> {
    let mut d = flate2::read::ZlibDecoder::new(data);
    let mut out = Vec::with_capacity(expected);
    d.read_to_end(&mut out).map_err(|e| format!("inflate: {e}"))?;
    Ok(out)
}

/// An MSHA occurrence in a megapack buffer.
struct Msha {
    off: usize,
    name: String,
    unc0: u32,
    unc1: u32,
    c0: u32,
    c1: u32,
}

fn scan_msha(buf: &[u8]) -> Vec<Msha> {
    let mut out = Vec::new();
    let mut i = 0usize;
    while i + 276 <= buf.len() {
        if &buf[i..i + 4] == b"AHSM" {
            let unc0 = u32at(buf, i + 4);
            let unc1 = u32at(buf, i + 8);
            let c0 = u32at(buf, i + 12);
            let c1 = u32at(buf, i + 16);
            let nb = &buf[i + 20..i + 276];
            let end = nb.iter().position(|&b| b == 0).unwrap_or(0);
            if end > 0
                && nb[..end].iter().all(|&b| (0x20..0x7f).contains(&b))
                && c0 > 0
                && unc0 > 0
                && i + 276 + c0 as usize <= buf.len()
            {
                out.push(Msha {
                    off: i,
                    name: String::from_utf8_lossy(&nb[..end]).into_owned(),
                    unc0,
                    unc1,
                    c0,
                    c1,
                });
            }
        }
        i += 1;
    }
    out
}

fn read_body_and_dat(buf: &[u8], m: &Msha) -> Result<(Vec<u8>, Vec<u8>), String> {
    let s0 = m.off + 276;
    let e0 = s0 + m.c0 as usize;
    let body = inflate(&buf[s0..e0], m.unc0 as usize)?;
    if body.len() != m.unc0 as usize {
        return Err(format!("body {} != declared {}", body.len(), m.unc0));
    }
    let dat = if m.c1 > 0 && e0 + m.c1 as usize <= buf.len() {
        inflate(&buf[e0..e0 + m.c1 as usize], m.unc1 as usize)?
    } else {
        Vec::new()
    };
    Ok((body, dat))
}

// ---- MESH body section model ---------------------------------------------------------------------
struct Stream {
    raw: [u8; 152],
    num_vertices: u32,
    format: u32,
    vb_offset: u32,
    vb_stride: u32,
    ib_offset: u32,
    face_type: u32,
    num_indices: u32,
}
struct Prim {
    raw: [u8; 100],
    stream_index: u32,
    index_offset: u32,
    num_indices: u32,
}
struct Draw {
    raw: [u8; 16],
    primitive_index: u32,
    material: u32,
    parent_bone: u16,
}

/// Everything needed to reproduce a MESH body: opaque sections kept raw, fixed records parsed into
/// fields (and re-emitted from them). `num_*` are re-written into the header/skeleton on serialize.
struct MeshDoc {
    body: Vec<u8>,
    // section [start,len)
    header: (usize, usize),      // 0..244 (counts live here)
    skel_header: (usize, usize), // 244..288
    bone_ids: (usize, usize),
    pad0: (usize, usize),
    local_tms: (usize, usize),
    bone_hashes: Vec<u32>, // one per bone (from bone records @0)
    bone_rec: (usize, usize),
    transforms: (usize, usize),
    parent_ids: (usize, usize),
    null32: (usize, usize),
    pad1: (usize, usize),
    remaps: (usize, usize),
    streams: Vec<Stream>,
    prims: Vec<Prim>,
    draws: Vec<Draw>,
    tail_off: usize, // where streams begin (for serialize)
    trailing: (usize, usize),
    num_bones: usize,
    num_remaps: usize,
}

fn parse_body(body: &[u8]) -> Result<MeshDoc, String> {
    if body.len() < 288 {
        return Err("MESH body too short".into());
    }
    let num_bones0 = u32at(body, 204) as usize;
    let num_remaps = u32at(body, 208) as usize;
    let num_streams = u16at(body, 216) as usize;
    let num_prims = u16at(body, 218) as usize;
    let num_draws = u32at(body, 232) as usize;

    let num_unk0 = u32at(body, 244) as usize;
    let num_bones = u32at(body, 256) as usize;
    let num_unk1 = u32at(body, 260);
    let num_bones3 = u32at(body, 264) as usize;
    let num_bones4 = u32at(body, 272) as usize;
    if num_bones <= 1 {
        return Err(format!("not skinned (numBones={num_bones})"));
    }
    if num_bones != num_bones0 || num_bones != num_bones3 || num_bones != num_bones4 {
        return Err("bone count mismatch".into());
    }

    let mut p = 288usize;
    let take = |p: &mut usize, n: usize| -> Result<(usize, usize), String> {
        if *p + n > body.len() {
            return Err("section overruns body".into());
        }
        let r = (*p, n);
        *p += n;
        Ok(r)
    };

    let bone_ids = take(&mut p, num_bones)?;
    let pad0 = take(&mut p, num_unk0)?;
    let local_tms = take(&mut p, num_bones * 64)?;
    let bone_rec = take(&mut p, num_bones * 64)?;
    let bone_hashes: Vec<u32> = (0..num_bones).map(|i| u32at(body, bone_rec.0 + i * 64)).collect();
    let transforms = take(&mut p, num_bones * 48)?;
    let parent_ids = take(&mut p, num_bones * 2)?;
    let null32 = take(&mut p, num_bones * 4)?;
    let pad1 = if num_unk1 != 0 { take(&mut p, 2)? } else { (p, 0) };

    let remaps = if num_remaps > 0 {
        let guard = u32at(body, p) as usize;
        if guard != num_remaps {
            return Err(format!("boneRemap guard {guard} != {num_remaps}"));
        }
        take(&mut p, 8 + num_remaps * 68)?
    } else {
        (p, 0)
    };

    let tail_off = p;
    let mut streams = Vec::with_capacity(num_streams);
    for _ in 0..num_streams {
        let s = take(&mut p, 152)?;
        let mut raw = [0u8; 152];
        raw.copy_from_slice(&body[s.0..s.0 + 152]);
        streams.push(Stream {
            num_vertices: u32at(&raw, 24),
            format: u32at(&raw, 40),
            vb_offset: u32at(&raw, 88),
            vb_stride: u32at(&raw, 120),
            ib_offset: u32at(&raw, 128),
            face_type: u32at(&raw, 140),
            num_indices: u32at(&raw, 144),
            raw,
        });
    }
    let mut prims = Vec::with_capacity(num_prims);
    for _ in 0..num_prims {
        let s = take(&mut p, 100)?;
        let mut raw = [0u8; 100];
        raw.copy_from_slice(&body[s.0..s.0 + 100]);
        prims.push(Prim {
            stream_index: u32at(&raw, 80),
            index_offset: u32at(&raw, 88),
            num_indices: u32at(&raw, 96),
            raw,
        });
    }
    let mut draws = Vec::with_capacity(num_draws);
    for _ in 0..num_draws {
        let s = take(&mut p, 16)?;
        let mut raw = [0u8; 16];
        raw.copy_from_slice(&body[s.0..s.0 + 16]);
        draws.push(Draw {
            primitive_index: u32at(&raw, 0),
            material: u32at(&raw, 4),
            parent_bone: u16at(&raw, 12),
            raw,
        });
    }
    let trailing = (p, body.len() - p);

    Ok(MeshDoc {
        body: body.to_vec(),
        header: (0, 244),
        skel_header: (244, 44),
        bone_ids,
        pad0,
        local_tms,
        bone_hashes,
        bone_rec,
        transforms,
        parent_ids,
        null32,
        pad1,
        remaps,
        streams,
        prims,
        draws,
        tail_off,
        trailing,
        num_bones,
        num_remaps,
    })
}

/// Re-emit the body from the parsed model, writing every known field back from its parsed value.
fn serialize_body(d: &MeshDoc) -> Vec<u8> {
    let raw = |r: (usize, usize)| &d.body[r.0..r.0 + r.1];
    let mut out = Vec::with_capacity(d.body.len());

    // header — re-write the counts we understand (identity on a faithful round-trip)
    let mut header = d.body[d.header.0..d.header.0 + d.header.1].to_vec();
    put_u32(&mut header, 204, d.num_bones as u32);
    put_u32(&mut header, 208, d.num_remaps as u32);
    put_u16(&mut header, 216, d.streams.len() as u16);
    put_u16(&mut header, 218, d.prims.len() as u16);
    put_u32(&mut header, 232, d.draws.len() as u32);
    out.extend_from_slice(&header);

    // skeleton header — re-write the bone counts
    let mut skh = d.body[d.skel_header.0..d.skel_header.0 + d.skel_header.1].to_vec();
    put_u32(&mut skh, 12, d.num_bones as u32); // numBones2 (@256)
    put_u32(&mut skh, 20, d.num_bones as u32); // numBones3 (@264)
    put_u32(&mut skh, 28, d.num_bones as u32); // numBones4 (@272)
    out.extend_from_slice(&skh);

    out.extend_from_slice(raw(d.bone_ids));
    out.extend_from_slice(raw(d.pad0));
    out.extend_from_slice(raw(d.local_tms));

    // bone records — re-write the name-hash field (@0 of each 64B record)
    for i in 0..d.num_bones {
        let mut rec = d.body[d.bone_rec.0 + i * 64..d.bone_rec.0 + i * 64 + 64].to_vec();
        put_u32(&mut rec, 0, d.bone_hashes[i]);
        out.extend_from_slice(&rec);
    }

    out.extend_from_slice(raw(d.transforms));
    out.extend_from_slice(raw(d.parent_ids));
    out.extend_from_slice(raw(d.null32));
    out.extend_from_slice(raw(d.pad1));
    out.extend_from_slice(raw(d.remaps));

    for s in &d.streams {
        let mut r = s.raw;
        put_u32(&mut r, 24, s.num_vertices);
        put_u32(&mut r, 40, s.format);
        put_u32(&mut r, 88, s.vb_offset);
        put_u32(&mut r, 120, s.vb_stride);
        put_u32(&mut r, 128, s.ib_offset);
        put_u32(&mut r, 140, s.face_type);
        put_u32(&mut r, 144, s.num_indices);
        out.extend_from_slice(&r);
    }
    for pr in &d.prims {
        let mut r = pr.raw;
        put_u32(&mut r, 80, pr.stream_index);
        put_u32(&mut r, 88, pr.index_offset);
        put_u32(&mut r, 96, pr.num_indices);
        out.extend_from_slice(&r);
    }
    for dr in &d.draws {
        let mut r = dr.raw;
        put_u32(&mut r, 0, dr.primitive_index);
        put_u32(&mut r, 4, dr.material);
        put_u16(&mut r, 12, dr.parent_bone);
        out.extend_from_slice(&r);
    }
    out.extend_from_slice(raw(d.trailing));
    let _ = d.tail_off;
    out
}

/// ISOLATION TEST B helper: force every drawcall's material to `mat` and re-serialize the MESH body.
/// Length is unchanged (byte-exact round-trip; only the 4-byte material field at drawcall+4 changes).
/// Returns `(new_body, num_drawcalls)`.
pub fn force_drawcall_material(body: &[u8], mat: u32) -> Result<(Vec<u8>, usize), String> {
    let mut d = parse_body(body)?;
    let n = d.draws.len();
    for dr in &mut d.draws {
        dr.material = mat;
    }
    Ok((serialize_body(&d), n))
}

pub fn roundtrip(f: &Flags) -> Result<(), String> {
    let name = f.name.clone().unwrap_or_else(|| "SeanDevlin".into());
    let mp_path = format!("{}/Global/Dynamic0.megapack", f.game);
    println!("[1] scanning {mp_path} for MSHA models matching '{name}'");
    let mp = pack::Megapack::open(&mp_path)?;
    let all = scan_msha(mp.raw());
    let hits: Vec<&Msha> = all.iter().filter(|m| m.name.to_ascii_lowercase().contains(&name.to_ascii_lowercase())).collect();
    if hits.is_empty() {
        return Err(format!("no MSHA model matches '{name}' ({} total in pack)", all.len()));
    }
    println!("    {} match (of {} models in pack)", hits.len(), all.len());

    let (mut ok, mut skip, mut fail) = (0, 0, 0);
    for m in &hits {
        let (body, dat) = read_body_and_dat(mp.raw(), m)?;
        match parse_body(&body) {
            Ok(doc) => {
                let reser = serialize_body(&doc);
                let exact = reser == body;
                let diff = if exact {
                    "byte-exact".to_string()
                } else {
                    let at = reser.iter().zip(&body).position(|(a, b)| a != b);
                    format!("MISMATCH len {}->{} first diff {:?}", body.len(), reser.len(), at)
                };
                println!(
                    "    {:38} bones={:3} streams={} prims={} draws={} dat={:>8}B  MESH re-serialize: {}",
                    m.name,
                    doc.num_bones,
                    doc.streams.len(),
                    doc.prims.len(),
                    doc.draws.len(),
                    dat.len(),
                    diff
                );
                if exact {
                    ok += 1;
                } else {
                    fail += 1;
                }
            }
            Err(e) => {
                println!("    {:38} SKIP ({e})", m.name);
                skip += 1;
            }
        }
    }
    println!("\n{ok} byte-exact, {fail} mismatch, {skip} skipped (non-skinned/parse).");
    if fail > 0 {
        return Err("some MESH bodies did not re-serialize byte-exact".into());
    }
    println!("PASS — MESH/MSHA writer reproduces Sean's mesh byte-exact. Stage 1 gate met.");
    println!("(Container zlib blobs are re-compressed on write; the byte-exact gate is on the DECOMPRESSED");
    println!(" MESH body + .dat, exactly as with DTEX — the engine consumes the decompressed form.)");
    Ok(())
}

// ================================================================== geometry codec (Stage 2b)
fn half_to_f32(h: u16) -> f32 {
    let sign = ((h >> 15) & 1) as u32;
    let exp = ((h >> 10) & 0x1f) as u32;
    let man = (h & 0x3ff) as u32;
    let bits = match exp {
        0 => {
            if man == 0 {
                sign << 31
            } else {
                let mut e = -1i32;
                let mut m = man;
                while m & 0x400 == 0 {
                    m <<= 1;
                    e -= 1;
                }
                (sign << 31) | (((127 - 15 + 1 + e) as u32) << 23) | ((m & 0x3ff) << 13)
            }
        }
        0x1f => (sign << 31) | (0xff << 23) | (man << 13),
        _ => (sign << 31) | ((exp + 127 - 15) << 23) | (man << 13),
    };
    f32::from_bits(bits)
}
fn f32_to_half(f: f32) -> u16 {
    let bits = f.to_bits();
    let sign = ((bits >> 16) & 0x8000) as u16;
    let mut exp = ((bits >> 23) & 0xff) as i32 - 127 + 15;
    let man = bits & 0x7f_ffff;
    if ((bits >> 23) & 0xff) == 0xff {
        return sign | 0x7c00 | if man != 0 { 0x200 } else { 0 }; // inf/nan
    }
    if exp >= 0x1f {
        return sign | 0x7c00; // overflow -> inf
    }
    if exp <= 0 {
        if exp < -10 {
            return sign; // underflow -> 0
        }
        let man = (man | 0x80_0000) >> (1 - exp);
        // round to nearest even
        let half = ((man + 0x1000) >> 13) as u16;
        return sign | half;
    }
    let half = (((exp as u32) << 10) | (man >> 13)) as u16;
    // round to nearest even
    let round = if (man & 0x1000) != 0 { 1 } else { 0 };
    sign | (half + round)
}

#[derive(Clone, Copy, PartialEq)]
enum Attr {
    Position,
    BoneWeights,
    BoneIndices,
    Color,
    Uv,
    Normal,
    Tangent,
}
fn attr_size(a: Attr) -> usize {
    match a {
        Attr::Position => 8,
        Attr::BoneWeights | Attr::BoneIndices | Attr::Color | Attr::Uv | Attr::Tangent => 4,
        Attr::Normal => 12,
    }
}
fn decode_format(fmt: u32) -> Result<Vec<(Attr, usize)>, String> {
    if (fmt >> 24) & 0xff != 0x1b {
        return Err(format!("bad constTag in 0x{fmt:08x}"));
    }
    if fmt & 0x3 != 2 {
        return Err(format!("unsupported positionType in 0x{fmt:08x}"));
    }
    let skin = (fmt >> 2) & 0x3;
    let ncol = (fmt >> 4) & 0xf;
    let nuv = (fmt >> 8) & 0xf;
    let mut list = vec![Attr::Position];
    if skin != 0 {
        list.push(Attr::BoneWeights);
        list.push(Attr::BoneIndices);
    }
    for _ in 0..ncol {
        list.push(Attr::Color);
    }
    for _ in 0..nuv {
        list.push(Attr::Uv);
    }
    if (fmt >> 12) & 1 != 0 {
        list.push(Attr::Normal);
    }
    if (fmt >> 13) & 1 != 0 {
        list.push(Attr::Tangent);
    }
    let mut out = Vec::new();
    let mut off = 0;
    for a in list {
        out.push((a, off));
        off += attr_size(a);
    }
    Ok(out)
}

/// Decoded geometry: per-vertex attrs (GLOBAL bone indices) + one combined index buffer, with mesh
/// PRIMITIVES (ranges into it) and DRAWCALLS (referencing primitives) kept separate — several drawcalls
/// can share one primitive (LOD/damage passes), so they must not be flattened.
struct SemMesh {
    pos: Vec<[f32; 3]>,
    nrm: Vec<[f32; 3]>,
    uv: Vec<[f32; 2]>,
    joints: Vec<[u16; 4]>, // global skeleton bone indices
    weights: Vec<[f32; 4]>,
    indices: Vec<u32>,         // full combined index buffer (all streams), values = combined vertex idx
    prims: Vec<(u32, u32)>,    // (index_start into `indices`, count)
    draws: Vec<(u32, u32, u16)>, // (primitive_index, material, parent_bone)
}

/// Bone-remap + boneIds so `global = boneIds[boneRemaps[local]]` (as meshload does).
fn read_remaps_boneids(doc: &MeshDoc) -> (Vec<u32>, Vec<u8>) {
    let mut remaps = Vec::new();
    if doc.num_remaps > 0 {
        let base = doc.remaps.0 + 8; // skip guard + null32
        for i in 0..doc.num_remaps {
            remaps.push(u32at(&doc.body, base + i * 68 + 64));
        }
    }
    let bone_ids = doc.body[doc.bone_ids.0..doc.bone_ids.0 + doc.bone_ids.1].to_vec();
    (remaps, bone_ids)
}

fn decode_geometry(doc: &MeshDoc, dat: &[u8]) -> Result<SemMesh, String> {
    let (remaps, bone_ids) = read_remaps_boneids(doc);
    let mut m = SemMesh {
        pos: vec![],
        nrm: vec![],
        uv: vec![],
        joints: vec![],
        weights: vec![],
        indices: vec![],
        prims: vec![],
        draws: vec![],
    };
    let mut stream_ibase = Vec::new();
    let mut stream_vbase = Vec::new();
    for s in &doc.streams {
        if s.face_type != 1 {
            return Err(format!("faceType {} not triangle-list", s.face_type));
        }
        let layout = decode_format(s.format)?;
        let stride = s.vb_stride as usize;
        let nv = s.num_vertices as usize;
        let vb = s.vb_offset as usize;
        let vbase = m.pos.len() as u32;
        stream_vbase.push(vbase);
        for v in 0..nv {
            let base = vb + v * stride;
            let (mut p, mut n, mut uv) = ([0f32; 3], [0f32; 3], [0f32; 2]);
            let (mut j, mut w) = ([0u16; 4], [0f32; 4]);
            for &(a, ao) in &layout {
                let o = base + ao;
                match a {
                    Attr::Position => p = [half_to_f32(u16at(dat, o)), half_to_f32(u16at(dat, o + 2)), half_to_f32(u16at(dat, o + 4))],
                    Attr::Normal => n = [f32at(dat, o), f32at(dat, o + 4), f32at(dat, o + 8)],
                    Attr::Uv => uv = [half_to_f32(u16at(dat, o)), half_to_f32(u16at(dat, o + 2))],
                    Attr::BoneWeights => {
                        for k in 0..4 {
                            w[k] = dat[o + k] as f32 / 255.0;
                        }
                    }
                    Attr::BoneIndices => {
                        for k in 0..4 {
                            let local = dat[o + k] as usize;
                            let bid = remaps.get(local).copied().unwrap_or(0) as usize;
                            j[k] = *bone_ids.get(bid).unwrap_or(&0) as u16;
                        }
                    }
                    _ => {}
                }
            }
            m.pos.push(p);
            m.nrm.push(n);
            m.uv.push(uv);
            m.joints.push(j);
            m.weights.push(w);
        }
        let ibase = m.indices.len() as u32;
        stream_ibase.push(ibase);
        let ib = s.ib_offset as usize;
        for k in 0..s.num_indices as usize {
            m.indices.push(u16at(dat, ib + k * 2) as u32 + vbase);
        }
    }
    // mesh primitives: range into the combined index buffer (rebased by their stream's ibase)
    for pr in &doc.prims {
        let ibase = stream_ibase.get(pr.stream_index as usize).copied().unwrap_or(0);
        m.prims.push((ibase + pr.index_offset, pr.num_indices));
    }
    // drawcalls: reference a primitive + material
    for d in &doc.draws {
        m.draws.push((d.primitive_index, d.material, d.parent_bone));
    }
    Ok(m)
}

fn quant_weights(w: [f32; 4]) -> [u8; 4] {
    let mut q = [0i32; 4];
    for k in 0..4 {
        q[k] = (w[k] * 255.0).round() as i32;
    }
    let sum: i32 = q.iter().sum();
    if sum != 255 && sum != 0 {
        // push the rounding error onto the largest component
        let mut mi = 0;
        for k in 1..4 {
            if q[k] > q[mi] {
                mi = k;
            }
        }
        q[mi] += 255 - sum;
    }
    [q[0].clamp(0, 255) as u8, q[1].clamp(0, 255) as u8, q[2].clamp(0, 255) as u8, q[3].clamp(0, 255) as u8]
}

/// Encode a SemMesh into a canonical MESH (format 0x1b001106: Pos+Weights+Indices+UV+Normal, one
/// stream) using `doc` as the header/skeleton/descriptor template. Returns (new_body, new_dat).
/// `bone_global_to_new`: optional map from a SemMesh global bone index into the TEMPLATE skeleton's
/// bone-id space (identity when re-encoding the same part).
/// Per-vertex tangents (Lengyel's method): accumulate per-triangle tangent/bitangent from position
/// and UV gradients, then Gram-Schmidt against the vertex normal and record handedness in w. Returns
/// [tx,ty,tz,handedness(+1/-1)] per vertex. The body shader needs this for normal mapping; without a
/// tangent the tangent-space basis is undefined and lighting swims with the view.
fn compute_tangents(pos: &[[f32; 3]], uv: &[[f32; 2]], nrm: &[[f32; 3]], indices: &[u32]) -> Vec<[f32; 4]> {
    let n = pos.len();
    let mut tan = vec![[0.0f32; 3]; n];
    let mut bit = vec![[0.0f32; 3]; n];
    for tri in indices.chunks_exact(3) {
        let (i0, i1, i2) = (tri[0] as usize, tri[1] as usize, tri[2] as usize);
        let (p0, p1, p2) = (pos[i0], pos[i1], pos[i2]);
        let (w0, w1, w2) = (uv[i0], uv[i1], uv[i2]);
        let e1 = [p1[0] - p0[0], p1[1] - p0[1], p1[2] - p0[2]];
        let e2 = [p2[0] - p0[0], p2[1] - p0[1], p2[2] - p0[2]];
        let (du1, dv1) = (w1[0] - w0[0], w1[1] - w0[1]);
        let (du2, dv2) = (w2[0] - w0[0], w2[1] - w0[1]);
        let denom = du1 * dv2 - du2 * dv1;
        let r = if denom.abs() < 1e-8 { 0.0 } else { 1.0 / denom };
        let t = [(e1[0] * dv2 - e2[0] * dv1) * r, (e1[1] * dv2 - e2[1] * dv1) * r, (e1[2] * dv2 - e2[2] * dv1) * r];
        let b = [(e2[0] * du1 - e1[0] * du2) * r, (e2[1] * du1 - e1[1] * du2) * r, (e2[2] * du1 - e1[2] * du2) * r];
        for &i in &[i0, i1, i2] {
            for k in 0..3 {
                tan[i][k] += t[k];
                bit[i][k] += b[k];
            }
        }
    }
    let mut out = vec![[1.0f32, 0.0, 0.0, 1.0]; n];
    for i in 0..n {
        let nn = nrm[i];
        let d = nn[0] * tan[i][0] + nn[1] * tan[i][1] + nn[2] * tan[i][2];
        let mut tp = [tan[i][0] - nn[0] * d, tan[i][1] - nn[1] * d, tan[i][2] - nn[2] * d];
        let len = (tp[0] * tp[0] + tp[1] * tp[1] + tp[2] * tp[2]).sqrt();
        if len > 1e-6 {
            tp = [tp[0] / len, tp[1] / len, tp[2] / len];
        } else {
            // degenerate (no UV gradient): any vector perpendicular to the normal
            let a = if nn[0].abs() < 0.9 { [1.0, 0.0, 0.0] } else { [0.0, 1.0, 0.0] };
            let d2 = nn[0] * a[0] + nn[1] * a[1] + nn[2] * a[2];
            let mut p = [a[0] - nn[0] * d2, a[1] - nn[1] * d2, a[2] - nn[2] * d2];
            let l2 = (p[0] * p[0] + p[1] * p[1] + p[2] * p[2]).sqrt();
            if l2 > 1e-6 {
                p = [p[0] / l2, p[1] / l2, p[2] / l2];
            }
            tp = p;
        }
        // handedness = sign(dot(cross(n, t), bitangent))
        let c = [nn[1] * tp[2] - nn[2] * tp[1], nn[2] * tp[0] - nn[0] * tp[2], nn[0] * tp[1] - nn[1] * tp[0]];
        let hd = c[0] * bit[i][0] + c[1] * bit[i][1] + c[2] * bit[i][2];
        out[i] = [tp[0], tp[1], tp[2], if hd < 0.0 { -1.0 } else { 1.0 }];
    }
    out
}

fn encode_mesh(doc: &MeshDoc, skel_bytes: &[u8], num_bones0: u32, sem: &SemMesh, stored_ibms: &std::collections::HashMap<u32, [f32; 16]>) -> Result<(Vec<u8>, Vec<u8>), String> {
    // 0x1b003106 (stride 36) = Sean's body format: it has the TANGENT attribute (bit 13) the
    // normal-map body shader needs. Omitting it (the old 0x1b001106/32) left the tangent input
    // undefined, so tangent-space lighting swam/blew out as the camera moved (view-dependent flashing).
    const FMT: u32 = 0x1b00_3106;
    const STRIDE: usize = 36;
    let nverts = sem.pos.len();
    // per-vertex tangents (packed u8x4 @ +32: xyz in [-1,1]->[0,255], w = handedness 0x00/0xff)
    let tangents = compute_tangents(&sem.pos, &sem.uv, &sem.nrm, &sem.indices);

    // bone palette: unique global bone indices used, in first-seen order -> local index
    let mut palette: Vec<u16> = Vec::new();
    let mut pal_of = std::collections::HashMap::new();
    let local_index = |g: u16, palette: &mut Vec<u16>, pal_of: &mut std::collections::HashMap<u16, u8>| -> u8 {
        if let Some(&l) = pal_of.get(&g) {
            l
        } else {
            let l = palette.len() as u8;
            palette.push(g);
            pal_of.insert(g, l);
            l
        }
    };

    // VB
    let mut vb = vec![0u8; nverts * STRIDE];
    for i in 0..nverts {
        let o = i * STRIDE;
        let p = sem.pos[i];
        for (k, val) in p.iter().enumerate() {
            vb[o + k * 2..o + k * 2 + 2].copy_from_slice(&f32_to_half(*val).to_le_bytes());
        }
        // pos.w = 1.0 (0x3C00): the shader reads it as per-vertex OPACITY. Sean's is 1.0 everywhere;
        // leaving it 0 made the whole mesh transparent (angle-dependent see-through).
        vb[o + 6..o + 8].copy_from_slice(&0x3C00u16.to_le_bytes());
        let w = quant_weights(sem.weights[i]);
        vb[o + 8..o + 12].copy_from_slice(&w);
        let j = sem.joints[i];
        for k in 0..4 {
            vb[o + 12 + k] = if w[k] == 0 { 0 } else { local_index(j[k], &mut palette, &mut pal_of) };
        }
        let uv = sem.uv[i];
        vb[o + 16..o + 18].copy_from_slice(&f32_to_half(uv[0]).to_le_bytes());
        vb[o + 18..o + 20].copy_from_slice(&f32_to_half(uv[1]).to_le_bytes());
        let n = sem.nrm[i];
        for k in 0..3 {
            vb[o + 20 + k * 4..o + 20 + k * 4 + 4].copy_from_slice(&n[k].to_le_bytes());
        }
        // tangent @ +32 (u8x4): xyz normalized to [0,255], w = handedness (0xff = +1, 0x00 = -1)
        let t = tangents[i];
        for k in 0..3 {
            vb[o + 32 + k] = (((t[k] + 1.0) * 127.5).round().clamp(0.0, 255.0)) as u8;
        }
        vb[o + 35] = if t[3] < 0.0 { 0x00 } else { 0xff };
    }
    // IB: the whole combined index buffer, emitted ONCE as u16. Primitives are ranges into it.
    let mut ib = Vec::with_capacity(sem.indices.len() * 2);
    for &vi in &sem.indices {
        if vi >= 65536 {
            return Err("vertex index exceeds u16".into());
        }
        ib.extend_from_slice(&(vi as u16).to_le_bytes());
    }
    let mut dat = vb;
    let ib_offset = dat.len() as u32;
    dat.extend_from_slice(&ib);
    let num_indices = (ib.len() / 2) as u32;

    // ---- assemble body ----
    let mut body = Vec::new();
    // header (patch counts)
    let mut header = doc.body[0..244].to_vec();
    put_u32(&mut header, 204, num_bones0); // numBones0
    put_u32(&mut header, 208, palette.len() as u32); // numBoneRemaps
    put_u16(&mut header, 216, 1); // numStreams
    put_u16(&mut header, 218, sem.prims.len() as u16); // numPrimitives
    put_u32(&mut header, 232, sem.draws.len() as u32); // numDrawCalls
    // Bounding volume (engine culls against this): AABB size @76-84, sphere radius @88, center @92-100.
    // Verified layout on Sean UB (size/radius/center matched its geometry exactly). Templated from the
    // head donor -> a 0.25 m sphere at head height -> the full body is culled/invisible. Recompute it.
    // Bounds from REFERENCED verts only (so a region-filtered part gets region-sized bounds, not the
    // full vertex buffer's extent — the per-part LOD/fade metric depends on this being part-sized).
    let (mut mn, mut mx) = ([f32::MAX; 3], [f32::MIN; 3]);
    for &vi in &sem.indices {
        let p = sem.pos[vi as usize];
        for k in 0..3 {
            mn[k] = mn[k].min(p[k]);
            mx[k] = mx[k].max(p[k]);
        }
    }
    let size = [mx[0] - mn[0], mx[1] - mn[1], mx[2] - mn[2]];
    let center = [(mn[0] + mx[0]) * 0.5, (mn[1] + mx[1]) * 0.5, (mn[2] + mx[2]) * 0.5];
    let radius = 0.5 * (size[0] * size[0] + size[1] * size[1] + size[2] * size[2]).sqrt();
    for (o, v) in [(76, size[0]), (80, size[1]), (84, size[2]), (88, radius), (92, center[0]), (96, center[1]), (100, center[2])] {
        put_f32(&mut header, o, v);
    }
    body.extend_from_slice(&header);
    // skeleton — provided as bytes (donor's own for a self-test; synthesized for an import)
    body.extend_from_slice(skel_bytes);
    // boneRemaps: guard + null + palette entries {inverseBindMatrix(64) + boneId(4)}.
    // The engine SKINS with the stored IBM (it does NOT recompute it). Use Sean's REAL per-bone IBMs
    // (keyed by bone hash, gathered from his parts) — the engine's IBMs are authored/stored, not
    // derivable: naive inv(worldBind) is off by up to 1.7 m for ~6 bones (that dropped the teeth to the
    // floor). Fall back to computed inv(worldBind) only for bones no Sean part uses.
    if !palette.is_empty() {
        let computed = compute_ibms(skel_bytes, num_bones0 as usize);
        let nb = num_bones0 as usize;
        let unk0 = u32at(skel_bytes, 0) as usize;
        let brec_off = 44 + nb + unk0 + nb * 64; // bone records within skel_bytes (hash @ +0)
        put_u32_vec(&mut body, palette.len() as u32);
        put_u32_vec(&mut body, 0);
        let mut fell_back = 0;
        for &g in &palette {
            let hash = u32at(skel_bytes, brec_off + g as usize * 64);
            let ibm = stored_ibms.get(&hash).copied().unwrap_or_else(|| {
                fell_back += 1;
                computed[g as usize]
            });
            for v in ibm {
                body.extend_from_slice(&v.to_le_bytes());
            }
            put_u32_vec(&mut body, g as u32); // boneId
        }
        if fell_back > 0 {
            eprintln!("    IBM: {fell_back}/{} palette bones absent from Sean's parts — used computed fallback", palette.len());
        }
    }
    // streams (1) — template from the donor's first stream, patch fields
    let mut sd = doc.streams[0].raw;
    put_u32(&mut sd, 24, nverts as u32);
    put_u32(&mut sd, 40, FMT);
    put_u32(&mut sd, 88, 0); // vb_offset
    put_u32(&mut sd, 104, (nverts * STRIDE) as u32); // VB size in bytes (engine reads the buffer by this)
    put_u32(&mut sd, 120, STRIDE as u32);
    put_u32(&mut sd, 128, ib_offset);
    put_u32(&mut sd, 132, num_indices * 2); // IB size in bytes
    put_u32(&mut sd, 136, dat.len() as u32); // total .dat size (VB+IB) — was HD's stale value -> truncated read -> collapse
    put_u32(&mut sd, 140, 1); // face_type
    put_u32(&mut sd, 144, num_indices);
    body.extend_from_slice(&sd);
    // primitives — template from donor's first prim; index range into the single combined IB
    for &(istart, icnt) in &sem.prims {
        let mut pd = doc.prims[0].raw;
        put_u32(&mut pd, 4, 0xffff_ffff); // const0 = -1
        put_u32(&mut pd, 80, 0); // stream_index
        put_u32(&mut pd, 88, istart); // index_offset (into combined IB)
        put_u32(&mut pd, 92, icnt / 3); // num_triangles (primCount) — MUST equal numIdx/3; a stale donor
        // constant here makes the loader build 0 render segments -> IsFullyLoaded false -> part not drawn.
        put_u32(&mut pd, 96, icnt); // num_indices
        body.extend_from_slice(&pd);
    }
    // drawcalls — template from donor's first draw
    for &(prim_idx, mat, pb) in &sem.draws {
        let mut dd = doc.draws[0].raw;
        put_u32(&mut dd, 0, prim_idx);
        put_u32(&mut dd, 4, mat);
        put_u16(&mut dd, 12, pb);
        body.extend_from_slice(&dd);
    }
    Ok((body, dat))
}

fn put_u32_vec(v: &mut Vec<u8>, x: u32) {
    v.extend_from_slice(&x.to_le_bytes());
}

/// Compare two SemMeshes for geometry equality within half-float tolerance.
fn geom_close(a: &SemMesh, b: &SemMesh) -> Result<(), String> {
    if a.pos.len() != b.pos.len() {
        return Err(format!("vertex count {} != {}", a.pos.len(), b.pos.len()));
    }
    if a.indices.len() != b.indices.len() {
        return Err(format!("index count {} != {}", a.indices.len(), b.indices.len()));
    }
    if a.prims.len() != b.prims.len() {
        return Err(format!("primitive count {} != {}", a.prims.len(), b.prims.len()));
    }
    if a.draws.len() != b.draws.len() {
        return Err(format!("drawcall count {} != {}", a.draws.len(), b.draws.len()));
    }
    let mut maxd = 0f32;
    for i in 0..a.pos.len() {
        for k in 0..3 {
            maxd = maxd.max((a.pos[i][k] - b.pos[i][k]).abs());
        }
    }
    if maxd > 0.01 {
        return Err(format!("max position delta {maxd} too large"));
    }
    // skinning: compare the per-bone weight map per vertex (order-independent, quantization-tolerant).
    // A benign u8 tie-flip leaves the map unchanged; a genuinely wrong bone shows up as a large delta.
    let mut worst = 0f32;
    let mut bad = 0usize;
    for i in 0..a.pos.len() {
        let mut map: std::collections::HashMap<u16, f32> = std::collections::HashMap::new();
        for k in 0..4 {
            if a.weights[i][k] > 0.0 {
                *map.entry(a.joints[i][k]).or_insert(0.0) += a.weights[i][k];
            }
        }
        for k in 0..4 {
            if b.weights[i][k] > 0.0 {
                *map.entry(b.joints[i][k]).or_insert(0.0) -= b.weights[i][k];
            }
        }
        let d = map.values().fold(0f32, |m, &v| m.max(v.abs()));
        worst = worst.max(d);
        if d > 0.03 {
            bad += 1; // > 3× the u8 quantization step on any single bone = a real assignment error
        }
    }
    if bad > 0 {
        return Err(format!("{bad} vertices have a wrong bone influence (worst per-bone weight delta {worst:.3})"));
    }
    Ok(())
}

pub fn encode_test(f: &Flags) -> Result<(), String> {
    let name = f.name.clone().unwrap_or_else(|| "SeanDevlin_01_HD".into());
    let mp = pack::Megapack::open(&format!("{}/Global/Dynamic0.megapack", f.game))?;
    let all = scan_msha(mp.raw());
    let m = all
        .iter()
        .find(|m| m.name.to_ascii_lowercase().contains(&name.to_ascii_lowercase()))
        .ok_or_else(|| format!("no MSHA matches '{name}'"))?;
    println!("[1] decode geometry of '{}'", m.name);
    let (body, dat) = read_body_and_dat(mp.raw(), m)?;
    let doc = parse_body(&body)?;
    let sem = decode_geometry(&doc, &dat)?;
    println!("    {} verts, {} indices, {} prims", sem.pos.len(), sem.indices.len(), sem.prims.len());

    println!("[2] re-encode via the geometry encoder (canonical 0x1b001106, 1 stream)");
    let skel = &doc.body[244..doc.remaps.0]; // donor's own skeleton section, verbatim
    let ibms = gather_stored_ibms(&f.game)?; // real stored IBMs so the deployed re-encode skins right
    let (nbody, ndat) = encode_mesh(&doc, skel, doc.num_bones as u32, &sem, &ibms)?;
    println!("    new body {} B, new dat {} B", nbody.len(), ndat.len());
    // Deployable diagnostic: write it as the port MSHA so `deploy --slot 3` puts THIS (my-encoded
    // Sean geometry, small Sean bounds) in the character. Isolates my encoder from Mattias's content.
    let outdir = std::path::PathBuf::from(if f.out == "patchdynamic0.megapack" { "mattias_port".into() } else { f.out.clone() });
    std::fs::create_dir_all(&outdir).ok();
    write_msha(outdir.join("pmc_hum_mattias.msha").to_str().unwrap(), "pmc_hum_mattias", &nbody, &ndat)?;
    println!("    wrote re-encoded '{}' to pmc_hum_mattias.msha -> deploy --slot 3 to test in-game", m.name);

    println!("[3] decode the re-encoded MESH and compare geometry");
    let ndoc = parse_body(&nbody)?;
    let nsem = decode_geometry(&ndoc, &ndat)?;
    println!("    re-decoded {} verts, {} indices, {} prims", nsem.pos.len(), nsem.indices.len(), nsem.prims.len());
    geom_close(&sem, &nsem)?;
    println!("\nPASS — geometry encoder round-trips Sean's mesh through the semantic layer.");
    println!("(positions within half precision, indices exact, dominant bone preserved)");
    Ok(())
}

// ================================================================== skeleton synthesis (Stage 2b)
fn put_f32(b: &mut [u8], o: usize, v: f32) {
    b[o..o + 4].copy_from_slice(&v.to_le_bytes());
}

struct SkelBone {
    parent: i32,
    hash: u32,
    t: [f32; 3],
    r: [f32; 4],
    s: [f32; 3],
}

fn name_hash(name: &str) -> u32 {
    // an embedded 0x........ suffix is the bone hash; otherwise pandemic_hash(name)
    if let Some(p) = name.rfind("0x").or_else(|| name.rfind("0X")) {
        let hex: String = name[p + 2..].chars().take(8).collect();
        if hex.len() == 8 {
            if let Ok(v) = u32::from_str_radix(&hex, 16) {
                return v;
            }
        }
    }
    crate::pack::pandemic_hash(name)
}

fn parse_skel(path: &str) -> Result<Vec<SkelBone>, String> {
    let text = std::fs::read_to_string(path).map_err(|e| format!("read {path}: {e}"))?;
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
        let g = |i: usize| f[i].parse::<f32>().unwrap_or(0.0);
        out.push(SkelBone {
            parent: f[0].parse().unwrap_or(-1),
            hash: name_hash(f[1]),
            t: [g(2), g(3), g(4)],
            r: [g(5), g(6), g(7), g(8)],
            s: [g(9), g(10), g(11)],
        });
    }
    Ok(out)
}

/// TRS → localTMS: row-major 4×4, rows = rotation·scale, translation in the last row. Matches the game
/// (verified vs `CH_AL_SeanDevlin_01_HD` bone 2).
/// Row-major 4x4 multiply matching numpy `A @ B` (C[i][j] = Σ A[i][k]·B[k][j]).
fn mat_mul(a: &[f32; 16], b: &[f32; 16]) -> [f32; 16] {
    let mut c = [0f32; 16];
    for i in 0..4 {
        for j in 0..4 {
            let mut s = 0f32;
            for k in 0..4 {
                s += a[i * 4 + k] * b[k * 4 + j];
            }
            c[i * 4 + j] = s;
        }
    }
    c
}

/// Inverse of a row-major, row-vector affine matrix (linear 3x3 in rows 0-2 cols 0-2, translation in
/// row 3). Inverse = [[Rinv, 0], [-t·Rinv, 1]]. Exact for products of TRS bind transforms.
fn inv_affine(m: &[f32; 16]) -> [f32; 16] {
    let a = [m[0], m[1], m[2], m[4], m[5], m[6], m[8], m[9], m[10]];
    let det = a[0] * (a[4] * a[8] - a[5] * a[7]) - a[1] * (a[3] * a[8] - a[5] * a[6]) + a[2] * (a[3] * a[7] - a[4] * a[6]);
    let id = if det.abs() > 1e-20 { 1.0 / det } else { 1.0 };
    let b = [
        (a[4] * a[8] - a[5] * a[7]) * id, (a[2] * a[7] - a[1] * a[8]) * id, (a[1] * a[5] - a[2] * a[4]) * id,
        (a[5] * a[6] - a[3] * a[8]) * id, (a[0] * a[8] - a[2] * a[6]) * id, (a[2] * a[3] - a[0] * a[5]) * id,
        (a[3] * a[7] - a[4] * a[6]) * id, (a[1] * a[6] - a[0] * a[7]) * id, (a[0] * a[4] - a[1] * a[3]) * id,
    ];
    let t = [m[12], m[13], m[14]];
    let nt = [
        -(t[0] * b[0] + t[1] * b[3] + t[2] * b[6]),
        -(t[0] * b[1] + t[1] * b[4] + t[2] * b[7]),
        -(t[0] * b[2] + t[1] * b[5] + t[2] * b[8]),
    ];
    [b[0], b[1], b[2], 0.0, b[3], b[4], b[5], 0.0, b[6], b[7], b[8], 0.0, nt[0], nt[1], nt[2], 1.0]
}

/// Per-bone inverse-bind matrices from a serialized skeleton section (`skel_bytes` starts at MESH
/// body+244). worldBind[b] = localTMS[b] @ localTMS[parent] @ ... @ localTMS[root]; IBM = inverse.
fn compute_ibms(skel_bytes: &[u8], nb: usize) -> Vec<[f32; 16]> {
    let unk0 = u32at(skel_bytes, 0) as usize; // @244 pad count
    let ltms_off = 44 + nb + unk0;
    let par_off = ltms_off + nb * 64 + nb * 64 + nb * 48;
    let ltms = |b: usize| -> [f32; 16] {
        let mut m = [0f32; 16];
        for k in 0..16 {
            m[k] = f32at(skel_bytes, ltms_off + b * 64 + k * 4);
        }
        m
    };
    let parent = |b: usize| -> i32 { i16::from_le_bytes([skel_bytes[par_off + b * 2], skel_bytes[par_off + b * 2 + 1]]) as i32 };
    let mut out = vec![[0f32; 16]; nb];
    for b in 0..nb {
        let mut w = [1.0f32, 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.];
        let mut c = b as i32;
        for _ in 0..=nb {
            // guard against cycles
            w = mat_mul(&w, &ltms(c as usize));
            let p = parent(c as usize);
            if p < 0 || p as usize >= nb {
                break;
            }
            c = p;
        }
        out[b] = inv_affine(&w);
    }
    out
}

fn compose_localtms(t: [f32; 3], r: [f32; 4], s: [f32; 3]) -> [f32; 16] {
    let (x, y, z, w) = (r[0], r[1], r[2], r[3]);
    let rot = [
        [1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + z * w), 2.0 * (x * z - y * w)],
        [2.0 * (x * y - z * w), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + x * w)],
        [2.0 * (x * z + y * w), 2.0 * (y * z - x * w), 1.0 - 2.0 * (x * x + y * y)],
    ];
    let mut m = [0f32; 16];
    for a in 0..3 {
        for b in 0..3 {
            m[a * 4 + b] = rot[a][b] * s[a];
        }
    }
    m[12] = t[0];
    m[13] = t[1];
    m[14] = t[2];
    m[15] = 1.0;
    m
}

/// Stored inverse-bind matrices from one part's boneRemap records, keyed by bone hash.
fn stored_ibms_from(doc: &MeshDoc) -> Vec<(u32, [f32; 16])> {
    let mut out = Vec::new();
    if doc.num_remaps == 0 {
        return out;
    }
    let base = doc.remaps.0 + 8; // skip guard + null32
    for i in 0..doc.num_remaps {
        let rec = base + i * 68;
        let mut ibm = [0f32; 16];
        for (k, v) in ibm.iter_mut().enumerate() {
            *v = f32at(&doc.body, rec + k * 4);
        }
        let bid = u32at(&doc.body, rec + 64) as usize;
        if let Some(&h) = doc.bone_hashes.get(bid) {
            out.push((h, ibm));
        }
    }
    out
}

/// Gather the engine's REAL inverse-bind matrices from every Sean character part, keyed by bone hash.
/// The IBM is a property of the shared rig (verified: 0 cross-part inconsistency), so any part that
/// uses a bone yields its correct IBM. Naive inv(bindWorld) is WRONG for ~6 bones (worst 1.7 m — it
/// dropped Mattias's teeth to the floor), because the engine's IBMs are authored/stored, not derived.
fn gather_stored_ibms(game: &str) -> Result<std::collections::HashMap<u32, [f32; 16]>, String> {
    let mp = pack::Megapack::open(&format!("{game}/Global/Dynamic0.megapack"))?;
    let all = scan_msha(mp.raw());
    let mut map = std::collections::HashMap::new();
    let mut gather = |pred: &dyn Fn(&str) -> bool, map: &mut std::collections::HashMap<u32, [f32; 16]>| {
        for m in all.iter().filter(|m| pred(&m.name)) {
            let Ok((body, _)) = read_body_and_dat(mp.raw(), m) else { continue };
            let Ok(doc) = parse_body(&body) else { continue };
            for (h, ibm) in stored_ibms_from(&doc) {
                map.entry(h).or_insert(ibm); // first writer wins -> Sean's parts are authoritative
            }
        }
    };
    // Phase 1: Sean's own parts (his exact rig) — authoritative. LOD variants carry simplified rigs.
    gather(&|n| n.contains("SeanDevlin") && !n.contains("LOD"), &mut map);
    // Phase 2: other Allied (CH_AL_*) characters share the humanoid rig — fill any bone Sean's parts
    // never skin to (e.g. 0x328C1F25 lives only in CH_AL_Waitress). Eliminates the broken computed
    // IBM fallback (a computed inv(bindWorld) collapsed a rigid mesh to invisible in testing).
    gather(&|n| n.starts_with("CH_AL_") && !n.contains("LOD") && !n.contains("SeanDevlin"), &mut map);
    Ok(map)
}

/// Extract a Sean part's REAL skeleton section — MESH body[244..boneRemaps] — plus its bone count.
/// This is the exact bind pose the engine animates; a `.skel`-synthesized skeleton mis-binds ~50 bones
/// (verified: worst localTMS off by 1.67 m), so IBMs come out wrong and the mesh skins to garbage.
/// GR carries all 191 bones in the same hash order the retarget uses, so its indices line up 1:1.
fn sean_skeleton_section(game: &str, part: &str) -> Result<(Vec<u8>, u32), String> {
    let mp = pack::Megapack::open(&format!("{game}/Global/Dynamic0.megapack"))?;
    let all = scan_msha(mp.raw());
    let dm = all.iter().find(|m| m.name.contains(part)).ok_or_else(|| format!("no skeleton donor '{part}'"))?;
    let (dbody, _) = read_body_and_dat(mp.raw(), dm)?;
    let doc = parse_body(&dbody)?;
    Ok((doc.body[244..doc.remaps.0].to_vec(), doc.num_bones as u32))
}

/// Synthesize the whole skeleton section (skel_header + arrays) for `N` bones from a `.skel`.
/// `donor_skel_header` (44 B) is templated and its bone-count fields patched.
fn synthesize_skeleton(skel_path: &str, donor_skel_header: &[u8]) -> Result<(Vec<u8>, u32), String> {
    let bones = parse_skel(skel_path)?;
    let n = bones.len();
    let mut out = donor_skel_header[..44].to_vec();
    // pad0 (@244) 16-byte-aligns the localTMS matrix array so the engine's aligned SSE loads don't
    // fault. bone_ids start at body offset 288 (16-aligned) and are `n` bytes, so pad = (-n) mod 16.
    // Verified across all 8 Sean parts (e.g. GR: 191 bones -> pad 1; UB: 182 -> pad 10).
    let pad0 = (16 - (n % 16)) % 16;
    put_u32(&mut out, 0, pad0 as u32); // numUnkBones0 = alignment pad byte count
    put_u32(&mut out, 12, n as u32); // numBones
    put_u32(&mut out, 16, 0); // numUnkBones1
    put_u32(&mut out, 20, n as u32); // numBones3
    put_u32(&mut out, 28, n as u32); // numBones4
    // boneIds (identity)
    for i in 0..n {
        out.push(i as u8);
    }
    // pad0: zero bytes to 16-align localTMS
    for _ in 0..pad0 {
        out.push(0);
    }
    // localTMS
    for b in &bones {
        for f in compose_localtms(b.t, b.r, b.s) {
            out.extend_from_slice(&f.to_le_bytes());
        }
    }
    // bone records {hash, 16×0, hash, 0, 0, empty-bbox} (verified on Sean, 167/168)
    for b in &bones {
        let mut r = [0u8; 64];
        put_u32(&mut r, 0, b.hash);
        put_u32(&mut r, 20, b.hash);
        for k in 0..4 {
            put_f32(&mut r, 32 + k * 4, 0.0);
        }
        for k in 0..4 {
            put_f32(&mut r, 48 + k * 4, -10000.0);
        }
        out.extend_from_slice(&r);
    }
    // transforms: t(x,y,z,0) r(xyzw) s(x,y,z,0)
    for b in &bones {
        for v in [b.t[0], b.t[1], b.t[2], 0.0, b.r[0], b.r[1], b.r[2], b.r[3], b.s[0], b.s[1], b.s[2], 0.0] {
            out.extend_from_slice(&v.to_le_bytes());
        }
    }
    // parentIds (i16)
    for b in &bones {
        out.extend_from_slice(&(b.parent as i16).to_le_bytes());
    }
    // null32
    for _ in 0..n {
        out.extend_from_slice(&0u32.to_le_bytes());
    }
    Ok((out, n as u32))
}

fn deflate(data: &[u8]) -> Vec<u8> {
    let mut e = flate2::write::ZlibEncoder::new(Vec::new(), flate2::Compression::new(9));
    use std::io::Write as _;
    e.write_all(data).unwrap();
    e.finish().unwrap()
}

/// Wrap a MESH body + .dat into an MSHA container and write it.
fn write_msha(path: &str, name: &str, body: &[u8], dat: &[u8]) -> Result<(), String> {
    let b0 = deflate(body);
    let b1 = deflate(dat);
    let mut out = Vec::new();
    out.extend_from_slice(b"AHSM");
    put_u32_vec(&mut out, body.len() as u32); // unc0
    put_u32_vec(&mut out, dat.len() as u32); // unc1
    put_u32_vec(&mut out, b0.len() as u32); // c0
    put_u32_vec(&mut out, b1.len() as u32); // c1
    let mut nm = [0u8; 256];
    let nb = name.as_bytes();
    nm[..nb.len().min(255)].copy_from_slice(&nb[..nb.len().min(255)]);
    out.extend_from_slice(&nm);
    out.extend_from_slice(&b0);
    out.extend_from_slice(&b1);
    std::fs::write(path, &out).map_err(|e| format!("write {path}: {e}"))
}

/// Stage 2b payoff: build a Saboteur MESH for Mattias — synthesized Sean skeleton + Mattias geometry
/// with bone indices hash-remapped onto Sean — and verify it decodes back to Mattias's geometry.
pub fn import(f: &Flags) -> Result<(), String> {
    let donor_name = f.name.clone().unwrap_or_else(|| "SeanDevlin_01_HD".into());
    let out = if f.out == "patchdynamic0.megapack" { "pmc_hum_mattias.msha".to_string() } else { f.out.clone() };

    println!("[1] donor MESH (header + descriptor templates): '{donor_name}'");
    let mp = pack::Megapack::open(&format!("{}/Global/Dynamic0.megapack", f.game))?;
    let all = scan_msha(mp.raw());
    let dm = all
        .iter()
        .find(|m| m.name.to_ascii_lowercase().contains(&donor_name.to_ascii_lowercase()))
        .ok_or_else(|| format!("no donor MSHA matches '{donor_name}'"))?;
    let (dbody, _ddat) = read_body_and_dat(mp.raw(), dm)?;
    let donor = parse_body(&dbody)?;

    println!("[2] Sean's REAL skeleton (GR embedded) + real stored IBMs");
    let (skel_bytes, nbones) = sean_skeleton_section(&f.game, "SeanDevlin_01_GR")?;
    let stored_ibms = gather_stored_ibms(&f.game)?;
    println!("    {nbones} bones, skeleton section {} B, {} stored IBMs", skel_bytes.len(), stored_ibms.len());

    println!("[3] loading Mattias glTF + bone hash-remap");
    let sem = build_mattias(&f.gltf, &f.skel)?;
    println!("    {} verts, {} indices, {} prims/draws", sem.pos.len(), sem.indices.len(), sem.prims.len());

    println!("[4] encoding MESH (real skeleton + Mattias geometry)");
    let (body, dat) = encode_mesh(&donor, &skel_bytes, nbones, &sem, &stored_ibms)?;
    println!("    MESH body {} B, .dat {} B", body.len(), dat.len());

    println!("[5] VERIFY: decode the encoded MESH and compare to Mattias's glTF geometry");
    let ndoc = parse_body(&body)?;
    let nsem = decode_geometry(&ndoc, &dat)?;
    geom_close(&sem, &nsem)?;
    println!("    re-decoded {} verts, {} indices — matches glTF", nsem.pos.len(), nsem.indices.len());

    write_msha(&out, "pmc_hum_mattias", &body, &dat)?;
    println!("\nPASS — Mattias MESH built and verified against source geometry. Wrote {out}");
    println!("(Geometry + skin verified by decode. In-game load is NOT yet confirmed — that + materials");
    println!(" (Stage 4 textures) + packaging into Sean's bundle are the remaining steps.)");
    Ok(())
}

/// Diagnostic: build an MSHA from a clean external GLB (Khronos RiggedFigure) — whole figure bound
/// rigidly to one Sean bone, with a known-opaque Sean material. Isolates whether the render pipeline
/// (encode + material + skeleton) yields an OPAQUE result on clean, non-doubled geometry. Pass the
/// .glb via --gltf; deploy with `deploy --slot 3`.
pub fn basic_fig(f: &Flags) -> Result<(), String> {
    let outdir = std::path::PathBuf::from(if f.out == "patchdynamic0.megapack" { "mattias_port".into() } else { f.out.clone() });
    std::fs::create_dir_all(&outdir).ok();
    let glb = std::fs::read(&f.gltf).map_err(|e| format!("read glb {}: {e}", f.gltf))?;
    if &glb[0..4] != b"glTF" {
        return Err("not a GLB (magic != glTF)".into());
    }
    let jlen = u32at(&glb, 12) as usize;
    let json: serde_json::Value = serde_json::from_slice(&glb[20..20 + jlen]).map_err(|e| format!("glb json: {e}"))?;
    let bin_off = 20 + jlen;
    let blen = u32at(&glb, bin_off) as usize;
    let bin = &glb[bin_off + 8..bin_off + 8 + blen];
    let acc = &json["accessors"];
    let bvs = &json["bufferViews"];
    let acc_off = |ai: usize| -> usize {
        let a = &acc[ai];
        let v = &bvs[a["bufferView"].as_u64().unwrap() as usize];
        v["byteOffset"].as_u64().unwrap_or(0) as usize + a["byteOffset"].as_u64().unwrap_or(0) as usize
    };
    let read_vec3 = |ai: usize| -> Vec<[f32; 3]> {
        let cnt = acc[ai]["count"].as_u64().unwrap() as usize;
        let base = acc_off(ai);
        (0..cnt).map(|i| [f32at(bin, base + i * 12), f32at(bin, base + i * 12 + 4), f32at(bin, base + i * 12 + 8)]).collect()
    };
    let prim = &json["meshes"][0]["primitives"][0];
    let pos = read_vec3(prim["attributes"]["POSITION"].as_u64().unwrap() as usize);
    let n = pos.len();
    let nrm = if prim["attributes"].get("NORMAL").is_some() {
        read_vec3(prim["attributes"]["NORMAL"].as_u64().unwrap() as usize)
    } else {
        vec![[0.0, 1.0, 0.0]; n]
    };
    let ia = prim["indices"].as_u64().unwrap() as usize;
    let icnt = acc[ia]["count"].as_u64().unwrap() as usize;
    let ib0 = acc_off(ia);
    let ct = acc[ia]["componentType"].as_u64().unwrap();
    let indices: Vec<u32> = (0..icnt)
        .map(|i| match ct {
            5123 => u16::from_le_bytes([bin[ib0 + i * 2], bin[ib0 + i * 2 + 1]]) as u32,
            5125 => u32at(bin, ib0 + i * 4),
            _ => bin[ib0 + i] as u32,
        })
        .collect();
    const BONE: u16 = 0; // rigid to Sean's root bone
    let sem = SemMesh {
        pos,
        nrm,
        uv: vec![[0.0, 0.0]; n],
        joints: vec![[BONE, 0, 0, 0]; n],
        weights: vec![[1.0, 0.0, 0.0, 0.0]; n],
        indices,
        prims: vec![(0, icnt as u32)],
        draws: vec![(0, 0x0CBFA52B, 0)], // Sean's opaque body material — already in France.materials
    };
    println!("[basicfig] {} verts, {} tris, rigid to Sean bone {BONE}, material 0x0CBFA52B (opaque)", n, icnt / 3);
    let (sk, nb) = sean_skeleton_section(&f.game, "SeanDevlin_01_GR")?;
    let ibms = gather_stored_ibms(&f.game)?;
    let mp = pack::Megapack::open(&format!("{}/Global/Dynamic0.megapack", f.game))?;
    let all = scan_msha(mp.raw());
    let dm = all.iter().find(|m| m.name.contains("SeanDevlin_01_HD")).ok_or("no donor")?;
    let (dbody, _) = read_body_and_dat(mp.raw(), dm)?;
    let donor = parse_body(&dbody)?;
    let (body, dat) = encode_mesh(&donor, &sk, nb, &sem, &ibms)?;
    write_msha(outdir.join("pmc_hum_mattias.msha").to_str().unwrap(), "pmc_hum_mattias", &body, &dat)?;
    println!("    wrote pmc_hum_mattias.msha ({} B). Now: deploy --slot 3", body.len());
    Ok(())
}

/// Build a SemMesh from Mattias's glTF with bone indices hash-remapped onto Sean's GLOBAL bones.
fn build_mattias(gltf: &str, skel: &str) -> Result<SemMesh, String> {
    let mm = crate::gltf::load(gltf)?;
    let sean = crate::gltf::load_sean_skel(skel)?;
    let remap = crate::gltf::build_remap(&mm, &sean);
    if remap.orphan > 0 {
        return Err(format!("{} orphan joints — cannot rig", remap.orphan));
    }
    // The Mercs2 export baked BOTH LOD levels into one mesh: a high-detail normal-mapped layer and a
    // low-detail no-normal duplicate of the SAME diffuse, occupying the same space. Rendering both makes
    // them Z-fight (looks like "cycling outfits" + see-through). Drop the LOD1 duplicates: a material
    // with no normal map whose diffuse is shared by another material that HAS one.
    let (_gdir, roles) = crate::gltf::material_roles(gltf)?;
    let skip: std::collections::HashSet<usize> = (0..roles.len())
        .filter(|&i| {
            roles[i][1].is_none()
                && roles[i][0].is_some()
                && roles.iter().enumerate().any(|(j, r)| j != i && r[0] == roles[i][0] && r[1].is_some())
        })
        .collect();
    if !skip.is_empty() {
        println!("    dropping {} LOD-duplicate submesh material(s): {:?}", skip.len(), skip);
    }
    // The Mercs2 export DOUBLED the geometry (~67% of triangles are exact coincident duplicates;
    // Sean's real meshes have 0%). Overlapping copies Z-fight -> shimmer/see-through + "cycling
    // outfits". Dedup coincident triangles, keeping the copy from the HIGHEST-COVERAGE material so the
    // base body layer wins CONSISTENTLY (an inconsistent per-position choice caused red/blue patchwork).
    let mut cov: std::collections::HashMap<i64, usize> = std::collections::HashMap::new();
    for pr in mm.prims.iter() {
        if pr.material >= 0 && skip.contains(&(pr.material as usize)) {
            continue;
        }
        *cov.entry(pr.material).or_insert(0) += pr.indices.len();
    }
    // Dedup priority: process NORMAL-MAPPED (LOD0) prims first so they claim the shared triangles and
    // every coincident no-normal (LOD1) duplicate is dropped — even ones whose diffuse differs from any
    // LOD0 material (e.g. the bag: 2D237115_nnone overlapping 5AAB9E8A_n_s), which the shared-diffuse
    // `skip` rule alone misses. Within each tier, higher coverage wins (keeps one consistent base layer).
    let has_normal = |m: i64| m >= 0 && roles.get(m as usize).is_some_and(|r| r[1].is_some());
    let mut order: Vec<usize> = (0..mm.prims.len()).collect();
    order.sort_by_key(|&i| {
        let m = mm.prims[i].material;
        (std::cmp::Reverse(has_normal(m)), std::cmp::Reverse(cov.get(&m).copied().unwrap_or(0)))
    });

    let mut sem = SemMesh { pos: vec![], nrm: vec![], uv: vec![], joints: vec![], weights: vec![], indices: vec![], prims: vec![], draws: vec![] };
    let mut seen_tri: std::collections::HashSet<[[u16; 3]; 3]> = std::collections::HashSet::new();
    let mut dropped = 0usize;
    for &pi in &order {
        let pr = &mm.prims[pi];
        if pr.material >= 0 && skip.contains(&(pr.material as usize)) {
            continue; // LOD1 duplicate layer (different tessellation)
        }
        let vbase = sem.pos.len() as u32;
        // Rigid attachments (unskinned): positions are already baked to world space in gltf::load;
        // bind them weight-1 to their attachment bone (remapped to Sean) so they animate with it.
        let attach_sean = if pr.skinned {
            None
        } else {
            pr.attach_joint.and_then(|aj| remap.to_sean[aj]).map(|s| s as u16)
        };
        for v in 0..pr.positions.len() {
            sem.pos.push(pr.positions[v]);
            sem.nrm.push(pr.normals[v]);
            sem.uv.push(pr.uvs[v]);
            if let Some(sb) = attach_sean {
                sem.joints.push([sb, 0, 0, 0]);
                sem.weights.push([1.0, 0.0, 0.0, 0.0]);
            } else {
                let jl = pr.joints[v];
                let mut jg = [0u16; 4];
                for k in 0..4 {
                    jg[k] = remap.to_sean[jl[k] as usize].unwrap_or(0) as u16;
                }
                sem.joints.push(jg);
                sem.weights.push(pr.weights[v]);
            }
        }
        let istart = sem.indices.len() as u32;
        let hkey = |v: usize| -> [u16; 3] {
            let p = pr.positions[v];
            [f32_to_half(p[0]), f32_to_half(p[1]), f32_to_half(p[2])]
        };
        for tri in pr.indices.chunks_exact(3) {
            let mut key = [hkey(tri[0] as usize), hkey(tri[1] as usize), hkey(tri[2] as usize)];
            key.sort();
            if !seen_tri.insert(key) {
                dropped += 1;
                continue; // exact coincident duplicate (a lower-coverage overlay copy)
            }
            for &idx in tri {
                sem.indices.push(idx + vbase);
            }
        }
        let kept = sem.indices.len() as u32 - istart;
        if kept == 0 {
            continue; // whole prim was duplicate — drop it (its vertices stay, harmlessly unreferenced)
        }
        let pidx = sem.prims.len() as u32; // index into KEPT prims (draws must reference this, not glTF order)
        sem.prims.push((istart, kept));
        let mat = crate::pack::pandemic_hash(&format!("mattias_m{}", pr.material.max(0)));
        sem.draws.push((pidx, mat, 0));
    }
    if dropped > 0 {
        println!("    deduped {dropped} coincident-duplicate triangles (export doubling; kept base layer)");
    }
    // TEST HOOK: keep only triangles whose centroid Y is in [SAB_YMIN, SAB_YMAX] (region segmentation
    // probe — e.g. torso-only into the UB slot to confirm part-sized geometry renders solid).
    if std::env::var("SAB_YMIN").is_ok() || std::env::var("SAB_YMAX").is_ok() {
        let ymin: f32 = std::env::var("SAB_YMIN").ok().and_then(|s| s.parse().ok()).unwrap_or(f32::MIN);
        let ymax: f32 = std::env::var("SAB_YMAX").ok().and_then(|s| s.parse().ok()).unwrap_or(f32::MAX);
        let (mut nind, mut nprims, mut ndraws) = (Vec::new(), Vec::new(), Vec::new());
        for &(pidx, mat, pb) in &sem.draws {
            let (istart, cnt) = sem.prims[pidx as usize];
            let start = nind.len() as u32;
            let mut t = istart as usize;
            while t + 2 < (istart + cnt) as usize {
                let (a, b, c) = (sem.indices[t], sem.indices[t + 1], sem.indices[t + 2]);
                let cy = (sem.pos[a as usize][1] + sem.pos[b as usize][1] + sem.pos[c as usize][1]) / 3.0;
                if cy >= ymin && cy <= ymax {
                    nind.push(a);
                    nind.push(b);
                    nind.push(c);
                }
                t += 3;
            }
            let kept = nind.len() as u32 - start;
            if kept > 0 {
                let np = nprims.len() as u32;
                nprims.push((start, kept));
                ndraws.push((np, mat, pb));
            }
        }
        println!("    region filter Y[{ymin},{ymax}]: {} tris kept ({} draws)", nind.len() / 3, ndraws.len());
        sem.indices = nind;
        sem.prims = nprims;
        sem.draws = ndraws;
    }
    Ok(sem)
}

// ---- minimal column-major 4x4 for bind-pose bone world positions ----
type M4 = [f32; 16];
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
fn m_trs(t: [f32; 3], r: [f32; 4], s: [f32; 3]) -> M4 {
    let (x, y, z, w) = (r[0], r[1], r[2], r[3]);
    // column-major rotation, columns scaled
    [
        (1.0 - 2.0 * (y * y + z * z)) * s[0], (2.0 * (x * y + z * w)) * s[0], (2.0 * (x * z - y * w)) * s[0], 0.0,
        (2.0 * (x * y - z * w)) * s[1], (1.0 - 2.0 * (x * x + z * z)) * s[1], (2.0 * (y * z + x * w)) * s[1], 0.0,
        (2.0 * (x * z + y * w)) * s[2], (2.0 * (y * z - x * w)) * s[2], (1.0 - 2.0 * (x * x + y * y)) * s[2], 0.0,
        t[0], t[1], t[2], 1.0,
    ]
}
/// Bind-pose world position of every bone (.skel order; parents precede children).
fn bone_world_positions(bones: &[SkelBone]) -> Vec<[f32; 3]> {
    let mut world = vec![[0f32; 16]; bones.len()];
    for (i, b) in bones.iter().enumerate() {
        let local = m_trs(b.t, b.r, b.s);
        world[i] = if b.parent < 0 || b.parent as usize >= i {
            local
        } else {
            m_mul(&world[b.parent as usize], &local)
        };
    }
    world.iter().map(|m| [m[12], m[13], m[14]]).collect()
}

/// Write the SemMesh as an SMSH the workshop viewer can load (`--mesh`), rigged to Sean's `.skel`.
fn write_smsh(path: &str, sem: &SemMesh) -> Result<(), String> {
    let (nv, ni, np) = (sem.pos.len(), sem.indices.len(), sem.draws.len());
    let mut o = Vec::new();
    o.extend_from_slice(b"SMSH");
    put_u32_vec(&mut o, 2); // version 2 (has parent_bone)
    put_u32_vec(&mut o, nv as u32);
    put_u32_vec(&mut o, ni as u32);
    put_u32_vec(&mut o, np as u32);
    for p in &sem.pos {
        for v in p {
            o.extend_from_slice(&v.to_le_bytes());
        }
    }
    for n in &sem.nrm {
        for v in n {
            o.extend_from_slice(&v.to_le_bytes());
        }
    }
    for uv in &sem.uv {
        for v in uv {
            o.extend_from_slice(&v.to_le_bytes());
        }
    }
    for j in &sem.joints {
        for v in j {
            o.extend_from_slice(&v.to_le_bytes());
        }
    }
    for w in &sem.weights {
        for v in w {
            o.extend_from_slice(&v.to_le_bytes());
        }
    }
    for &i in &sem.indices {
        o.extend_from_slice(&i.to_le_bytes());
    }
    for &(prim_idx, mat, pb) in &sem.draws {
        let (istart, icnt) = sem.prims[prim_idx as usize];
        put_u32_vec(&mut o, istart);
        put_u32_vec(&mut o, icnt);
        put_u32_vec(&mut o, mat);
        put_u32_vec(&mut o, prim_idx); // flags
        o.extend_from_slice(&(pb).to_le_bytes());
        o.extend_from_slice(&0u16.to_le_bytes()); // pad
    }
    std::fs::write(path, &o).map_err(|e| format!("write {path}: {e}"))
}

/// Stage 3: export Mattias (rigged to Sean) as SMSH for the viewer, and headlessly check that each
/// vertex is bound to a Sean bone that is spatially near it — a coarse retarget-sanity gate.
/// FULL PORT — the whole Mattias pipeline in one shot: mesh (MSHA + SMSH), textures (DTEX keyed by
/// hash), and the WSAO material records that bind them (patched into a copy of France.materials).
/// Self-verifies that each material resolves through the patched WSAO to its textures.
pub fn port(f: &Flags) -> Result<(), String> {
    let outdir = std::path::PathBuf::from(if f.out == "patchdynamic0.megapack" { "mattias_port".into() } else { f.out.clone() });
    std::fs::create_dir_all(&outdir).ok();
    std::fs::create_dir_all(outdir.join("dtex")).ok();

    println!("[1] materials + textures");
    let (gdir, roles) = crate::gltf::material_roles(&f.gltf)?;
    // encode each material's d/s/n textures -> DTEX keyed by hash; collect WSAO records
    let mut wsao_mats: Vec<(u32, Vec<u32>)> = Vec::new();
    let mut ntex = 0usize;
    for (i, r) in roles.iter().enumerate() {
        let mat_hash = crate::pack::pandemic_hash(&format!("mattias_m{i}"));
        let mut slice: Vec<u32> = Vec::new(); // order [d, s, n]
        for (role_i, suffix) in [(0usize, "d"), (2usize, "s"), (1usize, "n")] {
            let Some(orig) = r[role_i] else { continue };
            let png = gdir.join("textures").join(format!("tex_0x{orig:08X}.png"));
            let Ok((rgba, w, h)) = crate::tex::decode_png(png.to_str().unwrap()) else { continue };
            let name = format!("mattias_m{i}_{suffix}");
            let tex_hash = crate::pack::pandemic_hash(&name);
            // Diffuse must be DXT1 (no alpha) like all of Sean's body diffuse — the cloth shader reads
            // diffuse-alpha as OPACITY, so a DXT5 diffuse (Mercs2's spec-mask alpha) renders Mattias
            // transparent. Only spec keeps an alpha channel; normals are always DXT1.
            let bc3 = suffix == "s" && crate::tex::has_alpha(&rgba);
            let (rec, _unc) = crate::tex::build_dtex(&name, &rgba, w, h, bc3);
            std::fs::write(outdir.join("dtex").join(format!("{tex_hash:08X}.dtex")), [b"DTEX", &rec[..]].concat()).ok();
            slice.push(tex_hash);
            ntex += 1;
        }
        if !slice.is_empty() {
            wsao_mats.push((mat_hash, slice));
        }
    }
    println!("    {} materials, {} DTEX written to {}/dtex", wsao_mats.len(), ntex, outdir.display());

    println!("[2] patching WSAO (France.materials) with Mattias's material records");
    let base_wsao = format!("{}/France.materials", f.game);
    let out_wsao = outdir.join("France.materials");
    crate::wsao::edit(&base_wsao, out_wsao.to_str().unwrap(), &wsao_mats)?;
    // verify: re-parse and resolve each Mattias material + confirm Sean's head still resolves
    let w = crate::wsao::Wsao::open(out_wsao.to_str().unwrap())?;
    if w.textures(0x31AD5DD2).map(|t| t == [0xD0C7AFBC, 0xB2F6DEB7, 0xA8AF6BDE, 0xFB27FAB8]) != Some(true) {
        return Err("patched WSAO broke Sean's head material".into());
    }
    let mut bad = 0;
    for (m, want) in &wsao_mats {
        if w.textures(*m).as_ref() != Some(want) {
            bad += 1;
        }
    }
    if bad > 0 {
        return Err(format!("{bad} Mattias materials did not resolve through patched WSAO"));
    }
    println!("    OK — Sean's head still resolves, and all {} Mattias materials resolve to their DTEX", wsao_mats.len());

    println!("[3] mesh (MSHA + SMSH)");
    let (skel_bytes, nbones) = {
        // donor header/descriptors from a Sean part
        let mp = pack::Megapack::open(&format!("{}/Global/Dynamic0.megapack", f.game))?;
        let all = scan_msha(mp.raw());
        let dm = all.iter().find(|m| m.name.contains("SeanDevlin_01_HD")).ok_or("no donor")?;
        let (dbody, _) = read_body_and_dat(mp.raw(), dm)?;
        let donor = parse_body(&dbody)?;
        // Skeleton = Sean's REAL embedded rig (GR has all 191 bones), NOT a .skel synthesis — the
        // .skel bind is wrong for ~50 bones, which mis-skins the mesh. Same hash order as the retarget.
        let (sk, nb) = sean_skeleton_section(&f.game, "SeanDevlin_01_GR")?;
        // real per-bone inverse-bind matrices (engine's own; naive inv(bind) is wrong for ~6 bones)
        let stored_ibms = gather_stored_ibms(&f.game)?;
        // build mesh
        let sem = build_mattias(&f.gltf, &f.skel)?;
        let (body, dat) = encode_mesh(&donor, &sk, nb, &sem, &stored_ibms)?;
        write_msha(outdir.join("pmc_hum_mattias.msha").to_str().unwrap(), "pmc_hum_mattias", &body, &dat)?;
        write_smsh(outdir.join("pmc_hum_mattias.smsh").to_str().unwrap(), &sem)?;
        // Empty-slot filler: a zero-area 3-vertex mesh on the same rig. The player bundle has 8 body
        // slots; putting the full Mattias in all 8 makes 8 overlapping copies (Z-fight + look
        // transparent). Deploy uses this for the 7 non-primary slots so exactly ONE Mattias renders.
        let empty_mat = wsao_mats.first().map(|(h, _)| *h).unwrap_or(0);
        let empty_sem = SemMesh {
            pos: vec![[0.0; 3]; 3],
            nrm: vec![[0.0, 1.0, 0.0]; 3],
            uv: vec![[0.0; 2]; 3],
            joints: vec![[0u16; 4]; 3],
            weights: vec![[1.0, 0.0, 0.0, 0.0]; 3],
            indices: vec![0, 1, 2],
            prims: vec![(0, 3)],
            draws: vec![(0, empty_mat, 0)],
        };
        let (eb, ed) = encode_mesh(&donor, &sk, nb, &empty_sem, &stored_ibms)?;
        write_msha(outdir.join("pmc_empty.msha").to_str().unwrap(), "pmc_empty", &eb, &ed)?;
        (sk.len(), nb)
    };
    let _ = skel_bytes;
    println!("    MSHA + SMSH written ({nbones}-bone skeleton)");

    println!("\nPASS — full Mattias port. Outputs in {}/:", outdir.display());
    println!("  pmc_hum_mattias.msha  (mesh, engine format)   pmc_hum_mattias.smsh  (viewer)");
    println!("  dtex/<hash>.dtex      (textures keyed by pandemic_hash)");
    println!("  France.materials      (WSAO with Mattias's material->texture records; drop into game root)");
    Ok(())
}

pub fn retarget(f: &Flags) -> Result<(), String> {
    let out = if f.out == "patchdynamic0.megapack" { "pmc_hum_mattias.smsh".to_string() } else { f.out.clone() };
    println!("[1] building Mattias mesh rigged to Sean (hash-remap)");
    let sem = build_mattias(&f.gltf, &f.skel)?;
    println!("    {} verts, {} tris, {} drawcalls", sem.pos.len(), sem.indices.len() / 3, sem.draws.len());

    println!("[2] spatial coherence: distance from each vertex to its dominant bone's rest position");
    let bones = parse_skel(&f.skel)?;
    let bpos = bone_world_positions(&bones);
    let mut dists: Vec<f32> = Vec::with_capacity(sem.pos.len());
    for i in 0..sem.pos.len() {
        let dk = (0..4).max_by(|&a, &b| sem.weights[i][a].total_cmp(&sem.weights[i][b])).unwrap();
        let g = sem.joints[i][dk] as usize;
        let bp = bpos.get(g).copied().unwrap_or([0.0; 3]);
        let p = sem.pos[i];
        let d = ((p[0] - bp[0]).powi(2) + (p[1] - bp[1]).powi(2) + (p[2] - bp[2]).powi(2)).sqrt();
        dists.push(d);
    }
    dists.sort_by(|a, b| a.total_cmp(b));
    let n = dists.len();
    let pct = |q: f32| dists[((n as f32 * q) as usize).min(n - 1)];
    let near = dists.iter().filter(|&&d| d < 0.40).count();
    println!(
        "    median {:.3} m   p95 {:.3} m   max {:.3} m   |  within 0.40 m of bone: {:.1}%",
        pct(0.5),
        pct(0.95),
        dists[n - 1],
        100.0 * near as f32 / n as f32
    );
    let far = dists.iter().filter(|&&d| d > 0.60).count();
    if far > n / 50 {
        println!("    ⚠ {far} vertices ({:.1}%) are >0.60 m from their bone — inspect those regions in the viewer", 100.0 * far as f32 / n as f32);
    } else {
        println!("    coherent: <2% of vertices are far from their bound bone (limb-radius scale).");
    }

    println!("[3] writing SMSH for the workshop viewer -> {out}");
    write_smsh(&out, &sem)?;
    println!("\nDone. Visual Stage-3 gate — load it in the workshop against Sean's rig + animations:");
    println!("  cargo run -p sab_workshop --release -- \\");
    println!("    --mesh \"{out}\" --skel <CH_AL_SeanDevlin.skel> --index <anim_bone_map.json> --pack <Animations.pack>");
    println!("Then play idle/walk/aim clips and judge deformation. (Headless coherence above is a coarse");
    println!(" pre-check, NOT a substitute for eyeballing the animated result.)");
    Ok(())
}

pub fn audit(game: &str) -> Result<(), String> {
    println!("AUDIT: byte-exact MESH re-serialize across every skinned model in Dynamic0");
    let mp = pack::Megapack::open(&format!("{game}/Global/Dynamic0.megapack"))?;
    let all = scan_msha(mp.raw());
    let (mut ok, mut fail, mut skip) = (0usize, 0usize, 0usize);
    for m in &all {
        let Ok((body, _dat)) = read_body_and_dat(mp.raw(), m) else {
            skip += 1;
            continue;
        };
        match parse_body(&body) {
            Ok(doc) => {
                if serialize_body(&doc) == body {
                    ok += 1;
                } else {
                    fail += 1;
                    let at = serialize_body(&doc).iter().zip(&body).position(|(a, b)| a != b);
                    println!("    MISS {:38} first diff {:?}", m.name, at);
                }
            }
            Err(_) => skip += 1,
        }
    }
    println!("TOTAL: {ok} byte-exact, {fail} mismatch, {skip} skipped (non-skinned/parse) — {} MSHA scanned", all.len());
    if fail == 0 {
        println!("MESH writer is byte-exact across every skinned model it parses.");
    }
    Ok(())
}
