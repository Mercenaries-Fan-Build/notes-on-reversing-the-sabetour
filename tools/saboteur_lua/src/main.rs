//! saboteur_lua — reader for The Saboteur's `.luap` Lua script packs.
//!
//! Format derived from the loader `FUN_00706670` @ 0x00706670 in the clean decomp,
//! then confirmed byte-for-byte against retail `LuaScripts.luap`.
//! See docs/formats/lua_scripts.md.
//!
//!   u32                 count
//!   Descriptor[count]   21 bytes each, packed (NOT 24 — the 0x18 stride is in-memory padding)
//!   u8[..]              bytecode blob (the loader slurps the WHOLE file; offsets are ABSOLUTE)
//!
//! Descriptor:
//!   +0x00 u32  name hash (pandemic_hash of the script path)
//!   +0x04 u32  second hash — semantics unresolved
//!   +0x08 u32  absolute file offset of the chunk
//!   +0x0C u32  stored size      \ equal in every retail entry (flag == 0 => uncompressed)
//!   +0x10 u32  uncompressed size/
//!   +0x14 u8   flag (0 = stored plain)
//!
//! Usage: saboteur_lua <LuaScripts.luap> <outdir>

use std::collections::BTreeMap;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};

const DESC_SIZE: usize = 21;
const LUAQ_MAGIC: &[u8] = b"\x1bLuaQ";

#[derive(Debug, Clone)]
struct Desc {
    name_hash: u32,
    hash2: u32,
    offset: u32,
    stored_size: u32,
    size: u32,
    flag: u8,
}

fn rd_u32(b: &[u8], off: usize) -> u32 {
    u32::from_le_bytes([b[off], b[off + 1], b[off + 2], b[off + 3]])
}

/// pandemic_hash — exact transcription of `FUN_00dc1e20` @ 0x00dc1e20.
///
/// FNV-1a with a `| 0x20` case-fold per byte, then a finalizer that XORs 0x2A
/// into the accumulator and multiplies ONE more time. Note the finalizer order:
/// `(h ^ 0x2A) * PRIME`, NOT `(h * PRIME) ^ 0x2A`. Verified: hash("ANY") == 0xED057225.
fn pandemic_hash(s: &str) -> u32 {
    const PRIME: u32 = 0x0100_0193;
    let b = s.as_bytes();
    if b.is_empty() {
        return 0;
    }
    let mut h: u32 = 0x811C_9DC5;
    for &c in b {
        h = ((c | 0x20) as u32 ^ h).wrapping_mul(PRIME);
    }
    (h ^ 0x2A).wrapping_mul(PRIME)
}

/// Pull the `source` string out of a Lua 5.1 chunk's top-level prototype.
/// Layout: 12-byte LuaQ header, then the proto's `source` = u32 len + bytes (NUL-terminated).
fn luaq_source_name(chunk: &[u8]) -> Option<String> {
    if chunk.len() < 17 || !chunk.starts_with(LUAQ_MAGIC) {
        return None;
    }
    let len = rd_u32(chunk, 12) as usize;
    if len == 0 || len > 512 || 16 + len > chunk.len() {
        return None;
    }
    let raw = &chunk[16..16 + len];
    let raw = raw.strip_suffix(&[0]).unwrap_or(raw);
    Some(String::from_utf8_lossy(raw).into_owned())
}

/// Crude but robust string harvest: printable ASCII runs >= 4 chars.
/// Feeds the name->hash dictionary the megapack reader will need.
fn harvest_strings(chunk: &[u8], out: &mut BTreeMap<String, u32>) {
    let mut cur = Vec::new();
    for &b in chunk {
        if (0x20..0x7f).contains(&b) {
            cur.push(b);
        } else {
            if cur.len() >= 4 {
                if let Ok(s) = std::str::from_utf8(&cur) {
                    *out.entry(s.to_string()).or_insert(0) += 1;
                }
            }
            cur.clear();
        }
    }
    if cur.len() >= 4 {
        if let Ok(s) = std::str::from_utf8(&cur) {
            *out.entry(s.to_string()).or_insert(0) += 1;
        }
    }
}

