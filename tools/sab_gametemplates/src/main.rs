// sab_gametemplates — read / modify / write The Saboteur (2009) GameTemplates.wsd
//
// Container format (magic "AULB"). Verified against DLC/01/GameTemplates.wsd and
// the game loader FUN_0162bfa0 @0x0162bfa0 (decomp). See docs/formats/gametemplates.md.
//
//   char   magic[4]      = "AULB"
//   u32    entry_count                          (little-endian)
//   entry_count x Entry                         (contiguous, NO extra padding)
//
// Entry is one of:
//   * Marker  : total_size==8 followed by 8 zero bytes (12 bytes total). Acts as a
//               group separator; still consumes one entry_count slot. The big
//               main-game file (loosefiles_BinPC.pack @0x2732c50) has 311 of these
//               among 11072 entries; the small DLC file has none.
//   * Template: a full TemplateRecord (below).
//
// TemplateRecord:
//   u32    total_size    = number of bytes of this record AFTER this field
//   u32    unk1          (always 0 observed)
//   u32    unk2          (always 1 observed)
//   u32    name_len      = strlen(name)+1  (includes NUL)
//   u8     name[name_len]                  (ASCII + trailing NUL)
//   u32    type_len      = strlen(type)+1  (includes NUL)
//   u8     type[type_len]                  (ASCII + trailing NUL)
//   u32    pair_count
//   pair_count x Pair
//
// Pair:
//   u32    hash          stored little-endian; == pandemic_hash(property_name)
//   u32    data_size
//   u8     data[data_size]
//
// All multi-byte integers are little-endian (native x86 dword reads in the engine,
// see u32-reader FUN_00463b00 @0x00463b00). The community "GameTemplates-Helper"
// reads the pair hash as big-endian for *display* only; the engine (and the
// pandemic_hash match) uses the little-endian value.

use std::collections::HashMap;
use std::env;
use std::fs;
use std::process::exit;

const MAGIC: &[u8; 4] = b"AULB";

// ---- pandemic_hash (FNV-1a variant with |0x20 lowercasing + 0x2A finalize) ----
fn pandemic_hash(s: &str) -> u32 {
    let mut h: u32 = 0x811C9DC5;
    for &c in s.as_bytes() {
        h = ((((c as u32) | 0x20) ^ h)).wrapping_mul(0x0100_0193);
    }
    (h ^ 0x2A).wrapping_mul(0x0100_0193)
}

#[derive(Clone)]
struct Pair {
    hash: u32,
    data: Vec<u8>,
}

#[derive(Clone)]
struct Template {
    unk1: u32,
    unk2: u32,
    name: Vec<u8>, // WITHOUT NUL
    ttype: Vec<u8>,
    pairs: Vec<Pair>,
}

#[derive(Clone)]
enum Entry {
    Marker,
    Template(Template),
}

struct GameTemplates {
    entries: Vec<Entry>,
}

impl GameTemplates {
    fn templates(&self) -> impl Iterator<Item = (usize, &Template)> {
        self.entries.iter().enumerate().filter_map(|(i, e)| match e {
            Entry::Template(t) => Some((i, t)),
            Entry::Marker => None,
        })
    }
}

const MARKER: [u8; 12] = [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

struct Reader<'a> {
    b: &'a [u8],
    o: usize,
}
impl<'a> Reader<'a> {
    fn new(b: &'a [u8]) -> Self {
        Reader { b, o: 0 }
    }
    fn u32(&mut self) -> Result<u32, String> {
        if self.o + 4 > self.b.len() {
            return Err(format!("EOF reading u32 at {}", self.o));
        }
        let v = u32::from_le_bytes(self.b[self.o..self.o + 4].try_into().unwrap());
        self.o += 4;
        Ok(v)
    }
    fn bytes(&mut self, n: usize) -> Result<&'a [u8], String> {
        if self.o + n > self.b.len() {
            return Err(format!("EOF reading {} bytes at {}", n, self.o));
        }
        let s = &self.b[self.o..self.o + n];
        self.o += n;
        Ok(s)
    }
}

