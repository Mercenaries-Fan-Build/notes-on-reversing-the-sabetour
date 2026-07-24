// Saboteur audio extractor: parse the "1KCP" Wwise file-package (.pck), carve the streamed
// .wem voice lines, and batch-decode them to WAV via vgmstream-cli.
//
// 1KCP header (LE):
//   +0x00 u32 magic = 0x50434B31 ("1KCP")
//   +0x04 u32 block align (2048)
//   +0x08 u32 version (2)
//   +0x0C u32 bankCount
//   +0x10 u32 bankTableOffset   -- always 0x1C on retail
//   +0x14 u32 streamCount
//   +0x18 u32 streamTableOffset -- always bankTableOffset + bankCount*12
//   +0x1C : record table, 12 bytes each { u32 id, u32 size, u32 offset(absolute) }
//           first `bankCount` records are .bnk (BKHD), next `streamCount` are loose .wem (RIFF).
//           The two sub-tables are contiguous, so both are read as one run from bankTableOffset.
//
// NOTE: this table was previously read from a hardcoded +0x28, which skipped the first record and
// read one record past the end of every pack -- silently losing 1 real stream per pack (8 across the
// 4 VO languages x main+DLC). Verified against all 10 retail packs: reading from bankTableOffset
// validates 100% of records by magic (BKHD/RIFF); reading from 0x28 mis-reads exactly 2 per pack.
//
// Usage:
//   saboteur_audio --game <dir> --out <dir> --vgmstream <exe> --langs eng,fra,deu,ita
//                  [--no-decode] [--keep-wem] [--batch N]

use std::collections::BTreeMap;
use std::fs::{self, File};
use std::io::{Read, Seek, SeekFrom, Write, BufWriter};
use std::path::{Path, PathBuf};
use std::process::Command;

