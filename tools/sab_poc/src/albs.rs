//! global.map parse, ALBS bundle parse + byte-exact rebuild, DTEX (checker) encode, and the patch
//! megapack writer (incl. the second `(crc,index)` table both community tools omit).
//! Format details: docs/formats/archive_and_models.md. Byte-verified (repack-audit: 921/923).

#![allow(dead_code)]

use std::io::Write as _;

pub const DXT1: u32 = 0x3154_5844; // on disk bytes 44 58 54 31 (forward MAKEFOURCC)
const DTEX_CHUNK: usize = 0x180000; // 1.5 MiB uncompressed multistream chunk
pub const CAT_TEX: usize = 3; // ALBS table order: [mesh, phys, flash, tex]

fn u16le(b: &[u8], o: usize) -> u16 {
    u16::from_le_bytes([b[o], b[o + 1]])
}
fn u32le(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}
fn push_u16(v: &mut Vec<u8>, x: u16) {
    v.extend_from_slice(&x.to_le_bytes());
}
fn push_u32(v: &mut Vec<u8>, x: u32) {
    v.extend_from_slice(&x.to_le_bytes());
}

// ================================================================== global.map
#[derive(Clone, Debug)]
pub struct Dyn {
    pub asset_index: u32,
    pub name: String,
    pub n_mesh: u32,
    pub n_phys: u32,
    pub n_flash: u32,
    pub n_tex: u32,
}

struct Reader<'a> {
    b: &'a [u8],
    p: usize,
}
impl<'a> Reader<'a> {
    fn new(b: &'a [u8]) -> Self {
        Reader { b, p: 0 }
    }
    fn u16(&mut self) -> u16 {
        let v = u16le(self.b, self.p);
        self.p += 2;
        v
    }
    fn u32(&mut self) -> u32 {
        let v = u32le(self.b, self.p);
        self.p += 4;
        v
    }
    fn skip(&mut self, n: usize) {
        self.p += n;
    }
    fn take(&mut self, n: usize) -> &'a [u8] {
        let s = &self.b[self.p..self.p + n];
        self.p += n;
        s
    }
}

/// Locate `global.map` inside `loosefiles_BinPC.pack`.
/// Loose entry = { u32 hash; u32 dataSize; char name[120]; u8 data[dataSize]; pad->16 }.
pub fn find_global_map(loose: &[u8]) -> Result<Vec<u8>, String> {
    let mut p = 0usize;
    while p + 128 <= loose.len() {
        let data_size = u32le(loose, p + 4) as usize;
        let name_end = loose[p + 8..p + 128].iter().position(|&c| c == 0).unwrap_or(120);
        let name = String::from_utf8_lossy(&loose[p + 8..p + 8 + name_end]);
        let data_off = p + 128;
        if name.ends_with("lobal.map") {
            if data_off + data_size > loose.len() {
                return Err("global.map data overruns loosefiles".into());
            }
            return Ok(loose[data_off..data_off + data_size].to_vec());
        }
        p = data_off + data_size;
        p = (p + 15) / 16 * 16;
    }
    Err("global.map not found in loosefiles".into())
}

fn read_dyn(r: &mut Reader) -> Dyn {
    let asset_index = r.u32();
    let nlen = r.u16() as usize;
    let raw = r.take(nlen);
    let name = String::from_utf8_lossy(raw.split(|&c| c == 0).next().unwrap_or(raw)).into_owned();
    r.skip(28);
    let ntex = r.u32();
    r.skip(ntex as usize * 8);
    let nmsh = r.u32();
    r.skip(nmsh as usize * 8);
    r.u32(); // dataOffset
    let n_mesh = r.u32();
    let n_tex = r.u32();
    let n_phys = r.u32();
    for _ in 0..4 {
        r.u32();
    }
    let n_flash = r.u32();
    for _ in 0..4 {
        r.u32();
    }
    Dyn { asset_index, name, n_mesh, n_phys, n_flash, n_tex }
}

