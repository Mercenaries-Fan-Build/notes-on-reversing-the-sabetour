//! AP0L `ANIM` metadata reader for The Saboteur (2009) `Animations.pack`.
//!
//! Emits, per main-blob clip, its ordered track->bone binding so a decoded
//! Havok spline clip (see `tools/sab_havok65`) can be rigged onto a named
//! skeleton.
//!
//! ## What the ANIM block is (CONFIRMED against real bytes + SaboteurToolset)
//! The pack starts `"AP0L"` then a sequence of FourCC-tagged blocks. The FIRST
//! block is `ANIM` (file bytes `MINA`). Its body, per SaboteurToolset
//! `animpack/anim_extract.cpp::ProcessANIM` (spike `BinReaderRef`), is:
//!
//!   u32 recordCount                       // 3463 in retail
//!   record[recordCount] {
//!       u32  id                           // pandemic hash seed
//!       u8   unk4  (bool)
//!       u8   streamed (bool)
//!       u32  nameLen ; char name[nameLen] // ReadContainer(std::string) => u32 len
//!       f32  duration
//!       if !streamed: u32 boneCount ; u32 bones[boneCount]   // <-- the track->bone list
//!       f32  unk0[8]
//!       u8   unk1  (bool)
//!       u32  n2 ; ANIMStruct0 unk2[n2]    // ANIMStruct0 = u32[10]  (40 B)
//!       u32  n3 ; ANIMStruct1 unk3[n3]    // ANIMStruct1 = u32,u8(null),f32[2],u32 (17 B)
//!   }
//!   u32 numAnims ; u32 hkSize             // then the concatenated animations.hkx blob
//!
//! Walking `recordCount` records lands the cursor EXACTLY on the `numAnims`
//! (=2214) / `hkSize` (=0x80FB00) pair that immediately precedes the first
//! Havok packfile magic `57 e0 e0 57` at file 0xDECE1 — a decisive structural
//! self-check. The 2214 `streamed==false` records map 1:1, in order, to the
//! 2214 `hkaSplineCompressedAnimation` objects in the main blob (streamed
//! records carry no bone list; their sub-animations live in the SSP0 block).
//!
//! ## The `bones` field is polymorphic (KEY finding)
//!   * biped clips (2155/2214) store per-track **bone INDICES** into the shared
//!     biped skeleton (values 0..190, `0xFFFFFFFF` = unbound/no-bone sentinel).
//!   * exotic-skeleton clips (59/2214: Cow/Chicken/bird) store per-track
//!     **bone name-HASHES** (pandemic_hash of the bone name) directly.
//! In both cases `len(bones) == numTransformTracks` (the ground-truth oracle).
//! Index values resolve to name-hashes through the character skeleton's
//! bone-index order (`CH_AL_SeanDevlin.json`, 191 bones); the resulting names
//! form a valid ordered biped hierarchy (GlobalSRT, Bone_Root, Bone_Hips,
//! Bone_LThigh, ...), and the hash-style clips independently reference the same
//! bone hashes (GlobalSRT, Bone_Chest, Bone_Head), cross-confirming the order.

// A couple of helpers/fields document the on-disk format without being on the
// hot path (u16le; skeleton name_of map for callers that want names).
#![allow(dead_code)]

use std::collections::{HashMap, HashSet};
use std::env;
use std::fs;

const SENTINEL: u32 = 0xFFFF_FFFF;

// ---------- little-endian helpers ----------
fn u16le(b: &[u8], o: usize) -> u16 { u16::from_le_bytes([b[o], b[o + 1]]) }
fn u32le(b: &[u8], o: usize) -> u32 { u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn f32le(b: &[u8], o: usize) -> f32 { f32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]]) }
fn find_sub(hay: &[u8], n: &[u8]) -> Option<usize> { hay.windows(n.len()).position(|w| w == n) }

// ---------- ANIM record ----------
struct Clip {
    index: usize,          // 0..N over the non-streamed (main-blob) clips
    id: u32,               // pandemic-hash seed / clip id
    name: String,
    duration: f32,
    unk4: bool,
    unk1: bool,
    bones: Vec<u32>,       // raw stored values (index, hash, or 0xFFFFFFFF)
}

