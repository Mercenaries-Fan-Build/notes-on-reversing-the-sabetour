// sab_gametext — read / edit / add / write The Saboteur (2009) GameText.dlg
//
// GameText.dlg is the complete localized-text container (one file per language under
// Cinematics/Dialog/<Lang>/): it holds every UI string (objectives, mission names, tooltips,
// fail messages, shop/object display names — what GameTemplates and the Lua scripts reference)
// AND every cinematic VO subtitle. Verified against all six retail language files and the engine
// parser FUN_0095f370 @0x0095f370. See docs/formats/gametext.md.
//
// Byte layout (little-endian):
//   Header (12 bytes)
//     u32 version = 5
//     u32 record_count
//     u32 total_string_code_units          -- Σ str_len over the base records
//   record_count × Record                  -- contiguous, no padding
//     char magic[4] = "TXTD"
//     u32  asset_id                         -- pandemic_hash(dottedID) for UI; opaque id for VO.
//                                              EITHER WAY it is the store's lookup key.
//     u16  key_len                          -- bytes incl trailing NUL; 1 for UI text (a lone NUL)
//     char key[key_len]                     -- ASCII vo_ name + NUL, or a single NUL (never absent)
//     u16  str_len                          -- UTF-16 code units, INCLUDING the NUL terminator
//     u16  str[str_len]                     -- UTF-16LE, NUL-terminated
//   "DNEC" section                          -- per-cinematic-scene VO overlays
//     u32 group_count
//     group_count × { u32 scene_hash; u32 file_offset }   -- file_offset is ABSOLUTE
//     ... sub-blobs to EOF                  -- preserved verbatim; offsets rebased on write
//
// Lookup key: ALWAYS asset_id, for UI and VO records alike. The engine's tree insert
// (0x0095f5b9, key = &entry+0x18 = asset_id) runs unconditionally, before key_len is examined.
// For VO records the ascii key is separately hashed into entry+0x1c, which is the WWISE EVENT ID
// that Sound.PlayTextID fires -- NOT a lookup key.
//
// So adding a UI string = append a record whose asset_id is pandemic_hash("<File>_Text.<Key>") and
// whose key is a single NUL (key_len==1). No Lua LoadGameTextFile registration needed -- base
// records are always loaded (inferred from the load path, not confirmed in-game).

use std::env;
use std::fs;
use std::process::exit;

const MAGIC_REC: &[u8; 4] = b"TXTD";
const MAGIC_DNEC: &[u8; 4] = b"DNEC";
const VERSION: u32 = 5;

// ---- pandemic_hash (engine FUN_00dc1e20): FNV-1a, |0x20 fold, ^0x2A finalize ----
fn pandemic_hash(s: &[u8]) -> u32 {
    if s.is_empty() {
        return 0;
    }
    let mut h: u32 = 0x811C_9DC5;
    for &c in s {
        h = (((c as u32) | 0x20) ^ h).wrapping_mul(0x0100_0193);
    }
    (h ^ 0x2A).wrapping_mul(0x0100_0193)
}

#[derive(Clone)]
struct Record {
    asset_id: u32,
    /// Raw key bytes exactly as on disk, INCLUDING the trailing NUL. Empty for UI-text records.
    key: Vec<u8>,
    /// UTF-16LE code units of the localized string (no NUL terminator).
    text: Vec<u16>,
}

impl Record {
    /// A UI-text record has an empty key (on disk that is `key_len==1`, a single NUL); a VO record
    /// carries an ascii `vo_…` name. Both key and string are NUL-terminated on disk.
    fn is_ui(&self) -> bool {
        self.key_str().is_empty()
    }
    /// Display key: ascii key without the trailing NUL (VO), or "" (UI text).
    fn key_str(&self) -> String {
        let end = self.key.iter().position(|&b| b == 0).unwrap_or(self.key.len());
        String::from_utf8_lossy(&self.key[..end]).into_owned()
    }
    /// The localized string, without its trailing NUL terminator.
    fn text_string(&self) -> String {
        let end = self.text.iter().position(|&u| u == 0).unwrap_or(self.text.len());
        String::from_utf16_lossy(&self.text[..end])
    }
    /// On-disk byte size of this record.
    fn size(&self) -> usize {
        4 + 4 + 2 + self.key.len() + 2 + self.text.len() * 2
    }
}