fn parse(b: &[u8]) -> Result<(GameTemplates, usize), String> {
    let mut r = Reader::new(b);
    let magic = r.bytes(4)?;
    if magic != MAGIC {
        return Err(format!("bad magic {:?}, expected AULB", magic));
    }
    let count = r.u32()?;
    let mut entries = Vec::with_capacity(count as usize);
    for ti in 0..count {
        // Marker entry: total_size==8 + 8 zero bytes (12 bytes).
        if r.o + 12 <= b.len() && b[r.o..r.o + 12] == MARKER {
            r.o += 12;
            entries.push(Entry::Marker);
            continue;
        }
        let rec_start = r.o;
        let total_size = r.u32()?;
        let body_start = r.o;
        let unk1 = r.u32()?;
        let unk2 = r.u32()?;
        let nlen = r.u32()? as usize;
        if nlen == 0 {
            return Err(format!("template {}: name_len==0", ti));
        }
        let name = r.bytes(nlen)?[..nlen - 1].to_vec(); // drop NUL
        let tlen = r.u32()? as usize;
        if tlen == 0 {
            return Err(format!("template {}: type_len==0", ti));
        }
        let ttype = r.bytes(tlen)?[..tlen - 1].to_vec();
        let pcount = r.u32()?;
        let mut pairs = Vec::with_capacity(pcount as usize);
        for _ in 0..pcount {
            let hash = r.u32()?;
            let dsize = r.u32()? as usize;
            let data = r.bytes(dsize)?.to_vec();
            pairs.push(Pair { hash, data });
        }
        // Verify total_size == bytes consumed after the total_size field.
        let measured = (r.o - body_start) as u32;
        if measured != total_size {
            return Err(format!(
                "template {} ({:?}): total_size={} but measured body={} (rec_start={})",
                ti,
                String::from_utf8_lossy(&name),
                total_size,
                measured,
                rec_start
            ));
        }
        entries.push(Entry::Template(Template {
            unk1,
            unk2,
            name,
            ttype,
            pairs,
        }));
    }
    Ok((GameTemplates { entries }, r.o))
}

fn record_body_size(t: &Template) -> u32 {
    let mut n = 4 + 4; // unk1 + unk2
    n += 4 + (t.name.len() + 1); // name_len + name + NUL
    n += 4 + (t.ttype.len() + 1); // type_len + type + NUL
    n += 4; // pair_count
    for p in &t.pairs {
        n += 4 + 4 + p.data.len(); // hash + data_size + data
    }
    n as u32
}

fn write(gt: &GameTemplates) -> Vec<u8> {
    let mut out = Vec::new();
    out.extend_from_slice(MAGIC);
    out.extend_from_slice(&(gt.entries.len() as u32).to_le_bytes());
    for e in &gt.entries {
        let t = match e {
            Entry::Marker => {
                out.extend_from_slice(&MARKER);
                continue;
            }
            Entry::Template(t) => t,
        };
        out.extend_from_slice(&record_body_size(t).to_le_bytes());
        out.extend_from_slice(&t.unk1.to_le_bytes());
        out.extend_from_slice(&t.unk2.to_le_bytes());
        out.extend_from_slice(&((t.name.len() + 1) as u32).to_le_bytes());
        out.extend_from_slice(&t.name);
        out.push(0);
        out.extend_from_slice(&((t.ttype.len() + 1) as u32).to_le_bytes());
        out.extend_from_slice(&t.ttype);
        out.push(0);
        out.extend_from_slice(&(t.pairs.len() as u32).to_le_bytes());
        for p in &t.pairs {
            out.extend_from_slice(&p.hash.to_le_bytes());
            out.extend_from_slice(&(p.data.len() as u32).to_le_bytes());
            out.extend_from_slice(&p.data);
        }
    }
    out
}