/// Parse the leading ANIM block. Returns (clips, numAnims, hkSize).
fn parse_anim(file: &[u8]) -> Result<(Vec<Clip>, u32, u32), String> {
    if &file[0..4] != b"L0PA" {
        return Err("not an AP0L pack (magic != L0PA/AP0L)".into());
    }
    // First block id at offset 4 must be ANIM (bytes "MINA").
    if &file[4..8] != b"MINA" {
        return Err(format!("first block is not ANIM: {:?}", &file[4..8]));
    }
    let mut o = 8usize;
    let count = u32le(file, o) as usize; o += 4;
    let mut clips = Vec::new();
    let mut clip_index = 0usize;
    for _ in 0..count {
        let _id = u32le(file, o); o += 4;
        let unk4 = file[o] != 0; o += 1;
        let streamed = file[o] != 0; o += 1;
        let nlen = u32le(file, o) as usize; o += 4;
        let name = String::from_utf8_lossy(&file[o..o + nlen]).into_owned(); o += nlen;
        let duration = f32le(file, o); o += 4;
        let mut bones = Vec::new();
        if !streamed {
            let bc = u32le(file, o) as usize; o += 4;
            bones.reserve(bc);
            for i in 0..bc { bones.push(u32le(file, o + i * 4)); }
            o += bc * 4;
        }
        o += 8 * 4;                    // f32 unk0[8]
        let unk1 = file[o] != 0; o += 1;
        let n2 = u32le(file, o) as usize; o += 4; o += n2 * 40;   // ANIMStruct0[10*u32]
        let n3 = u32le(file, o) as usize; o += 4; o += n3 * 17;   // ANIMStruct1
        if !streamed {
            clips.push(Clip { index: clip_index, id: _id, name, duration, unk4, unk1, bones });
            clip_index += 1;
        }
    }
    let num_anims = u32le(file, o); o += 4;
    let hk_size = u32le(file, o);
    Ok((clips, num_anims, hk_size))
}

// ---------- Havok packfile: enumerate hkaSplineCompressedAnimation track counts ----------
// Minimal port of tools/sab_havok65 main.rs `Packfile::parse` — just enough to
// read numTransformTracks (obj+0x10) for each spline anim, in file order.
fn spline_track_counts(file: &[u8]) -> Result<Vec<usize>, String> {
    let magic = [0x57u8, 0xe0, 0xe0, 0x57];
    let blob_off = find_sub(file, &magic).ok_or("no havok magic in pack")?;
    let hk_size = u32le(file, blob_off - 4) as usize;
    let blob = &file[blob_off..blob_off + hk_size];

    let sh = find_sub(blob, b"__classnames__").ok_or("no __classnames__")?;
    let mut secs = [[0u32; 7]; 3];
    for s in 0..3 { for k in 0..7 { secs[s][k] = u32le(blob, sh + s * 48 + 20 + k * 4); } }
    let body0 = sh + 3 * 48;
    let cn_len = secs[0][6] as usize;
    let data_pk = body0 + secs[0][6] as usize + secs[1][6] as usize;

    // classnames: body-rel offset -> name
    let mut names: HashMap<usize, String> = HashMap::new();
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

    // __data__ virtual fixups bind objects -> class; keep spline-anim obj offsets in order.
    let (d_vf, d_end) = (secs[2][3] as usize, secs[2][4] as usize);
    let mut counts = Vec::new();
    let mut k = data_pk + d_vf;
    let vf_end = data_pk + d_end;
    while k + 12 <= vf_end {
        let src = u32le(blob, k) as usize;
        let cnoff = u32le(blob, k + 8) as usize;
        if src as u32 == 0xFFFF_FFFF { break; }
        k += 12;
        if names.get(&cnoff).map(|s| s == "hkaSplineCompressedAnimation").unwrap_or(false) {
            let ntt = u32le(blob, data_pk + src + 0x10) as usize; // numTransformTracks
            counts.push(ntt);
        }
    }
    Ok(counts)
}

// ---------- skeleton JSON (std-only, tolerant) ----------
struct Skeleton {
    hash_by_index: Vec<u32>,           // bones[] name_hash in index order
    set: HashSet<u32>,
    name_of: HashMap<u32, String>,
}