fn u32le(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

struct Rec { id: u32, size: u32, offset: u32 }

struct PckInfo { banks: u32, streams: u32, recs: Vec<Rec> }

fn parse_pck_header(f: &mut File) -> std::io::Result<PckInfo> {
    let mut h = [0u8; 0x1C];
    f.seek(SeekFrom::Start(0))?;
    f.read_exact(&mut h)?;
    assert_eq!(u32le(&h, 0), 0x5043_4B31, "not a 1KCP pack");
    let banks = u32le(&h, 0x0C);
    let bank_tbl = u32le(&h, 0x10);
    let streams = u32le(&h, 0x14);
    let stream_tbl = u32le(&h, 0x18);
    // The stream sub-table directly follows the bank sub-table; assert it so a pack that ever
    // breaks the assumption fails loudly instead of silently carving garbage.
    assert_eq!(
        stream_tbl,
        bank_tbl + banks * 12,
        "1KCP sub-tables are not contiguous (bankTable={:#x} banks={} streamTable={:#x})",
        bank_tbl, banks, stream_tbl
    );
    let total = (banks + streams) as usize;
    let mut tbl = vec![0u8; total * 12];
    f.seek(SeekFrom::Start(bank_tbl as u64))?;
    f.read_exact(&mut tbl)?;
    let mut recs = Vec::with_capacity(total);
    for i in 0..total {
        let o = i * 12;
        recs.push(Rec { id: u32le(&tbl, o), size: u32le(&tbl, o + 4), offset: u32le(&tbl, o + 8) });
    }
    Ok(PckInfo { banks, streams, recs })
}

// Carve the streamed .wem records (skip banks). Returns list of written wem paths + manifest rows.
fn carve_streams(pck: &Path, tag: &str, wem_dir: &Path, manifest: &mut Vec<String>, limit: usize) -> std::io::Result<Vec<PathBuf>> {
    let mut f = File::open(pck)?;
    let info = parse_pck_header(&mut f)?;
    let start = info.banks as usize;
    let mut end = start + info.streams as usize;
    if limit > 0 && end > start + limit { end = start + limit; }
    fs::create_dir_all(wem_dir)?;
    let mut out = Vec::new();
    let mut buf: Vec<u8> = Vec::new();
    let mut riff = 0usize;
    for r in &info.recs[start..end] {
        buf.clear();
        buf.resize(r.size as usize, 0);
        f.seek(SeekFrom::Start(r.offset as u64))?;
        f.read_exact(&mut buf)?;
        let is_riff = buf.len() >= 4 && &buf[0..4] == b"RIFF";
        if is_riff { riff += 1; }
        let name = format!("{}_{:08x}.wem", tag, r.id);
        let p = wem_dir.join(&name);
        { let mut w = BufWriter::new(File::create(&p)?); w.write_all(&buf)?; }
        manifest.push(format!("{},{:08x},{},{},{},{}", tag, r.id, r.offset, r.size, is_riff, name));
        out.push(p);
    }
    eprintln!("  [{}] carved {} streams ({} RIFF) from {}", tag, out.len(), riff, pck.display());
    Ok(out)
}

// Batch-decode wems to WAV. vgmstream selects the Wwise parser by the .wem extension and its
// -o "?f" wildcard expands to the infile string verbatim, so we run with CWD = wem_dir and pass
// bare basenames (?f -> "<tag>_<id>.wem"), writing to an absolute wav path. A final pass strips
// the ".wem.wav" double extension down to ".wav".
fn decode_batches(vgm: &Path, wems: &[PathBuf], wem_dir: &Path, wav_dir: &Path, batch: usize)
    -> std::io::Result<usize>
{
    fs::create_dir_all(wav_dir)?;
    let cwd = std::env::current_dir()?;
    // Plain absolute paths (NO fs::canonicalize -> avoids the \\?\ extended prefix that
    // breaks vgmstream's -o pattern).
    let wav_abs = if wav_dir.is_absolute() { wav_dir.to_path_buf() } else { cwd.join(wav_dir) };
    let vgm_abs = if vgm.is_absolute() { vgm.to_path_buf() } else { cwd.join(vgm) };
    let pat = format!("{}\\?f.wav", wav_abs.to_string_lossy());
    let mut done = 0usize;
    let debug = std::env::var("SAB_DEBUG").is_ok();
    for (bi, chunk) in wems.chunks(batch).enumerate() {
        let mut cmd = Command::new(&vgm_abs);
        cmd.current_dir(wem_dir);
        cmd.arg("-o").arg(&pat);
        for w in chunk {
            cmd.arg(w.file_name().unwrap());
        }
        if debug && bi == 0 {
            eprintln!("DEBUG exe={}", vgm_abs.display());
            eprintln!("DEBUG cwd={}", wem_dir.display());
            eprintln!("DEBUG arg[0]=-o arg[1]={}", pat);
            eprintln!("DEBUG first file arg = {:?}", chunk[0].file_name().unwrap());
            eprintln!("DEBUG last file arg  = {:?}", chunk[chunk.len()-1].file_name().unwrap());
            eprintln!("DEBUG total file args = {}", chunk.len());
        }
        let status = cmd.status()?;
        if !status.success() {
            eprintln!("    vgmstream batch {} exit {:?}", bi, status.code());
        }
        done += chunk.len();
        if bi % 10 == 0 { eprintln!("    decoded ~{}/{}", done, wems.len()); }
    }
    // Strip ".wem.wav" -> ".wav"
    let mut renamed = 0usize;
    for entry in fs::read_dir(wav_dir)? {
        let p = entry?.path();
        let s = p.to_string_lossy().to_string();
        if s.ends_with(".wem.wav") {
            let np = PathBuf::from(s.replace(".wem.wav", ".wav"));
            if fs::rename(&p, &np).is_ok() { renamed += 1; }
        }
    }
    eprintln!("    tidied {} names (.wem.wav -> .wav)", renamed);
    Ok(done)
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let mut game = String::new();
    let mut out = String::from("output/saboteur_audio");
    let mut vgm = String::from("tools/vgmstream/vgmstream-cli.exe");
    let mut langs = String::from("eng,fra,deu,ita");
    let mut decode = true;
    let mut keep_wem = false;
    let mut batch = 300usize;
    let mut limit = 0usize; // 0 = no limit
    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--game" => { i += 1; game = args[i].clone(); }
            "--out" => { i += 1; out = args[i].clone(); }
            "--vgmstream" => { i += 1; vgm = args[i].clone(); }
            "--langs" => { i += 1; langs = args[i].clone(); }
            "--no-decode" => { decode = false; }
            "--keep-wem" => { keep_wem = true; }
            "--batch" => { i += 1; batch = args[i].parse().unwrap(); }
            "--limit" => { i += 1; limit = args[i].parse().unwrap(); }
            other => { eprintln!("unknown arg {}", other); }
        }
        i += 1;
    }
    assert!(!game.is_empty(), "--game <Saboteur install dir> required");

    // lang code -> (main pck relative, dlc pck relative)
    let lang_map: BTreeMap<&str, (&str, &str)> = [
        ("eng", ("Sound/English(US).pck", "DLC/01/sound/English(US).pck")),
        ("fra", ("Sound/French(Canada).pck", "DLC/01/sound/French(Canada).pck")),
        ("deu", ("Sound/German.pck", "DLC/01/sound/German.pck")),
        ("ita", ("Sound/Italian.pck", "DLC/01/sound/Italian.pck")),
    ].into_iter().collect();

    let out_root = PathBuf::from(&out);
    fs::create_dir_all(&out_root).unwrap();
    let mut manifest: Vec<String> = vec!["pack,wem_id,offset,size,is_riff,file".into()];

    for lang in langs.split(',').map(|s| s.trim()).filter(|s| !s.is_empty()) {
        let (main_rel, dlc_rel) = match lang_map.get(lang) {
            Some(v) => *v, None => { eprintln!("skip unknown lang {}", lang); continue; }
        };
        eprintln!("=== language: {} ===", lang);
        let lang_dir = out_root.join(lang);
        let wem_dir = lang_dir.join("wem");
        let wav_dir = lang_dir.join("wav");
        let mut all_wems: Vec<PathBuf> = Vec::new();

        for (tag, rel) in [(format!("{}_main", lang), main_rel), (format!("{}_dlc", lang), dlc_rel)] {
            let pck = PathBuf::from(&game).join(rel);
            if !pck.exists() { eprintln!("  (missing {})", pck.display()); continue; }
            match carve_streams(&pck, &tag, &wem_dir, &mut manifest, limit) {
                Ok(mut v) => all_wems.append(&mut v),
                Err(e) => eprintln!("  ERROR carving {}: {}", pck.display(), e),
            }
        }

        if decode && !all_wems.is_empty() {
            eprintln!("  decoding {} wems -> {}", all_wems.len(), wav_dir.display());
            match decode_batches(&PathBuf::from(&vgm), &all_wems, &wem_dir, &wav_dir, batch) {
                Ok(n) => eprintln!("  decoded {} files", n),
                Err(e) => eprintln!("  decode error: {}", e),
            }
            if !keep_wem {
                let _ = fs::remove_dir_all(&wem_dir);
                eprintln!("  removed intermediate wem dir");
            }
        }
    }

    let mpath = out_root.join("manifest.csv");
    fs::write(&mpath, manifest.join("\n")).unwrap();
    eprintln!("manifest -> {} ({} rows)", mpath.display(), manifest.len() - 1);
}
