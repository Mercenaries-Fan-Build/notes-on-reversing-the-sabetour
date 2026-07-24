//! `repack` + `repack-audit` — byte-right texture replacement, proven end to end.
//!
//! Injects a synthetic checkerboard into an existing texture slot and emits a patch megapack, reusing
//! the base entry's crc/index so global.map is never touched. Self-verifies by re-reading its own output
//! through the megapack reader and decoding the injected texture back.

use crate::albs;
use crate::dtex;
use crate::pack;
use crate::Flags;

pub fn repack(f: &Flags) -> Result<(), String> {
    let mp_path = format!("{}/Global/Dynamic0.megapack", f.game);

    println!("[1] parsing global.map (from loosefiles) — the bundle<->megapack link");
    let dyns = albs::load_dyns(&f.game)?;
    println!("    global.map: {} dynpack descriptors", dyns.len());

    println!("[2] opening {mp_path}");
    let mp = pack::Megapack::open(&mp_path)?;
    let by_index: std::collections::HashMap<u32, pack::Entry> =
        mp.entries().iter().map(|e| (e.index, *e)).collect();

    println!("[3] picking a target texture slot + NULL ROUND-TRIP proof");
    let mut chosen: Option<(albs::Dyn, pack::Entry, albs::Bundle, usize, dtex::Dtex)> = None;
    for d in dyns.iter().filter(|d| d.n_tex > 0) {
        let Some(entry) = by_index.get(&d.asset_index).copied() else { continue };
        let sub = mp.slice(&entry);
        if sub.is_empty() {
            continue;
        }
        let Ok(b) = albs::parse_bundle(sub, d) else { continue };
        if albs::rebuild_bundle(sub, &b, None) != sub {
            continue;
        }
        for (off, len, name) in dtex::find_records(sub) {
            if let Some(filt) = &f.tex {
                if !name.to_ascii_lowercase().contains(&filt.to_ascii_lowercase()) {
                    continue;
                }
            }
            let Ok(parsed) = dtex::parse(&sub[off..off + len]) else { continue };
            if parsed.format == albs::DXT1 && parsed.width >= 32 && parsed.height >= 32 {
                if let Some(ti) = albs::tex_index_for_record(&b, off) {
                    println!(
                        "    bundle '{}' (assetIndex {}) — replacing DXT1 texture '{}' {}x{} mips={}",
                        d.name, d.asset_index, name, parsed.width, parsed.height, parsed.mips
                    );
                    println!("    NULL ROUND-TRIP: rebuilt unchanged bundle == original ({} bytes)  OK", sub.len());
                    chosen = Some((d.clone(), entry, b, ti, parsed));
                    break;
                }
            }
        }
        if chosen.is_some() {
            break;
        }
    }
    let (d, entry, bundle, tex_idx, orig) = chosen.ok_or("no suitable DXT1 texture slot found")?;

    println!("[4] encoding synthetic checkerboard DTEX ({}x{} DXT1, {} mips)", orig.width, orig.height, orig.mips);
    let (record, uncompressed) = albs::build_checker_dtex(&orig.name, orig.flags, orig.width, orig.height, orig.mips);
    println!("    new DTEX record: {} bytes, uncompressedSize={}", record.len(), uncompressed);

    println!("[5] rebuilding ALBS bundle with the slot replaced");
    let sub = mp.slice(&entry);
    let new_bundle = albs::rebuild_bundle(sub, &bundle, Some((tex_idx, &record, uncompressed)));
    println!("    bundle {} -> {} bytes", sub.len(), new_bundle.len());

    println!("[6] writing patch megapack (with the second (crc,index) table) -> {}", f.out);
    albs::write_patch_megapack(&f.out, &[(entry.crc, entry.index, new_bundle)])?;

    println!("[7] VERIFY: re-reading {} with the megapack reader", f.out);
    let vmp = pack::Megapack::open(&f.out)?;
    let ve = *vmp.entries().first().ok_or("patch has no entries")?;
    if ve.crc != entry.crc || ve.index != entry.index {
        return Err("patch entry crc/index mismatch".into());
    }
    let vsub = vmp.slice(&ve);
    let (voff, vlen) = match dtex::find_records(vsub).iter().find(|(_, _, n)| n.eq_ignore_ascii_case(&orig.name)) {
        Some((o, l, _)) => (*o, *l),
        None => return Err("injected texture not found on re-read".into()),
    };
    let decoded = dtex::decode(&vsub[voff..voff + vlen])?;
    let magenta = decoded
        .rgba
        .chunks_exact(4)
        .filter(|p| p[0] > 200 && p[1] < 80 && p[2] > 200)
        .count();
    let fmt = if decoded.format == albs::DXT1 { "DXT1".to_string() } else { format!("0x{:08X}", decoded.format) };
    println!(
        "    re-read OK: '{}' {}x{} {}, {} magenta texels (checker present: {})",
        orig.name, decoded.width, decoded.height, fmt, magenta, magenta > 0
    );
    if decoded.width != orig.width as u32 || decoded.height != orig.height as u32 {
        return Err("re-read dimensions differ from slot".into());
    }
    if magenta == 0 {
        return Err("re-read texture has no magenta — encode/repack broke".into());
    }

    println!("\nPASS — texture repack proof-of-concept complete.");
    println!("  Install:  copy \"{}\" into \"{}/Global/\"  then launch the game.", f.out, f.game);
    println!("  Uninstall: delete that file. (Additive patch layer; base megapack untouched.)");
    println!("  global.map was NOT modified — replacement overrides by assetIndex {}.", d.asset_index);
    Ok(())
}

/// Coverage: how many texture-bearing bundles rebuild byte-exact (the writer's correctness gate)?
pub fn audit(game: &str) -> Result<(), String> {
    println!("AUDIT: byte-exact ALBS null round-trip across all texture bundles");
    let dyns = albs::load_dyns(game)?;
    let (mut total, mut passed, mut parse_fail) = (0usize, 0usize, 0usize);
    for (name, mppath) in [("Dynamic0", "Global/Dynamic0.megapack"), ("Palettes0", "Global/Palettes0.megapack")] {
        let mp = pack::Megapack::open(&format!("{game}/{mppath}"))?;
        let by_index: std::collections::HashMap<u32, pack::Entry> =
            mp.entries().iter().map(|e| (e.index, *e)).collect();
        let (mut t, mut p, mut fparse) = (0, 0, 0);
        for d in dyns.iter().filter(|d| d.n_tex > 0) {
            let Some(entry) = by_index.get(&d.asset_index).copied() else { continue };
            let sub = mp.slice(&entry);
            if sub.is_empty() {
                continue;
            }
            t += 1;
            match albs::parse_bundle(sub, d) {
                Ok(b) => {
                    if albs::rebuild_bundle(sub, &b, None) == sub {
                        p += 1;
                    } else {
                        println!("    MISS '{}' (idx {}): len {}", d.name, d.asset_index, sub.len());
                    }
                }
                Err(_) => fparse += 1,
            }
        }
        println!("  {name}: {p}/{t} bundles byte-exact ({fparse} parse failures)");
        total += t;
        passed += p;
        parse_fail += fparse;
    }
    println!("TOTAL: {passed}/{total} byte-exact ({parse_fail} parse failures)");
    Ok(())
}
