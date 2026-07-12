//! hkaSplineCompressedAnimation decoder for The Saboteur (Havok 6.5.0-r1).
//!
//! COPIED VERBATIM (CLI/diagnostics stripped, a few items made `pub`) from
//! `tools/sab_havok65/src/main.rs`. Do not re-derive — this is the validated decoder.
//!
//! Pipeline: Animations.pack (AP0L) -> concatenated animations.hkx (Havok packfile,
//! magic 0x57e0e057) -> parse sections/classnames/fixups -> find
//! `hkaSplineCompressedAnimation` instances -> decode per-frame hkQsTransforms.

#![allow(dead_code)]

// ---------- little-endian helpers ----------
fn u16le(b: &[u8], o: usize) -> u16 { u16::from_le_bytes([b[o], b[o + 1]]) }
fn u32le(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn i32le(b: &[u8], o: usize) -> i32 { i32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn f32le(b: &[u8], o: usize) -> f32 { f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn find_sub(hay: &[u8], n: &[u8]) -> Option<usize> {
    hay.windows(n.len()).position(|w| w == n)
}

// ---------- Havok packfile (LE, 32-bit) ----------
pub struct Packfile<'a> {
    pub blob: &'a [u8],           // whole hkx blob (magic at 0)
    pub data_pk: usize,           // abs offset of __data__ body in blob
    names: std::collections::HashMap<usize, String>, // classnames-body-rel off -> name
    lf: std::collections::HashMap<usize, usize>,      // src(data-rel) -> dst(data-rel)
    pub vfixups: Vec<(usize, String)>,                // (obj src data-rel, class)
    pub version: String,
}

impl<'a> Packfile<'a> {
    pub fn parse(blob: &'a [u8]) -> Result<Self, String> {
        if u32le(blob, 0) != 0x57e0_e057 { return Err("bad havok magic".into()); }
        let sh = find_sub(blob, b"__classnames__").ok_or("no __classnames__")?;
        let mut secs = [[0u32; 7]; 3];
        for s in 0..3 {
            for k in 0..7 { secs[s][k] = u32le(blob, sh + s * 48 + 20 + k * 4); }
        }
        let body0 = sh + 3 * 48;
        let cn_len = secs[0][6] as usize;
        let data_pk = body0 + secs[0][6] as usize + secs[1][6] as usize;
        let mut names = std::collections::HashMap::new();
        let cn_end = (body0 + cn_len).min(blob.len());
        let mut p = body0;
        while p + 5 <= cn_end {
            if u32le(blob, p) == 0xFFFF_FFFF { break; }
            let mut q = p + 5;
            while q < cn_end && blob[q] != 0 { q += 1; }
            if let Ok(nm) = std::str::from_utf8(&blob[p + 5..q]) {
                if !nm.is_empty() { names.insert(p + 5 - body0, nm.to_string()); }
            }
            p = q + 1;
        }
        let (d_lf, d_gf, d_vf, d_end) =
            (secs[2][1] as usize, secs[2][2] as usize, secs[2][3] as usize, secs[2][4] as usize);
        let mut lf = std::collections::HashMap::new();
        let mut k = data_pk + d_lf;
        let lf_end = data_pk + d_gf;
        while k + 8 <= lf_end {
            let src = u32le(blob, k);
            if src == 0xFFFF_FFFF { break; }
            lf.insert(src as usize, u32le(blob, k + 4) as usize);
            k += 8;
        }
        let mut vfixups = Vec::new();
        let mut k = data_pk + d_vf;
        let vf_end = data_pk + d_end;
        while k + 12 <= vf_end {
            let src = u32le(blob, k) as usize;
            let cnoff = u32le(blob, k + 8) as usize;
            if src == 0xFFFF_FFFF { break; }
            k += 12;
            vfixups.push((src, names.get(&cnoff).cloned().unwrap_or_else(|| "?".into())));
        }
        let version = find_sub(blob, b"Havok-").map(|o| {
            let mut q = o;
            while q < blob.len() && blob[q] != 0 && blob[q].is_ascii_graphic() { q += 1; }
            String::from_utf8_lossy(&blob[o..q]).into_owned()
        }).unwrap_or_default();
        Ok(Packfile { blob, data_pk, names, lf, vfixups, version })
    }
    fn array(&self, obj_src: usize, field_off: usize) -> (Option<usize>, usize) {
        let size = u32le(self.blob, self.data_pk + obj_src + field_off + 4) as usize;
        let dst = self.lf.get(&(obj_src + field_off)).map(|d| self.data_pk + d);
        (dst, size)
    }
}

// ---------- AP0L pack ----------
pub struct Ap0l { pub blob_off: usize, pub num_anims: u32, pub hk_size: usize }
pub fn parse_ap0l(file: &[u8]) -> Result<Ap0l, String> {
    if file.len() < 4 || &file[0..4] != b"L0PA" { return Err("not AP0L".into()); }
    let magic = [0x57u8, 0xe0, 0xe0, 0x57];
    let blob_off = find_sub(file, &magic).ok_or("no havok magic in pack")?;
    if blob_off < 8 { return Err("havok blob too early in pack".into()); }
    let num_anims = u32le(file, blob_off - 8);
    let hk_size = u32le(file, blob_off - 4) as usize;
    Ok(Ap0l { blob_off, num_anims, hk_size })
}

// ---------- hkQsTransform ----------
#[derive(Clone, Copy, Debug)]
pub struct QsTransform { pub t: [f32; 4], pub r: [f32; 4], pub s: [f32; 4] }

// ---------- spline component evaluator (port of FUN_00eb73a0) ----------
fn eval_vec4(
    data: &[u8], ptr: &mut usize, mask: u8, quant_type: u8,
    frame_in_block: u8, frame_duration: f32, block_time: f32, default: [f32; 4],
) -> [f32; 4] {
    let has_spline = mask & 0xf0 != 0;
    let mut degree = 0usize;
    let mut n_idx = 0usize;
    let mut span = 0usize;
    let mut local_knots: Vec<f32> = Vec::new();

    if has_spline {
        n_idx = u16le(data, *ptr) as usize; *ptr += 2;
        degree = data[*ptr] as usize; *ptr += 1;
        let knot_ptr = *ptr;
        span = find_span(n_idx, degree, frame_in_block, &data[knot_ptr..]);
        for i in 0..(2 * degree) {
            let ki = (span as isize - degree as isize + 1 + i as isize) as usize;
            local_knots.push(data[knot_ptr + ki] as f32 * frame_duration);
        }
        *ptr = knot_ptr + n_idx + 2 + degree;
    }

    *ptr = (*ptr + 3) & !3;
    let mut statics = [0f32; 4];
    let mut range = [(0f32, 0f32); 3];
    for i in 0..3 {
        if mask & (1 << i) != 0 {
            statics[i] = f32le(data, *ptr); *ptr += 4;
        } else if mask & (0x10 << i) != 0 {
            let lo = f32le(data, *ptr); *ptr += 4;
            let hi = f32le(data, *ptr); *ptr += 4;
            range[i] = (lo, hi);
        }
    }
    if mask & 8 != 0 { statics[3] = f32le(data, *ptr); *ptr += 4; }

    if !has_spline {
        return assemble_static_default(mask, &statics, &default);
    }

    *ptr = (*ptr + 1) & !1;
    let bytes_per = if quant_type == 0 { 1usize } else { 2usize };
    let n_comp = ((mask >> 4) & 7).count_ones() as usize;
    let num_cp = n_idx + 1;
    let cp_base = *ptr;

    let dyn_bits: Vec<usize> = (0..3).filter(|&i| mask & (0x10 << i) != 0).collect();
    let mut cps: Vec<[f32; 4]> = Vec::with_capacity(degree + 1);
    for r in 0..=degree {
        let cp_index = span - degree + r;
        let mut v = [0f32; 4];
        for (c, &comp) in dyn_bits.iter().enumerate() {
            let off = cp_base + (cp_index * n_comp + c) * bytes_per;
            let q = if bytes_per == 1 { data[off] as f32 / 255.0 }
                    else { u16le(data, off) as f32 / 65535.0 };
            let (lo, hi) = range[comp];
            v[comp] = lo + q * (hi - lo);
        }
        for i in 0..4 {
            if mask & (1 << i) != 0 { v[i] = statics[i]; }
            else if (mask & (0x10 << i)) == 0 { v[i] = default[i]; }
        }
        cps.push(v);
    }
    *ptr = cp_base + num_cp * n_comp * bytes_per;

    de_boor(degree, span, &local_knots, &cps, block_time)
}

// Port of FUN_00eb72c0: ROTATION channel.
fn eval_rotation(
    data: &[u8], ptr: &mut usize, mask: u8, qtype: u8,
    fib: u8, frame_duration: f32, block_time: f32, default: [f32; 4],
) -> [f32; 4] {
    let cpsize = rot_cpsize(qtype);
    let q = if mask & 0xf0 != 0 {
        let n = u16le(data, *ptr) as usize; *ptr += 2;
        let degree = data[*ptr] as usize; *ptr += 1;
        let knot_ptr = *ptr;
        let span = find_span(n, degree, fib, &data[knot_ptr..]);
        let mut local_knots = Vec::new();
        for i in 0..(2 * degree) {
            let ki = (span as isize - degree as isize + 1 + i as isize) as usize;
            local_knots.push(data[knot_ptr + ki] as f32 * frame_duration);
        }
        *ptr = knot_ptr + n + 2 + degree;
        *ptr = align_up(*ptr, rot_align(qtype));
        let cp_base = *ptr;
        let mut cps: Vec<[f32; 4]> = Vec::with_capacity(degree + 1);
        for r in 0..=degree {
            let idx = span - degree + r;
            let mut cp = unpack_quat(data, cp_base + idx * cpsize, qtype);
            if let Some(first) = cps.first() {
                let dot: f32 = (0..4).map(|k| first[k] * cp[k]).sum();
                if dot < 0.0 { for k in 0..4 { cp[k] = -cp[k]; } }
            }
            cps.push(cp);
        }
        *ptr = cp_base + (n + 1) * cpsize;
        de_boor(degree, span, &local_knots, &cps, block_time)
    } else if mask & 0xf != 0 {
        *ptr = align_up(*ptr, rot_align(qtype));
        let v = unpack_quat(data, *ptr, qtype);
        *ptr += cpsize;
        v
    } else {
        default
    };
    let nrm = (q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3]).sqrt();
    if nrm > 1e-12 { [q[0]/nrm, q[1]/nrm, q[2]/nrm, q[3]/nrm] } else { [0.0,0.0,0.0,1.0] }
}

fn align_up(x: usize, a: usize) -> usize { (x + a - 1) & !(a - 1) }
fn rot_cpsize(t: u8) -> usize { match t { 0 => 4, 1 => 5, 2 => 6, 3 => 3, _ => 5 } }
fn rot_align(_t: u8) -> usize { 1 }

// THREECOMP40 (type 1) unpacker — faithful to FUN_00f22470.
fn unpack_quat(data: &[u8], off: usize, qtype: u8) -> [f32; 4] {
    match qtype {
        1 => {
            const S: f32 = 1.0 / (std::f32::consts::SQRT_2 * 2047.0);
            let v: u64 = (0..5).map(|i| (data[off + i] as u64) << (8 * i)).sum();
            let small = [
                (((v & 0xFFF) as i32) - 2047) as f32 * S,
                ((((v >> 12) & 0xFFF) as i32) - 2047) as f32 * S,
                ((((v >> 24) & 0xFFF) as i32) - 2047) as f32 * S,
            ];
            let idx = ((v >> 36) & 3) as usize;
            let neg = (v >> 38) & 1 != 0;
            let s = small[0] * small[0] + small[1] * small[1] + small[2] * small[2];
            let mut largest = (1.0 - s).max(0.0).sqrt();
            if neg { largest = -largest; }
            let mut q = [0f32; 4];
            let mut j = 0;
            for i in 0..4 {
                if i == idx { q[i] = largest; } else { q[i] = small[j]; j += 1; }
            }
            q
        }
        _ => [0.0, 0.0, 0.0, 1.0],
    }
}

fn assemble_static_default(mask: u8, statics: &[f32; 4], default: &[f32; 4]) -> [f32; 4] {
    let mut v = [0f32; 4];
    for i in 0..4 {
        v[i] = if mask & (1 << i) != 0 { statics[i] } else { default[i] };
    }
    v
}

fn find_span(n: usize, p: usize, u: u8, knots: &[u8]) -> usize {
    if u >= knots[n + 1] { return n; }
    if u <= knots[p] { return p; }
    let mut low = p;
    let mut high = n + 1;
    let mut mid = (low + high) / 2;
    let mut guard = 0;
    while u < knots[mid] || u >= knots[mid + 1] {
        if u < knots[mid] { high = mid; } else { low = mid; }
        mid = (low + high) / 2;
        guard += 1;
        if guard > 64 || low >= high { break; }
    }
    mid
}

fn de_boor(p: usize, span: usize, uk: &[f32], cps: &[[f32; 4]], u: f32) -> [f32; 4] {
    if p == 0 { return cps[0]; }
    let mut d = cps.to_vec();
    for r in 1..=p {
        for j in (r..=p).rev() {
            let ui = uk[j - 1];
            let uipr = uk[j + p - r];
            let denom = uipr - ui;
            let a = if denom.abs() < 1e-20 { 0.0 } else { (u - ui) / denom };
            let mut nv = [0f32; 4];
            for c in 0..4 { nv[c] = (1.0 - a) * d[j - 1][c] + a * d[j][c]; }
            d[j] = nv;
        }
    }
    let _ = span;
    d[p]
}

// ---------- clip decode ----------
pub struct SplineAnim {
    pub duration: f32,
    pub num_transform_tracks: usize,
    pub num_float_tracks: usize,
    pub num_frames: usize,
    pub num_blocks: usize,
    pub max_frames_per_block: usize,
    pub mask_and_quant_size: usize,
    pub block_duration: f32,
    pub block_inv_duration: f32,
    pub frame_duration: f32,
    pub block_offsets: Vec<u32>,
    pub transform_offsets: Vec<u32>,
    pub data_off: usize,
    pub data_len: usize,
}

pub fn read_spline_anim(pk: &Packfile, obj_src: usize) -> SplineAnim {
    let b = pk.blob;
    let o = pk.data_pk + obj_src;
    let block_offsets = {
        let (dst, size) = pk.array(obj_src, 0x40);
        let mut v = Vec::new();
        if let Some(d) = dst { for i in 0..size { v.push(u32le(b, d + i * 4)); } }
        v
    };
    let transform_offsets = {
        let (dst, size) = pk.array(obj_src, 0x58);
        let mut v = Vec::new();
        if let Some(d) = dst { for i in 0..size { v.push(u32le(b, d + i * 4)); } }
        v
    };
    let (data_dst, data_len) = pk.array(obj_src, 0x70);
    SplineAnim {
        duration: f32le(b, o + 0x0c),
        num_transform_tracks: u32le(b, o + 0x10) as usize,
        num_float_tracks: u32le(b, o + 0x14) as usize,
        num_frames: u32le(b, o + 0x24) as usize,
        num_blocks: u32le(b, o + 0x28) as usize,
        max_frames_per_block: u32le(b, o + 0x2c) as usize,
        mask_and_quant_size: u32le(b, o + 0x30) as usize,
        block_duration: f32le(b, o + 0x34),
        block_inv_duration: f32le(b, o + 0x38),
        frame_duration: f32le(b, o + 0x3c),
        block_offsets,
        transform_offsets,
        data_off: data_dst.unwrap_or(0),
        data_len,
    }
}

impl SplineAnim {
    fn block_and_frame(&self, time: f32) -> (usize, f32, u8) {
        let bi = if self.num_blocks <= 1 { 0 }
                 else { ((time / self.block_duration).floor() as i64)
                        .clamp(0, self.num_blocks as i64 - 1) as usize };
        let block_time = time - bi as f32 * self.block_duration;
        let fib = (block_time * self.block_inv_duration * (self.max_frames_per_block as f32 - 1.0))
            .round().clamp(0.0, 255.0) as u8;
        (bi, block_time, fib)
    }

    /// Sample all transform tracks at `time` (seconds). Returns one QsTransform per track.
    pub fn sample_at(&self, blob: &[u8], time: f32) -> Vec<QsTransform> {
        let (bi, block_time, fib) = self.block_and_frame(time);
        let block_start = self.data_off + self.block_offsets.get(bi).copied().unwrap_or(0) as usize;
        let nt = self.num_transform_tracks;
        let mut ptr = block_start + self.mask_and_quant_size;
        let mut out = Vec::with_capacity(nt);
        let id_rot = [0f32, 0f32, 0f32, 1f32];
        let id_pos = [0f32, 0f32, 0f32, 0f32];
        let id_scl = [1f32, 1f32, 1f32, 1f32];
        for t in 0..nt {
            let hdr = block_start + t * 4;
            let ctrl = blob[hdr];
            let trn_mask = blob[hdr + 1];
            let rot_mask = blob[hdr + 2];
            let scl_mask = blob[hdr + 3];
            let trn_type = ctrl & 3;
            let rot_type = (ctrl >> 2) & 0xf;
            let scl_type = ctrl >> 6;
            let t_ = eval_vec4(blob, &mut ptr, trn_mask, trn_type, fib, self.frame_duration, block_time, id_pos);
            ptr = (ptr + 3) & !3;
            let r = eval_rotation(blob, &mut ptr, rot_mask, rot_type, fib, self.frame_duration, block_time, id_rot);
            ptr = (ptr + 3) & !3;
            let s = eval_vec4(blob, &mut ptr, scl_mask, scl_type, fib, self.frame_duration, block_time, id_scl);
            ptr = (ptr + 3) & !3;
            out.push(QsTransform { t: t_, r, s });
        }
        out
    }
}