// ---- pretty helpers ----
fn known_hashes() -> HashMap<u32, &'static str> {
    // Property/value name hashes resolved so far (pandemic_hash of the ASCII name).
    // The texture-referencing properties below were reversed in RE-2: their 4-byte data is
    // `pandemic_hash(textureName)` — the same hash that keys the ALBS bundle directory and the
    // WSTX material table, so a value resolves straight to a DTEX record. See docs/formats/gametemplates.md.
    let names = [
        "Name", "Model", "Priority", "Offset", "AIAttractionPt", "none",
        // reversed from the main DB property-hash histogram:
        "Type", "LOD", "Color", "Face", "Head", "Skin", "Description", "Image",
        // ★ texture references (value = pandemic_hash(textureName)):
        "Texture",
    ];
    let mut m = HashMap::new();
    for n in names {
        m.insert(pandemic_hash(n), n);
    }
    // Texture-valued properties not yet name-reversed but PROVEN to carry texture hashes
    // (value ∈ ALBS dir-hash set). Labelled so `dump` flags them as texture refs.
    m.insert(0x7172b7ae, "DecalTexture?"); // type=Decal, 39/39 values are WSTX texture hashes
    m.insert(0x62404569, "ObjTexture0?"); // 705/889 values in Dynamic0 dir-hashes (object diffuse?)
    m.insert(0xd9725c55, "ObjTexture1?"); // 689/889 values in Dynamic0 dir-hashes (object normal?)
    m
}

fn s(v: &[u8]) -> String {
    String::from_utf8_lossy(v).to_string()
}

fn decode_data(data: &[u8], dict: &HashMap<u32, &'static str>) -> String {
    match data.len() {
        1 => format!("u8={}", data[0]),
        4 => {
            let u = u32::from_le_bytes(data.try_into().unwrap());
            let f = f32::from_le_bytes(data.try_into().unwrap());
            let mut hint = String::new();
            if let Some(name) = dict.get(&u) {
                hint = format!(" hash:\"{}\"", name);
            } else if f.abs() > 1e-6 && f.abs() < 1e9 {
                hint = format!(" f32={}", f);
            }
            format!("u32=0x{:08x} ({}){}", u, u, hint)
        }
        _ => format!("[{} bytes]", data.len()),
    }
}

fn usage() -> ! {
    eprintln!(
        "sab_gametemplates — read/modify/write The Saboteur GameTemplates.wsd (AULB)\n\
\n\
USAGE:\n\
  sab_gametemplates list <file>\n\
      List templates (entry index, name, type, pair count) + marker count.\n\
  sab_gametemplates dump <file> [--template N]\n\
      Dump pairs (hash + decoded data). N is the ENTRY index shown by `list`.\n\
  sab_gametemplates roundtrip <in> <out>\n\
      Parse and re-emit; verifies exact-consume + byte-identical output.\n\
  sab_gametemplates set-pair <in> <out> --template N (--key NAME | --hash 0xHHHHHHHH) --data HEX\n\
      Replace the data bytes of a pair (matched by property-name hash) and re-emit.\n\
      N is the ENTRY index from `list`; data is little-endian as stored.\n\
      --data is a hex string, e.g. 0ad7233c (little-endian float 0.01) or 01.\n\
  sab_gametemplates hash <string>\n\
      Print pandemic_hash of a string (little-endian u32 as stored)."
    );
    exit(2);
}

fn hex_to_bytes(h: &str) -> Result<Vec<u8>, String> {
    let h = h.trim_start_matches("0x");
    if h.len() % 2 != 0 {
        return Err("hex must have even length".into());
    }
    (0..h.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&h[i..i + 2], 16).map_err(|e| e.to_string()))
        .collect()
}

