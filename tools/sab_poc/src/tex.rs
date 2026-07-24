//! Stage 4 — Mattias textures → DTEX. Decode the exported PNGs, BC-compress (BC1 opaque, BC3 with
//! alpha), build mipped DTEX records keyed by the original texture hash, and verify by decoding back.
//!
//! Material→texture roles come from the glTF material names: `mat_d0x…_n0x…_s0x…` (diffuse / normal /
//! spec texture hashes). The PNGs are named `tex_0x<hash>.png`. DTEX are keyed by `pandemic_hash(name)`;
//! the material→texture binding is via WSAO (`France.materials`, see `wsao.rs`) — the full `mattias`
//! command re-keys these under `mattias_m<i>_<role>` names and writes matching WSMA records.

#![allow(dead_code)]

use std::io::Write as _;

use crate::dtex;
use crate::Flags;

const DXT1: u32 = 0x3154_5844;
const DXT5: u32 = 0x3554_5844;
const DTEX_CHUNK: usize = 0x180000;

fn push_u16(v: &mut Vec<u8>, x: u16) {
    v.extend_from_slice(&x.to_le_bytes());
}
fn push_u32(v: &mut Vec<u8>, x: u32) {
    v.extend_from_slice(&x.to_le_bytes());
}

// ---------------------------------------------------------------- PNG -> RGBA8
pub fn decode_png(path: &str) -> Result<(Vec<u8>, usize, usize), String> {
    let file = std::fs::File::open(path).map_err(|e| format!("open {path}: {e}"))?;
    let mut dec = png::Decoder::new(file);
    dec.set_transformations(png::Transformations::EXPAND | png::Transformations::STRIP_16);
    let mut reader = dec.read_info().map_err(|e| format!("png info {path}: {e}"))?;
    let mut buf = vec![0u8; reader.output_buffer_size()];
    let info = reader.next_frame(&mut buf).map_err(|e| format!("png frame {path}: {e}"))?;
    let (w, h) = (info.width as usize, info.height as usize);
    let src = &buf[..info.buffer_size()];
    let mut rgba = vec![0u8; w * h * 4];
    match info.color_type {
        png::ColorType::Rgba => rgba[..w * h * 4].copy_from_slice(&src[..w * h * 4]),
        png::ColorType::Rgb => {
            for i in 0..w * h {
                rgba[i * 4..i * 4 + 3].copy_from_slice(&src[i * 3..i * 3 + 3]);
                rgba[i * 4 + 3] = 255;
            }
        }
        png::ColorType::Grayscale => {
            for i in 0..w * h {
                let g = src[i];
                rgba[i * 4..i * 4 + 3].copy_from_slice(&[g, g, g]);
                rgba[i * 4 + 3] = 255;
            }
        }
        png::ColorType::GrayscaleAlpha => {
            for i in 0..w * h {
                let g = src[i * 2];
                rgba[i * 4..i * 4 + 4].copy_from_slice(&[g, g, g, src[i * 2 + 1]]);
            }
        }
        png::ColorType::Indexed => return Err("indexed PNG not expanded".into()),
    }
    Ok((rgba, w, h))
}

pub fn has_alpha(rgba: &[u8]) -> bool {
    rgba.chunks_exact(4).any(|p| p[3] < 250)
}

// ---------------------------------------------------------------- BC encoders
fn to565(c: [u8; 3]) -> u16 {
    ((c[0] as u16 >> 3) << 11) | ((c[1] as u16 >> 2) << 5) | (c[2] as u16 >> 3)
}
fn from565(v: u16) -> [i32; 3] {
    let r = ((v >> 11) & 0x1f) as i32;
    let g = ((v >> 5) & 0x3f) as i32;
    let b = (v & 0x1f) as i32;
    [(r * 255 + 15) / 31, (g * 255 + 31) / 63, (b * 255 + 15) / 31]
}

/// 4x4 BC1 colour block (opaque 4-colour), bounding-box endpoints, nearest indices.
fn bc1_block(texels: &[[u8; 3]; 16]) -> [u8; 8] {
    let (mut mn, mut mx) = ([255u8; 3], [0u8; 3]);
    for t in texels {
        for k in 0..3 {
            mn[k] = mn[k].min(t[k]);
            mx[k] = mx[k].max(t[k]);
        }
    }
    let mut c0 = to565(mx);
    let mut c1 = to565(mn);
    if c0 < c1 {
        std::mem::swap(&mut c0, &mut c1);
    }
    if c0 == c1 {
        if c1 > 0 {
            c1 -= 1;
        } else {
            c0 += 1;
        }
    }
    let (p0, p1) = (from565(c0), from565(c1));
    let pal = [
        p0,
        p1,
        [(2 * p0[0] + p1[0]) / 3, (2 * p0[1] + p1[1]) / 3, (2 * p0[2] + p1[2]) / 3],
        [(p0[0] + 2 * p1[0]) / 3, (p0[1] + 2 * p1[1]) / 3, (p0[2] + 2 * p1[2]) / 3],
    ];
    let mut idx = 0u32;
    for (i, t) in texels.iter().enumerate() {
        let mut best = 0;
        let mut bd = i32::MAX;
        for (j, pj) in pal.iter().enumerate() {
            let (dr, dg, db) = (t[0] as i32 - pj[0], t[1] as i32 - pj[1], t[2] as i32 - pj[2]);
            let d = dr * dr + dg * dg + db * db;
            if d < bd {
                bd = d;
                best = j;
            }
        }
        idx |= (best as u32) << (2 * i);
    }
    let mut o = [0u8; 8];
    o[0..2].copy_from_slice(&c0.to_le_bytes());
    o[2..4].copy_from_slice(&c1.to_le_bytes());
    o[4..8].copy_from_slice(&idx.to_le_bytes());
    o
}