pub fn parse_global_map(gm: &[u8]) -> Result<Vec<Dyn>, String> {
    if gm.len() < 8 || &gm[0..4] != b"6PAM" {
        return Err(format!("bad global.map magic {:02X?}", &gm[0..4.min(gm.len())]));
    }
    let mut r = Reader::new(gm);
    r.skip(4);
    let num_dynamics = r.u32();
    let n_preload = r.u32();
    let mut out = Vec::new();
    for _ in 0..n_preload {
        out.push(read_dyn(&mut r));
    }
    let n_patterns = r.u32();
    for _ in 0..n_patterns {
        out.push(read_dyn(&mut r));
    }
    for _ in 0..num_dynamics {
        out.push(read_dyn(&mut r));
    }
    Ok(out)
}

/// Convenience: parse global.map straight from a game dir.
pub fn load_dyns(game: &str) -> Result<Vec<Dyn>, String> {
    let loose = std::fs::read(format!("{game}/France/loosefiles_BinPC.pack")).map_err(|e| e.to_string())?;
    parse_global_map(&find_global_map(&loose)?)
}

// ================================================================== ALBS bundle
pub type DynFile = [u32; 6]; // hash0, offset, size, uncompressedSize, null, hash1

pub struct Bundle {
    pub tables: [Vec<DynFile>; 4], // [mesh, phys, flash, tex]
    pub tbl_end: usize,
    pub data_ext: usize,
}

pub fn parse_bundle(buf: &[u8], d: &Dyn) -> Result<Bundle, String> {
    if buf.len() < 8 || &buf[0..4] != b"ALBS" {
        return Err(format!("bad ALBS magic {:02X?}", &buf[0..4.min(buf.len())]));
    }
    if u32le(buf, 4) != 0 {
        return Err("ALBS second word != 0".into());
    }
    let counts = [d.n_mesh, d.n_phys, d.n_flash, d.n_tex];
    let mut tables: [Vec<DynFile>; 4] = Default::default();
    let mut p = 8usize;
    for (cat, &n) in counts.iter().enumerate() {
        for _ in 0..n {
            if p + 24 > buf.len() {
                return Err("ALBS table overruns bundle".into());
            }
            let mut df = [0u32; 6];
            for (k, slot) in df.iter_mut().enumerate() {
                *slot = u32le(buf, p + k * 4);
            }
            tables[cat].push(df);
            p += 24;
        }
    }
    let tbl_end = p;
    let mut data_ext = 0usize;
    for t in &tables {
        for df in t {
            data_ext = data_ext.max(df[1] as usize + df[2] as usize);
        }
    }
    Ok(Bundle { tables, tbl_end, data_ext })
}

/// Rebuild the bundle, optionally replacing one texture. Offsets/sizes recomputed, identity hashes kept.
pub fn rebuild_bundle(buf: &[u8], b: &Bundle, repl: Option<(usize, &[u8], u32)>) -> Vec<u8> {
    let mut tables = b.tables.clone();
    let trailing = &buf[b.tbl_end + b.data_ext..];
    let mut out_data: Vec<u8> = Vec::new();
    let mut cursor = 0u32;
    for cat in 0..4 {
        for i in 0..tables[cat].len() {
            let (data, sz, usz): (Vec<u8>, u32, u32) = match repl {
                Some((ri, rec, rusz)) if cat == CAT_TEX && i == ri => (rec.to_vec(), rec.len() as u32, rusz),
                _ => {
                    let df = tables[cat][i];
                    let off = b.tbl_end + df[1] as usize;
                    (buf[off..off + df[2] as usize].to_vec(), df[2], df[3])
                }
            };
            let df = &mut tables[cat][i];
            df[1] = cursor;
            df[2] = sz;
            df[3] = usz;
            out_data.extend_from_slice(&data);
            cursor += sz;
        }
    }
    let mut out = Vec::with_capacity(8 + b.tbl_end + out_data.len() + trailing.len());
    out.extend_from_slice(b"ALBS");
    push_u32(&mut out, 0);
    for cat in 0..4 {
        for df in &tables[cat] {
            for &w in df {
                push_u32(&mut out, w);
            }
        }
    }
    out.extend_from_slice(&out_data);
    out.extend_from_slice(trailing);
    out
}

/// Which tex-table index owns the DTEX record at absolute sub-pack offset `rec_off`?
pub fn tex_index_for_record(b: &Bundle, rec_off: usize) -> Option<usize> {
    let rel = rec_off.checked_sub(b.tbl_end)? as u32;
    b.tables[CAT_TEX].iter().position(|df| df[1] == rel)
}