/// Encode a Rust string to the on-disk UTF-16LE form: code units followed by a NUL terminator
/// (str_len counts the terminator, matching every retail record).
fn encode_text(s: &str) -> Vec<u16> {
    let mut v: Vec<u16> = s.encode_utf16().collect();
    v.push(0);
    v
}

struct GameText {
    version: u32,
    records: Vec<Record>,
    /// The whole post-records section, verbatim. If it begins with "DNEC" the directory offsets are
    /// rebased on write; otherwise it is copied unchanged.
    tail: Vec<u8>,
}

// ---------------------------------------------------------------- reader
struct Reader<'a> {
    b: &'a [u8],
    o: usize,
}
impl<'a> Reader<'a> {
    fn new(b: &'a [u8]) -> Self {
        Reader { b, o: 0 }
    }
    fn u16(&mut self) -> Result<u16, String> {
        if self.o + 2 > self.b.len() {
            return Err(format!("EOF reading u16 at {}", self.o));
        }
        let v = u16::from_le_bytes(self.b[self.o..self.o + 2].try_into().unwrap());
        self.o += 2;
        Ok(v)
    }
    fn u32(&mut self) -> Result<u32, String> {
        if self.o + 4 > self.b.len() {
            return Err(format!("EOF reading u32 at {}", self.o));
        }
        let v = u32::from_le_bytes(self.b[self.o..self.o + 4].try_into().unwrap());
        self.o += 4;
        Ok(v)
    }
    fn take(&mut self, n: usize) -> Result<&'a [u8], String> {
        if self.o + n > self.b.len() {
            return Err(format!("EOF reading {} bytes at {}", n, self.o));
        }
        let s = &self.b[self.o..self.o + n];
        self.o += n;
        Ok(s)
    }
}

fn parse(b: &[u8]) -> Result<GameText, String> {
    let mut r = Reader::new(b);
    let version = r.u32()?;
    if version != VERSION {
        return Err(format!("unexpected version {version}, expected {VERSION}"));
    }
    let count = r.u32()?;
    let total_cu = r.u32()?;
    let mut records = Vec::with_capacity(count as usize);
    let mut sum_cu: u64 = 0;
    for i in 0..count {
        let magic = r.take(4)?;
        if magic != MAGIC_REC {
            return Err(format!("record {i}: bad magic {magic:?}, expected TXTD at {}", r.o - 4));
        }
        let asset_id = r.u32()?;
        let key_len = r.u16()? as usize;
        let key = r.take(key_len)?.to_vec();
        let str_len = r.u16()? as usize;
        let raw = r.take(str_len * 2)?;
        let text: Vec<u16> = raw.chunks_exact(2).map(|c| u16::from_le_bytes([c[0], c[1]])).collect();
        sum_cu += str_len as u64;
        records.push(Record { asset_id, key, text });
    }
    if sum_cu != total_cu as u64 {
        // Not fatal (we recompute on write) but worth surfacing — it should hold on retail files.
        eprintln!(
            "warning: header total_string_code_units={total_cu} != Σ str_len={sum_cu}"
        );
    }
    let tail = b[r.o..].to_vec();
    Ok(GameText { version, records, tail })
}

// ---------------------------------------------------------------- writer
fn total_cu(records: &[Record]) -> u32 {
    records.iter().map(|r| r.text.len() as u32).sum()
}

/// Byte length of the header + all records (the base section) — where the tail begins.
fn base_len(records: &[Record]) -> usize {
    12 + records.iter().map(|r| r.size()).sum::<usize>()
}