/// Extract, in document order, every `"name_hash": <u32>` and its following
/// `"name": "<...>"` from the skeleton JSON. The `bones` array is index-ordered,
/// so the n-th name_hash is the hash of bone index n.
fn parse_skeleton(text: &str) -> Skeleton {
    let b = text.as_bytes();
    let mut hash_by_index = Vec::new();
    let mut set = HashSet::new();
    let mut name_of = HashMap::new();
    let key = b"\"name_hash\"";
    let mut i = 0usize;
    while let Some(rel) = find_sub(&b[i..], key) {
        let mut p = i + rel + key.len();
        // skip ": " / whitespace up to first digit
        while p < b.len() && !(b[p] as char).is_ascii_digit() { p += 1; }
        let mut val: u64 = 0;
        let mut any = false;
        while p < b.len() && (b[p] as char).is_ascii_digit() {
            val = val * 10 + (b[p] - b'0') as u64; p += 1; any = true;
        }
        i = p;
        if !any { continue; }
        let h = val as u32;
        // look for the bone "name" within the next window before the next name_hash
        let window_end = find_sub(&b[p..], key).map(|r| p + r).unwrap_or(b.len());
        let mut name = None;
        if let Some(nrel) = find_sub(&b[p..window_end], b"\"name\"") {
            let mut q = p + nrel + 6;
            while q < window_end && b[q] != b':' { q += 1; }
            q += 1;
            while q < window_end && (b[q] == b' ' || b[q] == b'\t') { q += 1; }
            if q < window_end && b[q] == b'"' {
                q += 1;
                let start = q;
                while q < window_end && b[q] != b'"' { q += 1; }
                name = Some(String::from_utf8_lossy(&b[start..q]).into_owned());
            }
        }
        hash_by_index.push(h);
        set.insert(h);
        if let Some(n) = name { if !n.is_empty() { name_of.insert(h, n); } }
    }
    Skeleton { hash_by_index, set, name_of }
}

// ---------- resolution ----------
#[derive(PartialEq)]
enum Repr { Index, Hash, Mixed, Empty }

fn classify(bones: &[u32], nbones: usize) -> Repr {
    let nz: Vec<u32> = bones.iter().copied().filter(|&x| x != SENTINEL).collect();
    if nz.is_empty() { return Repr::Empty; }
    let all_idx = nz.iter().all(|&x| (x as usize) < nbones);
    if all_idx { return Repr::Index; }
    let all_hash = nz.iter().all(|&x| x >= 256);
    if all_hash { return Repr::Hash; }
    Repr::Mixed
}

fn repr_str(r: &Repr) -> &'static str {
    match r { Repr::Index => "index", Repr::Hash => "hash", Repr::Mixed => "mixed", Repr::Empty => "empty" }
}

/// Resolve one raw bone value to a skeleton name-hash (None = sentinel/unbound).
fn resolve(raw: u32, repr: &Repr, sk: &Skeleton) -> Option<u32> {
    if raw == SENTINEL { return None; }
    match repr {
        Repr::Hash => Some(raw),
        // index / mixed: values < nbones are indices; anything else is a literal hash
        _ => {
            if (raw as usize) < sk.hash_by_index.len() { Some(sk.hash_by_index[raw as usize]) }
            else { Some(raw) }
        }
    }
}