fn get_flag(args: &[String], name: &str) -> Option<String> {
    args.iter()
        .position(|a| a == name)
        .and_then(|i| args.get(i + 1).cloned())
}

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        usage();
    }
    let cmd = args[0].as_str();
    let dict = known_hashes();
    let rest = &args[1..];

    let run = || -> Result<(), String> {
        match cmd {
            "hash" => {
                let s = rest.get(0).ok_or("need <string>")?;
                println!("pandemic_hash({:?}) = 0x{:08x}", s, pandemic_hash(s));
            }
            "list" => {
                let path = rest.get(0).ok_or("need <file>")?;
                let b = fs::read(path).map_err(|e| e.to_string())?;
                let (gt, consumed) = parse(&b)?;
                let ntmpl = gt.templates().count();
                let nmark = gt.entries.len() - ntmpl;
                println!(
                    "AULB  {} entries ({} templates + {} markers)  ({} bytes, consumed {})",
                    gt.entries.len(), ntmpl, nmark, b.len(), consumed
                );
                for (i, t) in gt.templates() {
                    println!(
                        "  [entry {:>5}] {:<26} type={:<20} pairs={}",
                        i, s(&t.name), s(&t.ttype), t.pairs.len()
                    );
                }
            }
            "dump" => {
                let path = rest.get(0).ok_or("need <file>")?;
                let only = get_flag(rest, "--template").map(|v| v.parse::<usize>().unwrap());
                let b = fs::read(path).map_err(|e| e.to_string())?;
                let (gt, _) = parse(&b)?;
                for (i, t) in gt.templates() {
                    if let Some(o) = only {
                        if o != i {
                            continue;
                        }
                    }
                    println!("[entry {}] {} : {}  ({} pairs, unk1={} unk2={})", i, s(&t.name), s(&t.ttype), t.pairs.len(), t.unk1, t.unk2);
                    for p in &t.pairs {
                        let key = dict.get(&p.hash).map(|n| format!("\"{}\"", n)).unwrap_or_else(|| "?".into());
                        println!("    hash=0x{:08x} {:<8} -> {}", p.hash, key, decode_data(&p.data, &dict));
                    }
                }
            }
            "roundtrip" => {
                let inp = rest.get(0).ok_or("need <in>")?;
                let outp = rest.get(1).ok_or("need <out>")?;
                let b = fs::read(inp).map_err(|e| e.to_string())?;
                let (gt, consumed) = parse(&b)?;
                let out = write(&gt);
                fs::write(outp, &out).map_err(|e| e.to_string())?;
                let exact = consumed == b.len();
                let identical = out == b;
                println!("parsed {} entries ({} templates)", gt.entries.len(), gt.templates().count());
                println!("exact-consume : {} ({} / {} bytes)", exact, consumed, b.len());
                println!("byte-identical: {} ({} bytes out)", identical, out.len());
                if !exact || !identical {
                    return Err("ROUND-TRIP FAILED".into());
                }
                println!("OK: byte-faithful round-trip");
            }
            "set-pair" => {
                let inp = rest.get(0).ok_or("need <in>")?;
                let outp = rest.get(1).ok_or("need <out>")?;
                let ti: usize = get_flag(rest, "--template").ok_or("need --template N")?.parse().map_err(|_| "bad --template")?;
                let hash = if let Some(k) = get_flag(rest, "--key") {
                    pandemic_hash(&k)
                } else if let Some(h) = get_flag(rest, "--hash") {
                    u32::from_str_radix(h.trim_start_matches("0x"), 16).map_err(|_| "bad --hash")?
                } else {
                    return Err("need --key NAME or --hash 0x...".into());
                };
                let data = hex_to_bytes(&get_flag(rest, "--data").ok_or("need --data HEX")?)?;
                let b = fs::read(inp).map_err(|e| e.to_string())?;
                let (mut gt, _) = parse(&b)?;
                let t = match gt.entries.get_mut(ti) {
                    Some(Entry::Template(t)) => t,
                    Some(Entry::Marker) => return Err(format!("entry {} is a marker, not a template", ti)),
                    None => return Err("entry index out of range".into()),
                };
                let mut found = false;
                for p in &mut t.pairs {
                    if p.hash == hash {
                        p.data = data.clone();
                        found = true;
                    }
                }
                if !found {
                    return Err(format!("no pair with hash 0x{:08x} in template {}", hash, ti));
                }
                let out = write(&gt);
                fs::write(outp, &out).map_err(|e| e.to_string())?;
                // re-parse to prove validity
                let (gt2, c2) = parse(&out)?;
                println!("set pair 0x{:08x} in entry {} -> {} bytes", hash, ti, data.len());
                println!("re-parsed OK: {} entries, exact-consume {}", gt2.entries.len(), c2 == out.len());
            }
            _ => usage(),
        }
        Ok(())
    };

    if let Err(e) = run() {
        eprintln!("error: {}", e);
        exit(1);
    }
}