fn write(gt: &GameText, orig_base_len: usize) -> Vec<u8> {
    let mut out = Vec::with_capacity(base_len(&gt.records) + gt.tail.len());
    out.extend_from_slice(&gt.version.to_le_bytes());
    out.extend_from_slice(&(gt.records.len() as u32).to_le_bytes());
    out.extend_from_slice(&total_cu(&gt.records).to_le_bytes());
    for rec in &gt.records {
        out.extend_from_slice(MAGIC_REC);
        out.extend_from_slice(&rec.asset_id.to_le_bytes());
        out.extend_from_slice(&(rec.key.len() as u16).to_le_bytes());
        out.extend_from_slice(&rec.key);
        out.extend_from_slice(&(rec.text.len() as u16).to_le_bytes());
        for &u in &rec.text {
            out.extend_from_slice(&u.to_le_bytes());
        }
    }
    // Tail: rebase absolute DNEC directory offsets by the shift in the base section.
    let new_base = base_len(&gt.records);
    let delta = new_base as i64 - orig_base_len as i64;
    let mut tail = gt.tail.clone();
    if delta != 0 && tail.len() >= 8 && &tail[0..4] == MAGIC_DNEC {
        let group_count = u32::from_le_bytes(tail[4..8].try_into().unwrap()) as usize;
        // directory: group_count × { u32 scene_hash, u32 file_offset }, offset at +4 of each pair
        for g in 0..group_count {
            let po = 8 + g * 8 + 4; // offset field
            if po + 4 > tail.len() {
                break;
            }
            let off = u32::from_le_bytes(tail[po..po + 4].try_into().unwrap());
            let rebased = (off as i64 + delta) as u32;
            tail[po..po + 4].copy_from_slice(&rebased.to_le_bytes());
        }
    }
    out.extend_from_slice(&tail);
    out
}

// ---------------------------------------------------------------- helpers
fn get_flag(args: &[String], name: &str) -> Option<String> {
    args.iter().position(|a| a == name).and_then(|i| args.get(i + 1).cloned())
}
fn has_flag(args: &[String], name: &str) -> bool {
    args.iter().any(|a| a == name)
}

fn usage() {
    eprintln!(
        "sab_gametext — The Saboteur GameText.dlg reader/writer\n\
\n\
  hash  <string>                       print pandemic_hash of a text id\n\
  info  <in.dlg>                       header + record kind counts + tail summary\n\
  list  <in.dlg> [--ui|--vo] [--limit N]   list records (asset_id, key, text preview)\n\
  get   <in.dlg> --id <DottedID>       print the localized string for a dotted UI id\n\
        <in.dlg> --hash 0x......       ... by raw asset_id\n\
  set   <in.dlg> <out.dlg> (--id <DottedID> | --hash 0x..) --text <STRING>\n\
                                       overwrite an existing record's string\n\
  add   <in.dlg> <out.dlg> --id <DottedID> --text <STRING>\n\
                                       append a NEW UI-text record (asset_id=pandemic_hash(id))\n\
  roundtrip <in.dlg>                   parse -> re-emit; assert byte-identical + exact consume\n"
    );
}

fn find_mut<'a>(gt: &'a mut GameText, args: &[String]) -> Result<&'a mut Record, String> {
    let id = if let Some(ids) = get_flag(args, "--id") {
        pandemic_hash(ids.as_bytes())
    } else if let Some(hs) = get_flag(args, "--hash") {
        u32::from_str_radix(hs.trim_start_matches("0x"), 16).map_err(|_| "bad --hash")?
    } else {
        return Err("need --id <DottedID> or --hash 0x...".into());
    };
    gt.records
        .iter_mut()
        .find(|r| r.asset_id == id)
        .ok_or_else(|| format!("no record with asset_id 0x{id:08x}"))
}