fn json_str(s: &str) -> String {
    let mut o = String::with_capacity(s.len() + 2);
    o.push('"');
    for c in s.chars() {
        match c { '"' => o.push_str("\\\""), '\\' => o.push_str("\\\\"),
                  '\n' => o.push_str("\\n"), '\t' => o.push_str("\\t"),
                  c if (c as u32) < 0x20 => o.push_str(&format!("\\u{:04x}", c as u32)),
                  c => o.push(c) }
    }
    o.push('"');
    o
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("usage: sab_animmeta <Animations.pack> [skeleton.json] <out.json>");
        std::process::exit(2);
    }
    // args: pack [skel] out
    let (pack_path, skel_path, out_path) = if args.len() >= 4 {
        (args[1].clone(), Some(args[2].clone()), args[3].clone())
    } else {
        (args[1].clone(), None, args[2].clone())
    };

    let file = fs::read(&pack_path).expect("read pack");
    let (clips, num_anims, hk_size) = parse_anim(&file).expect("parse ANIM");
    println!("ANIM: {} main-blob (non-streamed) clips; numAnims={} hkSize=0x{:x}",
             clips.len(), num_anims, hk_size);

    // ground-truth oracle: numTransformTracks per spline anim, in file order
    let track_counts = spline_track_counts(&file).expect("parse havok blob");
    println!("hkaSplineCompressedAnimation objects in main blob: {}", track_counts.len());

    let mut matched = 0usize;
    let mut mismatches: Vec<(usize, usize, usize)> = Vec::new();
    for (i, c) in clips.iter().enumerate() {
        let ntt = track_counts.get(i).copied().unwrap_or(usize::MAX);
        if c.bones.len() == ntt { matched += 1; }
        else { mismatches.push((i, c.bones.len(), ntt)); }
    }
    println!("ORACLE len(bones)==numTransformTracks: {}/{} match", matched, clips.len());
    if !mismatches.is_empty() {
        println!("  first mismatches (clip, nbones, ntt): {:?}",
                 &mismatches[..mismatches.len().min(10)]);
    }

    // optional skeleton resolution
    let skel = skel_path.as_ref().map(|p| parse_skeleton(&fs::read_to_string(p).expect("read skeleton")));
    if let Some(sk) = &skel {
        println!("skeleton: {} bones", sk.hash_by_index.len());
    }

    // emit JSON
    let mut out = String::new();
    out.push_str("{\n");
    out.push_str(&format!("  \"pack\": {},\n", json_str(&pack_path)));
    out.push_str(&format!("  \"num_main_clips\": {},\n", clips.len()));
    out.push_str(&format!("  \"num_anims\": {},\n", num_anims));
    out.push_str(&format!("  \"hk_size\": {},\n", hk_size));
    out.push_str(&format!("  \"oracle_track_match\": {},\n", matched));
    if let Some(sk) = &skel {
        out.push_str(&format!("  \"skeleton_bones\": {},\n", sk.hash_by_index.len()));
    }
    out.push_str("  \"clips\": [\n");

    let mut n_index = 0usize; let mut n_hash = 0usize; let mut n_mixed = 0usize;
    let mut subset_clips: Vec<(usize, String, usize)> = Vec::new();

    for (i, c) in clips.iter().enumerate() {
        let nbones = skel.as_ref().map(|s| s.hash_by_index.len()).unwrap_or(191);
        let repr = classify(&c.bones, nbones);
        match repr { Repr::Index => n_index += 1, Repr::Hash => n_hash += 1,
                     Repr::Mixed => n_mixed += 1, Repr::Empty => {} }

        // resolved hashes + subset test
        let mut resolved: Vec<Option<u32>> = Vec::with_capacity(c.bones.len());
        let mut is_subset = !c.bones.is_empty();
        for &raw in &c.bones {
            let r = skel.as_ref().and_then(|sk| resolve(raw, &repr, sk));
            if let (Some(sk), Some(h)) = (skel.as_ref(), r) {
                if !sk.set.contains(&h) { is_subset = false; }
            } else if raw != SENTINEL && skel.is_some() {
                is_subset = false;
            }
            resolved.push(r);
        }
        if skel.is_some() && is_subset {
            subset_clips.push((i, c.name.clone(), c.bones.len()));
        }

        let ntt = track_counts.get(i).copied().unwrap_or(0);
        out.push_str("    {");
        out.push_str(&format!("\"index\": {}, ", c.index));
        out.push_str(&format!("\"id\": \"0x{:08X}\", ", c.id));
        out.push_str(&format!("\"name\": {}, ", json_str(&c.name)));
        out.push_str(&format!("\"duration\": {:.6}, ", c.duration));
        out.push_str(&format!("\"num_tracks\": {}, ", c.bones.len()));
        out.push_str(&format!("\"num_transform_tracks\": {}, ", ntt));
        out.push_str(&format!("\"track_count_matches\": {}, ", c.bones.len() == ntt));
        out.push_str(&format!("\"streamed\": false, "));
        out.push_str(&format!("\"flags\": {{\"unk4\": {}, \"unk1\": {}}}, ", c.unk4, c.unk1));
        out.push_str(&format!("\"bone_repr\": {}, ", json_str(repr_str(&repr))));
        // raw ids
        out.push_str("\"bone_ids\": [");
        for (j, v) in c.bones.iter().enumerate() {
            if j > 0 { out.push(','); }
            out.push_str(&v.to_string());
        }
        out.push_str("], ");
        // resolved name-hashes (null = unbound sentinel)
        out.push_str("\"bone_hashes\": [");
        for (j, r) in resolved.iter().enumerate() {
            if j > 0 { out.push(','); }
            match r { Some(h) => out.push_str(&h.to_string()), None => out.push_str("null") }
        }
        out.push(']');
        if skel.is_some() {
            out.push_str(&format!(", \"subset_of_skeleton\": {}", is_subset));
        }
        out.push('}');
        if i + 1 < clips.len() { out.push(','); }
        out.push('\n');
    }
    out.push_str("  ]\n}\n");
    fs::write(&out_path, &out).expect("write out json");

    println!("bone_repr census: index={} hash={} mixed={}", n_index, n_hash, n_mixed);
    if skel.is_some() {
        println!("clips that are a subset of the skeleton (preview candidates): {}", subset_clips.len());
        print!("  examples:");
        for (i, name, n) in subset_clips.iter().take(8) {
            print!("  #{}({},{}t)", i, name, n);
        }
        println!();
    }
    println!("wrote {}", out_path);
}