// ================================================================== DTEX encode (synthetic checker)
fn encode_bc1_block(texels: &[[u8; 3]; 16]) -> [u8; 8] {
    let (mut mn, mut mx) = ([255u8; 3], [0u8; 3]);
    for t in texels {
        for k in 0..3 {
            mn[k] = mn[k].min(t[k]);
            mx[k] = mx[k].max(t[k]);
        }
    }
    let to565 = |c: [u8; 3]| ((c[0] as u16 >> 3) << 11) | ((c[1] as u16 >> 2) << 5) | (c[2] as u16 >> 3);
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
    let from565 = |v: u16| -> [i32; 3] {
        let r = ((v >> 11) & 0x1f) as i32;
        let g = ((v >> 5) & 0x3f) as i32;
        let b = (v & 0x1f) as i32;
        [(r * 255 + 15) / 31, (g * 255 + 31) / 63, (b * 255 + 15) / 31]
    };
    let p0 = from565(c0);
    let p1 = from565(c1);
    let pal = [
        p0,
        p1,
        [(2 * p0[0] + p1[0]) / 3, (2 * p0[1] + p1[1]) / 3, (2 * p0[2] + p1[2]) / 3],
        [(p0[0] + 2 * p1[0]) / 3, (p0[1] + 2 * p1[1]) / 3, (p0[2] + 2 * p1[2]) / 3],
    ];
    let mut idx = 0u32;
    for (i, t) in texels.iter().enumerate() {
        let mut best = 0usize;
        let mut bestd = i32::MAX;
        for (j, pj) in pal.iter().enumerate() {
            let (dr, dg, db) = (t[0] as i32 - pj[0], t[1] as i32 - pj[1], t[2] as i32 - pj[2]);
            let d = dr * dr + dg * dg + db * db;
            if d < bestd {
                bestd = d;
                best = j;
            }
        }
        idx |= (best as u32) << (2 * i);
    }
    let mut out = [0u8; 8];
    out[0..2].copy_from_slice(&c0.to_le_bytes());
    out[2..4].copy_from_slice(&c1.to_le_bytes());
    out[4..8].copy_from_slice(&idx.to_le_bytes());
    out
}

fn bc1_encode_surface(rgb: &[u8], w: usize, h: usize) -> Vec<u8> {
    let (bw, bh) = ((w + 3) / 4, (h + 3) / 4);
    let mut out = Vec::with_capacity(bw * bh * 8);
    for by in 0..bh {
        for bx in 0..bw {
            let mut texels = [[0u8; 3]; 16];
            for ty in 0..4 {
                for tx in 0..4 {
                    let px = (bx * 4 + tx).min(w - 1);
                    let py = (by * 4 + ty).min(h - 1);
                    let s = (py * w + px) * 3;
                    texels[ty * 4 + tx] = [rgb[s], rgb[s + 1], rgb[s + 2]];
                }
            }
            out.extend_from_slice(&encode_bc1_block(&texels));
        }
    }
    out
}

fn downsample(rgb: &[u8], w: usize, h: usize) -> (Vec<u8>, usize, usize) {
    let (nw, nh) = ((w / 2).max(1), (h / 2).max(1));
    let mut out = vec![0u8; nw * nh * 3];
    for y in 0..nh {
        for x in 0..nw {
            for k in 0..3 {
                let mut acc = 0u32;
                for dy in 0..2 {
                    for dx in 0..2 {
                        let sx = (x * 2 + dx).min(w - 1);
                        let sy = (y * 2 + dy).min(h - 1);
                        acc += rgb[(sy * w + sx) * 3 + k] as u32;
                    }
                }
                out[(y * nw + x) * 3 + k] = (acc / 4) as u8;
            }
        }
    }
    (out, nw, nh)
}

fn checker_rgb(w: usize, h: usize) -> Vec<u8> {
    let cell = (w.max(h) / 8).max(4);
    let mut out = vec![0u8; w * h * 3];
    for y in 0..h {
        for x in 0..w {
            let on = ((x / cell) + (y / cell)) % 2 == 0;
            let c = if on { [255u8, 0, 255] } else { [12u8, 12, 12] };
            out[(y * w + x) * 3..(y * w + x) * 3 + 3].copy_from_slice(&c);
        }
    }
    out
}