fn run() -> Result<(), String> {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        usage();
        return Ok(());
    }
    let cmd = args[0].as_str();
    let rest = &args[1..];
    match cmd {
        "hash" => {
            let s = rest.get(0).ok_or("need <string>")?;
            println!("0x{:08x}  pandemic_hash({s:?})", pandemic_hash(s.as_bytes()));
        }
        "info" => {
            let b = fs::read(rest.get(0).ok_or("need <in.dlg>")?).map_err(|e| e.to_string())?;
            let gt = parse(&b)?;
            let ui = gt.records.iter().filter(|r| r.is_ui()).count();
            let vo = gt.records.len() - ui;
            let tail_kind = if gt.tail.len() >= 4 && &gt.tail[0..4] == MAGIC_DNEC { "DNEC" } else { "opaque" };
            println!("version={}  records={}  (UI={ui}, VO={vo})", gt.version, gt.records.len());
            println!("total_string_code_units={}", total_cu(&gt.records));
            println!("tail={} bytes ({tail_kind})", gt.tail.len());
        }
        "list" => {
            let b = fs::read(rest.get(0).ok_or("need <in.dlg>")?).map_err(|e| e.to_string())?;
            let gt = parse(&b)?;
            let only_ui = has_flag(rest, "--ui");
            let only_vo = has_flag(rest, "--vo");
            let limit: usize = get_flag(rest, "--limit").and_then(|s| s.parse().ok()).unwrap_or(50);
            let mut n = 0;
            for r in &gt.records {
                if only_ui && !r.is_ui() {
                    continue;
                }
                if only_vo && r.is_ui() {
                    continue;
                }
                let kind = if r.is_ui() { "UI" } else { "VO" };
                let mut t = r.text_string();
                t.truncate(60);
                println!("0x{:08x} [{kind}] {:<40} {:?}", r.asset_id, r.key_str(), t);
                n += 1;
                if n >= limit {
                    println!("... (--limit {limit} reached)");
                    break;
                }
            }
        }
        "get" => {
            let b = fs::read(rest.get(0).ok_or("need <in.dlg>")?).map_err(|e| e.to_string())?;
            let mut gt = parse(&b)?;
            let r = find_mut(&mut gt, rest)?;
            println!("0x{:08x}  {:?}", r.asset_id, r.text_string());
        }
        "set" => {
            let inp = rest.get(0).ok_or("need <in>")?;
            let outp = rest.get(1).ok_or("need <out>")?;
            let text = get_flag(rest, "--text").ok_or("need --text <STRING>")?;
            let b = fs::read(inp).map_err(|e| e.to_string())?;
            let orig_base = {
                let g = parse(&b)?;
                base_len(&g.records)
            };
            let mut gt = parse(&b)?;
            {
                let r = find_mut(&mut gt, rest)?;
                r.text = encode_text(&text);
            }
            let out = write(&gt, orig_base);
            let gt2 = parse(&out)?; // prove validity
            fs::write(outp, &out).map_err(|e| e.to_string())?;
            println!("set string ({} CU incl NUL) -> {} bytes; re-parsed OK ({} records)", encode_text(&text).len(), out.len(), gt2.records.len());
        }
        "add" => {
            let inp = rest.get(0).ok_or("need <in>")?;
            let outp = rest.get(1).ok_or("need <out>")?;
            let id = get_flag(rest, "--id").ok_or("need --id <DottedID>")?;
            let text = get_flag(rest, "--text").ok_or("need --text <STRING>")?;
            let b = fs::read(inp).map_err(|e| e.to_string())?;
            let orig_base = base_len(&parse(&b)?.records);
            let mut gt = parse(&b)?;
            let asset_id = pandemic_hash(id.as_bytes());
            if gt.records.iter().any(|r| r.asset_id == asset_id) {
                return Err(format!("id {id:?} (0x{asset_id:08x}) already exists — use `set`"));
            }
            // UI record on-disk form: key = single NUL (empty C-string, key_len==1); NUL-terminated text.
            gt.records.push(Record { asset_id, key: vec![0u8], text: encode_text(&text) });
            let out = write(&gt, orig_base);
            let gt2 = parse(&out)?;
            fs::write(outp, &out).map_err(|e| e.to_string())?;
            println!("added UI id {id:?} = 0x{asset_id:08x} ({} CU incl NUL); now {} records, {} bytes", encode_text(&text).len(), gt2.records.len(), out.len());
        }
        "roundtrip" => {
            let inp = rest.get(0).ok_or("need <in.dlg>")?;
            let b = fs::read(inp).map_err(|e| e.to_string())?;
            let gt = parse(&b)?;
            let orig_base = base_len(&gt.records);
            let out = write(&gt, orig_base);
            let byte_ident = out == b;
            println!(
                "roundtrip {inp}: records={} tail={}B  exact_consume={}  BYTE_IDENTICAL={}",
                gt.records.len(),
                gt.tail.len(),
                orig_base + gt.tail.len() == b.len(),
                byte_ident
            );
            if !byte_ident {
                return Err("round-trip NOT byte-identical".into());
            }
        }
        _ => usage(),
    }
    Ok(())
}

fn main() {
    if let Err(e) = run() {
        eprintln!("error: {e}");
        exit(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn hash_vector() {
        assert_eq!(pandemic_hash(b"ANY"), 0xED05_7225);
        assert_eq!(pandemic_hash(b""), 0);
    }
}