/// Map the embedded source path to a safe relative output path.
/// e.g. "D:\projects\WildStar\pov\BinCommon\Scripts\AI\Soldier.lua" -> "AI/Soldier.lua"
fn out_rel_path(source: &str, idx: usize) -> PathBuf {
    let norm = source.replace('\\', "/");
    let tail = match norm.to_lowercase().find("/scripts/") {
        Some(p) => &norm[p + "/scripts/".len()..],
        None => norm.trim_start_matches(|c: char| c == '@' || c == '/'),
    };
    let tail = tail.trim_start_matches('@');
    let mut p = PathBuf::new();
    let mut any = false;
    for seg in tail.split('/') {
        let seg: String = seg
            .chars()
            .filter(|c| c.is_alphanumeric() || matches!(c, '.' | '_' | '-' | ' '))
            .collect();
        if seg.is_empty() || seg == ".." {
            continue;
        }
        p.push(seg);
        any = true;
    }
    if !any {
        p.push(format!("unnamed_{idx:04}.luac"));
    }
    p
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Self-test the hash before trusting anything it says.
    let anyhash = pandemic_hash("ANY");
    let hash_ok = anyhash == 0xED05_7225;
    eprintln!(
        "pandemic_hash(\"ANY\") = 0x{anyhash:08X}  (expect 0xED057225) -> {}",
        if hash_ok { "OK" } else { "MISMATCH" }
    );

    let args: Vec<String> = std::env::args().collect();
    if args.len() < 3 {
        eprintln!("usage: saboteur_lua <LuaScripts.luap> <outdir>");
        std::process::exit(2);
    }
    let src = Path::new(&args[1]);
    let outdir = Path::new(&args[2]);

    let data = fs::read(src)?;
    println!("\n{} — {} bytes", src.display(), data.len());

    let count = rd_u32(&data, 0) as usize;
    println!("count = {count}");

    let table_end = 4 + count * DESC_SIZE;
    if table_end > data.len() {
        return Err(format!("descriptor table ({table_end}) overruns file ({})", data.len()).into());
    }

    let mut descs = Vec::with_capacity(count);
    for i in 0..count {
        let o = 4 + i * DESC_SIZE;
        descs.push(Desc {
            name_hash: rd_u32(&data, o),
            hash2: rd_u32(&data, o + 4),
            offset: rd_u32(&data, o + 8),
            stored_size: rd_u32(&data, o + 12),
            size: rd_u32(&data, o + 16),
            flag: data[o + 20],
        });
    }

    // --- structural validation: the format claims should hold on every entry ---
    let mut bad = 0usize;
    let mut flags_set = 0usize;
    let mut size_mismatch = 0usize;
    for (i, d) in descs.iter().enumerate() {
        let end = d.offset as usize + d.size as usize;
        if end > data.len() {
            eprintln!("  !! entry {i}: chunk [{}..{end}] overruns file", d.offset);
            bad += 1;
        }
        if d.stored_size != d.size {
            size_mismatch += 1;
        }
        if d.flag != 0 {
            flags_set += 1;
        }
    }
    println!("first chunk offset = {} (header ends at {table_end})", descs[0].offset);
    println!("entries with stored_size != size : {size_mismatch}");
    println!("entries with flag != 0           : {flags_set}");
    if bad > 0 {
        return Err(format!("{bad} entries overrun the file — format is wrong").into());
    }

    // --- extract ---
    fs::create_dir_all(outdir)?;
    let mut index = String::from("idx\tname_hash\thash2\toffset\tsize\tflag\thash_matches_source\tsource_path\n");
    let mut strings: BTreeMap<String, u32> = BTreeMap::new();
    let mut luaq_ok = 0usize;
    let mut named = 0usize;
    let mut hash_confirms = 0usize;

    for (i, d) in descs.iter().enumerate() {
        let s = d.offset as usize;
        let chunk = &data[s..s + d.size as usize];

        if chunk.starts_with(LUAQ_MAGIC) {
            luaq_ok += 1;
        }
        harvest_strings(chunk, &mut strings);

        let source = luaq_source_name(chunk);
        if source.is_some() {
            named += 1;
        }
        let source_disp = source.clone().unwrap_or_else(|| "<no debug info>".into());

        // hash2 (+0x04) == pandemic_hash(basename without extension). Holds 321/321 on retail.
        // name_hash (+0x00) is NOT reproducible from the embedded source path under any
        // normalization tried, nor is it crc32/adler32 of the chunk — still open.
        let mut matched = "no";
        if hash_ok {
            if let Some(src_path) = &source {
                let norm = src_path.trim_start_matches('@').replace('/', "\\");
                let base = norm.rsplit('\\').next().unwrap_or(&norm);
                let stem = base.rsplit_once('.').map(|(s, _)| s).unwrap_or(base);
                if pandemic_hash(stem) == d.hash2 {
                    matched = "hash2=basename";
                    hash_confirms += 1;
                }
            }
        }

        let rel = match &source {
            Some(sp) => out_rel_path(sp, i),
            None => PathBuf::from(format!("_unnamed/{i:04}_{:08x}.luac", d.name_hash)),
        };
        let dest = outdir.join("chunks").join(&rel);
        if let Some(parent) = dest.parent() {
            fs::create_dir_all(parent)?;
        }
        fs::write(&dest, chunk)?;

        index.push_str(&format!(
            "{i}\t{:08x}\t{:08x}\t{}\t{}\t{}\t{}\t{}\n",
            d.name_hash, d.hash2, d.offset, d.size, d.flag, matched, source_disp
        ));
    }

    fs::write(outdir.join("index.tsv"), &index)?;

    let mut sf = fs::File::create(outdir.join("strings.txt"))?;
    for (s, n) in &strings {
        writeln!(sf, "{n}\t{s}")?;
    }

    println!("\n--- results ---");
    println!("extracted        : {count} chunks -> {}", outdir.join("chunks").display());
    println!("valid LuaQ magic : {luaq_ok}/{count}");
    println!("with source path : {named}/{count}");
    println!("hash2 reproduced : {hash_confirms}/{count}  (hash2 == pandemic_hash(basename-no-ext))");
    println!("unique strings   : {}  -> strings.txt", strings.len());
    println!("index            : {}", outdir.join("index.tsv").display());
    Ok(())
}