/// Build a DTEX record (no 'DTEX' prefix) of a synthetic checker at `w`x`h`x`mips`, DXT1.
/// Returns (record_bytes, uncompressed_size).
pub fn build_checker_dtex(name: &str, unk: u32, w: u16, h: u16, mips: u16) -> (Vec<u8>, u32) {
    let mut full: Vec<u8> = Vec::new();
    let (mut cw, mut ch) = (w as usize, h as usize);
    let mut rgb = checker_rgb(cw, ch);
    for m in 0..mips as u32 {
        let bc1 = bc1_encode_surface(&rgb, cw, ch);
        push_u32(&mut full, m);
        push_u32(&mut full, cw as u32);
        push_u32(&mut full, ch as u32);
        push_u32(&mut full, 0);
        push_u32(&mut full, 1);
        push_u32(&mut full, bc1.len() as u32);
        full.extend_from_slice(&bc1);
        if m + 1 < mips as u32 {
            let (d, nw, nh) = downsample(&rgb, cw, ch);
            rgb = d;
            cw = nw;
            ch = nh;
        }
    }
    let uncompressed = full.len() as u32;

    let mut chunks: Vec<Vec<u8>> = Vec::new();
    let mut i = 0usize;
    while i < full.len() {
        let end = (i + DTEX_CHUNK).min(full.len());
        let mut enc = flate2::write::ZlibEncoder::new(Vec::new(), flate2::Compression::new(9));
        enc.write_all(&full[i..end]).unwrap();
        chunks.push(enc.finish().unwrap());
        i = end;
    }
    if chunks.is_empty() {
        let mut enc = flate2::write::ZlibEncoder::new(Vec::new(), flate2::Compression::new(9));
        enc.write_all(&[]).unwrap();
        chunks.push(enc.finish().unwrap());
    }

    let nb = name.as_bytes();
    let mut rec = Vec::new();
    push_u32(&mut rec, nb.len() as u32);
    rec.extend_from_slice(nb);
    push_u32(&mut rec, DXT1);
    push_u32(&mut rec, unk);
    push_u16(&mut rec, w);
    push_u16(&mut rec, h);
    push_u16(&mut rec, mips);
    push_u32(&mut rec, uncompressed);
    push_u32(&mut rec, chunks.len() as u32);
    for c in &chunks {
        push_u32(&mut rec, c.len() as u32);
        rec.extend_from_slice(c);
    }
    (rec, uncompressed)
}

// ================================================================== megapack patch writer
fn align(n: usize, a: usize) -> usize {
    (n + a - 1) / a * a
}

/// Patch megapack: header, main TOC (20B), the SECOND (crc,index) table (8B), 0xCB padding, blobs.
pub fn write_patch_megapack(path: &str, entries: &[(u32, u32, Vec<u8>)]) -> Result<(), String> {
    let count = entries.len();
    let header = 8 + count * 20 + count * 8;
    let first_blob = align(header, 0x800);

    let mut recs: Vec<(u32, u32, u32, u64)> = Vec::with_capacity(count);
    let mut cursor = first_blob;
    for (crc, index, blob) in entries {
        recs.push((*crc, *index, blob.len() as u32, cursor as u64));
        cursor = align(cursor + blob.len(), 0x800);
    }
    let total = cursor;

    let mut out = vec![0xCBu8; total];
    out[0..4].copy_from_slice(b"00PM");
    out[4..8].copy_from_slice(&(count as u32).to_le_bytes());

    let mut p = 8;
    for (crc, index, size, off) in &recs {
        out[p..p + 4].copy_from_slice(&crc.to_le_bytes());
        out[p + 4..p + 8].copy_from_slice(&index.to_le_bytes());
        out[p + 8..p + 12].copy_from_slice(&size.to_le_bytes());
        out[p + 12..p + 20].copy_from_slice(&off.to_le_bytes());
        p += 20;
    }
    for (crc, index, _size, _off) in &recs {
        out[p..p + 4].copy_from_slice(&crc.to_le_bytes());
        out[p + 4..p + 8].copy_from_slice(&index.to_le_bytes());
        p += 8;
    }
    for ((_, _, _, off), (_, _, blob)) in recs.iter().zip(entries) {
        let o = *off as usize;
        out[o..o + blob.len()].copy_from_slice(blob);
    }
    std::fs::write(path, &out).map_err(|e| format!("write {path}: {e}"))
}