/// 8-byte BC3/BC4 alpha block: min/max + 3-bit interpolated indices.
fn bc3_alpha_block(a: &[u8; 16]) -> [u8; 8] {
    let mut amin = 255u8;
    let mut amax = 0u8;
    for &v in a {
        amin = amin.min(v);
        amax = amax.max(v);
    }
    // 8-alpha mode (a0 > a1): endpoints max,min
    let (a0, a1) = (amax, amin);
    let pal = if a0 > a1 {
        let mut p = [0u8; 8];
        p[0] = a0;
        p[1] = a1;
        for k in 1..7u32 {
            p[(k + 1) as usize] = (((7 - k) * a0 as u32 + k * a1 as u32) / 7) as u8;
        }
        p
    } else {
        [a0, a1, a0, a0, a0, a0, 0, 255]
    };
    let mut bits = 0u64;
    for (i, &v) in a.iter().enumerate() {
        let mut best = 0u64;
        let mut bd = i32::MAX;
        for (j, &pj) in pal.iter().enumerate() {
            let d = (v as i32 - pj as i32).abs();
            if d < bd {
                bd = d;
                best = j as u64;
            }
        }
        bits |= best << (3 * i);
    }
    let mut o = [0u8; 8];
    o[0] = a0;
    o[1] = a1;
    for i in 0..6 {
        o[2 + i] = ((bits >> (8 * i)) & 0xff) as u8;
    }
    o
}

fn fetch_block(rgba: &[u8], w: usize, h: usize, bx: usize, by: usize) -> ([[u8; 3]; 16], [u8; 16]) {
    let mut col = [[0u8; 3]; 16];
    let mut al = [0u8; 16];
    for ty in 0..4 {
        for tx in 0..4 {
            let px = (bx * 4 + tx).min(w - 1);
            let py = (by * 4 + ty).min(h - 1);
            let s = (py * w + px) * 4;
            col[ty * 4 + tx] = [rgba[s], rgba[s + 1], rgba[s + 2]];
            al[ty * 4 + tx] = rgba[s + 3];
        }
    }
    (col, al)
}

fn bc_encode_surface(rgba: &[u8], w: usize, h: usize, bc3: bool) -> Vec<u8> {
    let (bw, bh) = ((w + 3) / 4, (h + 3) / 4);
    let mut out = Vec::with_capacity(bw * bh * if bc3 { 16 } else { 8 });
    for by in 0..bh {
        for bx in 0..bw {
            let (col, al) = fetch_block(rgba, w, h, bx, by);
            if bc3 {
                out.extend_from_slice(&bc3_alpha_block(&al));
            }
            out.extend_from_slice(&bc1_block(&col));
        }
    }
    out
}

fn downsample(rgba: &[u8], w: usize, h: usize) -> (Vec<u8>, usize, usize) {
    let (nw, nh) = ((w / 2).max(1), (h / 2).max(1));
    let mut out = vec![0u8; nw * nh * 4];
    for y in 0..nh {
        for x in 0..nw {
            for k in 0..4 {
                let mut acc = 0u32;
                for dy in 0..2 {
                    for dx in 0..2 {
                        let sx = (x * 2 + dx).min(w - 1);
                        let sy = (y * 2 + dy).min(h - 1);
                        acc += rgba[(sy * w + sx) * 4 + k] as u32;
                    }
                }
                out[(y * nw + x) * 4 + k] = (acc / 4) as u8;
            }
        }
    }
    (out, nw, nh)
}

/// Build a mipped DTEX record (no 'DTEX' prefix) from an RGBA surface. Returns (record, uncompressed).
pub fn build_dtex(name: &str, rgba: &[u8], w: usize, h: usize, bc3: bool) -> (Vec<u8>, u32) {
    let nmips = (32 - (w.max(h) as u32).leading_zeros()).max(1); // full chain to 1x1
    let mut full: Vec<u8> = Vec::new();
    let (mut cw, mut ch) = (w, h);
    let mut cur = rgba.to_vec();
    for m in 0..nmips {
        let bc = bc_encode_surface(&cur, cw, ch, bc3);
        push_u32(&mut full, m);
        push_u32(&mut full, cw as u32);
        push_u32(&mut full, ch as u32);
        push_u32(&mut full, 0);
        push_u32(&mut full, 1);
        push_u32(&mut full, bc.len() as u32);
        full.extend_from_slice(&bc);
        if m + 1 < nmips {
            let (d, nw, nh) = downsample(&cur, cw, ch);
            cur = d;
            cw = nw;
            ch = nh;
        }
    }
    let uncompressed = full.len() as u32;
    let mut rec = Vec::new();
    let nb = name.as_bytes();
    push_u32(&mut rec, nb.len() as u32);
    rec.extend_from_slice(nb);
    push_u32(&mut rec, if bc3 { DXT5 } else { DXT1 });
    push_u32(&mut rec, 0); // unk
    push_u16(&mut rec, w as u16);
    push_u16(&mut rec, h as u16);
    push_u16(&mut rec, nmips as u16);
    push_u32(&mut rec, uncompressed);
    let mut i = 0;
    let mut chunks: Vec<Vec<u8>> = Vec::new();
    while i < full.len() {
        let end = (i + DTEX_CHUNK).min(full.len());
        let mut e = flate2::write::ZlibEncoder::new(Vec::new(), flate2::Compression::new(9));
        e.write_all(&full[i..end]).unwrap();
        chunks.push(e.finish().unwrap());
        i = end;
    }
    push_u32(&mut rec, chunks.len() as u32);
    for c in &chunks {
        push_u32(&mut rec, c.len() as u32);
        rec.extend_from_slice(c);
    }
    (rec, uncompressed)
}

/// Mean per-channel RGB error between a decoded DTEX and the source (0..255).
fn rgb_error(a: &[u8], b: &[u8]) -> f32 {
    let n = (a.len() / 4).min(b.len() / 4);
    if n == 0 {
        return 999.0;
    }
    let mut acc = 0u64;
    for i in 0..n {
        for k in 0..3 {
            acc += (a[i * 4 + k] as i32 - b[i * 4 + k] as i32).unsigned_abs() as u64;
        }
    }
    acc as f32 / (n as f32 * 3.0)
}

pub fn import(f: &Flags) -> Result<(), String> {
    let gltf_dir = std::path::Path::new(&f.gltf).parent().ok_or("gltf has no dir")?;
    let text = std::fs::read_to_string(&f.gltf).map_err(|e| e.to_string())?;
    let j: serde_json::Value = serde_json::from_str(&text).map_err(|e| e.to_string())?;

    // unique textures with roles from material names: mat_d0x…_n0x…_s0x…
    let mut want: std::collections::BTreeMap<u32, &'static str> = std::collections::BTreeMap::new();
    for m in j["materials"].as_array().unwrap_or(&vec![]).clone() {
        let nm = m["name"].as_str().unwrap_or("");
        for (tag, role) in [("_d0x", "diffuse"), ("_n0x", "normal"), ("_s0x", "spec")] {
            if let Some(p) = nm.find(tag) {
                let hex: String = nm[p + tag.len()..].chars().take(8).collect();
                if let Ok(h) = u32::from_str_radix(&hex, 16) {
                    want.entry(h).or_insert(role);
                }
            }
        }
    }
    println!("[1] {} unique textures referenced by 14 materials", want.len());

    let out_dir = gltf_dir.join("dtex_out");
    std::fs::create_dir_all(&out_dir).ok();
    let (mut ok, mut fail) = (0, 0);
    let mut worst = 0f32;
    for (hash, role) in &want {
        let png = gltf_dir.join("textures").join(format!("tex_0x{hash:08X}.png"));
        let (rgba, w, h) = match decode_png(png.to_str().unwrap()) {
            Ok(v) => v,
            Err(e) => {
                println!("    0x{hash:08X} ({role}): SKIP — {e}");
                fail += 1;
                continue;
            }
        };
        // Only SPEC may carry alpha (BC3/DXT5). DIFFUSE must be BC1/DXT1 even if its PNG has an alpha
        // channel: the cloth shader reads DIFFUSE-alpha as per-vertex OPACITY (see mesh.rs), so a DXT5
        // diffuse renders Mattias's body see-through. Normals are always BC1.
        let bc3 = *role == "spec" && has_alpha(&rgba);
        let name = format!("0x{hash:08X}");
        let (rec, unc) = build_dtex(&name, &rgba, w, h, bc3);
        // verify: decode back and measure error
        let dec = dtex::decode(&rec)?;
        let err = rgb_error(&dec.rgba, &rgba);
        worst = worst.max(err);
        let fmt = if bc3 { "BC3" } else { "BC1" };
        let flag = if err < 12.0 { "ok" } else { "HIGH ERR" };
        println!("    0x{hash:08X} {role:7} {w}x{h} {fmt} unc={unc} -> mean rgb err {err:.1} [{flag}]");
        std::fs::write(out_dir.join(format!("{name}.dtex")), [b"DTEX", &rec[..]].concat()).ok();
        if err < 12.0 {
            ok += 1;
        } else {
            fail += 1;
        }
    }
    println!("\n{ok} textures encoded+verified, {fail} problem, worst mean err {worst:.1}");
    println!("DTEX written to {}", out_dir.display());
    if fail == 0 {
        println!("PASS — Mattias textures encode to valid DTEX (decode round-trips within BC tolerance).");
    }
    Ok(())
}
