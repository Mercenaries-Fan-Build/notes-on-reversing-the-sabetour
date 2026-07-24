//! `deploy` — install the Mattias port into the game, reversibly.
//!
//! Overrides the player bundle `FBS_RS_Sean` (assetIndex 2016137252: 8 meshes + 29 textures) with
//! Mattias's MSHA (all mesh slots) and his 29 DTEX (keyed by their WSAO texture hashes), emitted as an
//! ADDITIVE `Global/patchdynamic0.megapack` — no base file is modified. Also installs the patched
//! `France.materials` (WSAO) that binds Mattias's material hashes to those textures, backing up the
//! original. Uninstall = delete the patch megapack + restore `France.materials.bak`.
//!
//! Counts match 1:1 (Mattias produced exactly 29 DTEX), so no global.map edit is needed.

use crate::albs;
use crate::pack;
use crate::Flags;

const SEAN_PLAYER_INDEX: u32 = 2016137252; // FBS_RS_Sean

fn u32at(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

fn inflate(d: &[u8]) -> Result<Vec<u8>, String> {
    use std::io::Read as _;
    let mut out = Vec::new();
    flate2::read::ZlibDecoder::new(d).read_to_end(&mut out).map_err(|e| format!("inflate: {e}"))?;
    Ok(out)
}
fn deflate(d: &[u8]) -> Vec<u8> {
    use std::io::Write as _;
    let mut e = flate2::write::ZlibEncoder::new(Vec::new(), flate2::Compression::new(9));
    e.write_all(d).unwrap();
    e.finish().unwrap()
}

/// Re-identify a placed MSHA so its self-identity matches the slot it occupies. Verified invariant
/// across all 8 Sean parts: DynFile df[0] == MESH body@148 (name-hash) == pandemic_hash(MSHA name@20).
/// The synth templated its header from the HD donor, so body@148 carried HD's hash — a mismatch in
/// every non-HD slot. We patch the MSHA name (@20) and body@148 to the slot's identity, recompressing
/// only the (small) body; the .dat stays compressed as-is. `unc1` (usz) is unchanged.
fn reidentify_msha(msha: &[u8], name: &str, hash: u32) -> Result<Vec<u8>, String> {
    let (unc0, unc1) = (u32at(msha, 4), u32at(msha, 8));
    let (c0, c1) = (u32at(msha, 12) as usize, u32at(msha, 16) as usize);
    let mut body = inflate(&msha[276..276 + c0])?;
    if body.len() != unc0 as usize {
        return Err(format!("reidentify: body {} != unc0 {}", body.len(), unc0));
    }
    body[148..152].copy_from_slice(&hash.to_le_bytes());
    let dat_z = &msha[276 + c0..276 + c0 + c1]; // keep .dat compressed
    let b0 = deflate(&body);
    let mut out = Vec::with_capacity(276 + b0.len() + c1);
    out.extend_from_slice(b"AHSM");
    out.extend_from_slice(&unc0.to_le_bytes());
    out.extend_from_slice(&unc1.to_le_bytes());
    out.extend_from_slice(&(b0.len() as u32).to_le_bytes());
    out.extend_from_slice(&(c1 as u32).to_le_bytes());
    let mut nm = [0u8; 256];
    let nb = name.as_bytes();
    nm[..nb.len().min(255)].copy_from_slice(&nb[..nb.len().min(255)]);
    out.extend_from_slice(&nm);
    out.extend_from_slice(&b0);
    out.extend_from_slice(dat_z);
    Ok(out)
}
fn dtex_uncompressed(rec: &[u8]) -> u32 {
    let nlen = u32at(rec, 0) as usize;
    u32at(rec, 4 + nlen + 4 + 4 + 2 + 2 + 2) // after nameLen,name,fmt,unk,w,h,mips
}

pub fn deploy(f: &Flags) -> Result<(), String> {
    if f.retex_sean {
        return deploy_retex_sean(f);
    }
    if f.mattias_opaque {
        return deploy_mattias_opaque(f);
    }
    let portdir = std::path::PathBuf::from(if f.out == "patchdynamic0.megapack" { "mattias_port".into() } else { f.out.clone() });
    let game = &f.game;

    println!("[1] loading Mattias port outputs from {}", portdir.display());
    let msha = std::fs::read(portdir.join("pmc_hum_mattias.msha")).map_err(|e| format!("read msha: {e}"))?;
    let empty = std::fs::read(portdir.join("pmc_empty.msha")).ok(); // degenerate filler for non-primary slots
    let patched_wsao = std::fs::read(portdir.join("France.materials")).map_err(|e| format!("read patched WSAO: {e} (run `sab_poc mattias` first)"))?;

    // is-normal flag per texture hash, from the glTF material roles (the port used the _n role for normals)
    let (_gdir, roles) = crate::gltf::material_roles(&f.gltf)?;
    let mut is_normal_of = std::collections::HashMap::new();
    for (i, r) in roles.iter().enumerate() {
        for (role_i, suffix, is_n) in [(0usize, "d", false), (2usize, "s", false), (1usize, "n", true)] {
            if r[role_i].is_some() {
                is_normal_of.insert(pack::pandemic_hash(&format!("mattias_m{i}_{suffix}")), is_n);
            }
        }
    }
    // read whatever DTEX the port actually wrote (each file is <HASH>.dtex)
    let mut texset: Vec<(u32, bool, Vec<u8>)> = Vec::new();
    for e in std::fs::read_dir(portdir.join("dtex")).map_err(|e| format!("read dtex dir: {e}"))? {
        let p = e.map_err(|e| e.to_string())?.path();
        let stem = p.file_stem().and_then(|s| s.to_str()).unwrap_or("");
        let Ok(hash) = u32::from_str_radix(stem, 16) else { continue };
        let raw = std::fs::read(&p).map_err(|e| e.to_string())?;
        let rec = if raw.len() > 4 && &raw[0..4] == b"DTEX" { raw[4..].to_vec() } else { raw };
        let is_n = is_normal_of.get(&hash).copied().unwrap_or(false);
        texset.push((hash, is_n, rec));
    }
    println!("    Mattias MSHA {} B, {} DTEX", msha.len(), texset.len());

    // Default = ROBUST multi-outfit fix: fill ONE shared, always-present mesh slot with the full merged
    // Mattias and degenerate every OTHER body mesh across ALL FBS_RS_Sean* variants, so no outfit renders
    // Sean's body OVERLAPPING Mattias. We fill the **LB** slot: proven live (sab_asi hook of body-setup
    // +0x60), the combined-LOD / cutscene render path reads the LB body-part blueprint for every human, so
    // the old HD-only default left LB empty → the far/cutscene render culled the whole body (invisible,
    // hat aside). The near-LOD assembles all parts, so a single non-empty slot still yields exactly one
    // body — LB satisfies BOTH paths. Fall back to HD for any outfit lacking an LB slot. --all / --slot
    // stay single-base debug/isolation modes.
    const SEAN_LB_HASH: u32 = 0xE1595A4B;   // CH_AL_SeanDevlin_01_LB — the slot the combined-LOD renders
    const SEAN_HEAD_HASH: u32 = 0x962C6D71; // CH_AL_SeanDevlin_01_HD — always-shared fallback
    let mp = pack::Megapack::open(&format!("{game}/Global/Dynamic0.megapack"))?;

    let mut patch_bundles: Vec<(u32, u32, Vec<u8>)> = Vec::new();
    if f.all || f.slot.is_some() {
        let fill = if f.all { Fill::AllFull } else { Fill::OverSean(f.slot.unwrap()) };
        let place_tex = !matches!(fill, Fill::OverSean(_));
        println!("[2] authoring FBS_RS_Sean (debug/isolation mode)");
        let entry = *mp.entries().iter().find(|e| e.index == SEAN_PLAYER_INDEX).ok_or("FBS_RS_Sean not in Dynamic0")?;
        let sub = mp.slice(&entry);
        let d = albs::Dyn { asset_index: SEAN_PLAYER_INDEX, name: "FBS_RS_Sean".into(), n_mesh: 8, n_phys: 8, n_flash: 0, n_tex: 29 };
        let b = albs::parse_bundle(sub, &d)?;
        let nb = author_bundle(sub, &b, &msha, empty.as_deref(), &texset, fill, place_tex)?;
        patch_bundles.push((entry.crc, entry.index, nb));
    } else {
        if empty.is_none() {
            return Err("pmc_empty.msha missing — re-run `sab_poc mattias` to generate the empty-slot filler".into());
        }
        let dyns = albs::load_dyns(game)?;
        let sean: Vec<&albs::Dyn> = dyns.iter().filter(|d| d.name.starts_with("FBS_RS_Sean")).collect();
        println!("[2] authoring {} FBS_RS_Sean* outfit bundle(s): Mattias in shared HD slot, all other body meshes degenerate", sean.len());
        for d in &sean {
            let Some(entry) = mp.entries().iter().find(|e| e.index == d.asset_index).copied() else {
                eprintln!("    skip {} (not in Dynamic0)", d.name);
                continue;
            };
            let sub = mp.slice(&entry);
            let b = match albs::parse_bundle(sub, d) {
                Ok(b) => b,
                Err(e) => { eprintln!("    skip {} (parse: {e})", d.name); continue }
            };
            // textures placed once (base bundle); they resolve globally by hash, so variants keep theirs
            let place_tex = d.asset_index == SEAN_PLAYER_INDEX;
            if place_tex && b.tables[albs::CAT_TEX].len() != texset.len() {
                return Err(format!("texture count mismatch on base: bundle {} vs Mattias {}", b.tables[albs::CAT_TEX].len(), texset.len()));
            }
            // Combined-LOD reads the LB slot; fill it when this outfit carries one, else the shared HD.
            let target = if b.tables[0].iter().any(|df| df[0] == SEAN_LB_HASH) { SEAN_LB_HASH } else { SEAN_HEAD_HASH };
            let nb = author_bundle(sub, &b, &msha, empty.as_deref(), &texset, Fill::CleanByHash(target), place_tex)?;
            patch_bundles.push((entry.crc, entry.index, nb));
            let slot_name = if target == SEAN_LB_HASH { "LB" } else { "HD(fallback)" };
            println!("    {} ({} mesh slots) -> Mattias in {slot_name}", d.name, b.tables[0].len());
        }
        if patch_bundles.is_empty() {
            return Err("no FBS_RS_Sean* bundles found to override".into());
        }
    }

    println!("[3] writing patch megapack ({} bundle(s)) + verifying it re-reads", patch_bundles.len());
    let patch_path = portdir.join("patchdynamic0.megapack");
    albs::write_patch_megapack(patch_path.to_str().unwrap(), &patch_bundles)?;
    let vmp = pack::Megapack::open(patch_path.to_str().unwrap())?;
    let ve = *vmp.entries().first().ok_or("patch empty")?;
    let vsub = vmp.slice(&ve);
    if !vsub.windows(4).any(|w| w == b"AHSM") {
        return Err("patch bundle has no MSHA — mesh write failed".into());
    }
    println!("    OK — patch re-reads, mesh present");

    println!("[4] installing (reversible)");
    // additive patch megapack
    let dst_patch = format!("{game}/Global/patchdynamic0.megapack");
    std::fs::copy(&patch_path, &dst_patch).map_err(|e| format!("install patch: {e}"))?;
    println!("    + {dst_patch}");
    // France.materials with backup
    let fm = format!("{game}/France.materials");
    let bak = format!("{game}/France.materials.bak");
    if !std::path::Path::new(&bak).exists() {
        std::fs::copy(&fm, &bak).map_err(|e| format!("backup France.materials: {e}"))?;
        println!("    backed up France.materials -> France.materials.bak");
    }
    std::fs::write(&fm, &patched_wsao).map_err(|e| format!("install France.materials: {e}"))?;
    println!("    installed patched France.materials ({} B)", patched_wsao.len());

    println!("\nDEPLOYED. Launch the game — the player character bundle is now Mattias.");
    println!("Uninstall:  del \"{dst_patch}\"   &&   copy /Y \"{bak}\" \"{fm}\"");
    println!("NOTE: first launch is the real test — I can't run the game. If it crashes or looks wrong,");
    println!("      revert with the line above and tell me what you saw; several layers are new here.");
    Ok(())
}

/// How to fill the 8 mesh slots of the player bundle.
#[derive(Clone, Copy)]
enum Fill {
    AllFull,          // every slot = full Mattias (debug; overlapping copies Z-fight)
    CleanSingle(usize), // one slot = full Mattias, the rest = degenerate empty (single clean character)
    CleanByHash(u32), // the slot whose DynFile hash == this = full Mattias, the rest = degenerate.
                      // Used to place Mattias in the SHARED head mesh (0x962C6D71 = CH_AL_SeanDevlin_01_HD,
                      // present in every Sean outfit) and blank all outfit-specific body meshes, so no
                      // outfit variant can render Sean's body overlapping Mattias.
    OverSean(usize),  // one slot = full Mattias, the rest = Sean's original parts (isolation test)
}

/// Author a new ALBS bundle. Mesh slots are filled per `fill`; when a mesh is placed it's re-identified
/// to that slot's identity (name + body@148) so the engine's part lookup resolves it. Tex slots become
/// the Mattias DTEX when `place_tex`, else kept. phys/flash always kept. `usz` = the mesh's unc1 (.dat).
fn author_bundle(buf: &[u8], b: &albs::Bundle, full: &[u8], empty: Option<&[u8]>, texset: &[(u32, bool, Vec<u8>)], fill: Fill, place_tex: bool) -> Result<Vec<u8>, String> {
    let mut tables = b.tables.clone();
    let trailing = &buf[b.tbl_end + b.data_ext..];
    let mut data: Vec<u8> = Vec::new();
    let mut cursor = 0u32;

    // helper to place a blob and update a DynFile's off/size/usz
    let mut place = |df: &mut albs::DynFile, blob: &[u8], usz: u32, cursor: &mut u32, data: &mut Vec<u8>| {
        df[1] = *cursor;
        df[2] = blob.len() as u32;
        df[3] = usz;
        data.extend_from_slice(blob);
        *cursor += blob.len() as u32;
    };

    // CAT order = [mesh, phys, flash, tex]
    for cat in 0..4 {
        for i in 0..tables[cat].len() {
            if cat == 0 {
                // which mesh (if any) goes in this slot?
                let chosen: Option<&[u8]> = match fill {
                    Fill::AllFull => Some(full),
                    Fill::CleanSingle(p) => if i == p { Some(full) } else { empty },
                    Fill::CleanByHash(h) => if tables[cat][i][0] == h { Some(full) } else { empty },
                    Fill::OverSean(p) => if i == p { Some(full) } else { None },
                };
                if let Some(m) = chosen {
                    let df0 = tables[cat][i];
                    let orig_off = b.tbl_end + df0[1] as usize;
                    let slot_name = {
                        let raw = &buf[orig_off + 20..orig_off + 276];
                        let end = raw.iter().position(|&x| x == 0).unwrap_or(raw.len());
                        String::from_utf8_lossy(&raw[..end]).into_owned()
                    };
                    let re = reidentify_msha(m, &slot_name, df0[0])?;
                    let usz = u32at(m, 8); // unc1 = the .dat uncompressed size
                    let mut df = df0;
                    place(&mut df, &re, usz, &mut cursor, &mut data);
                    tables[cat][i] = df;
                } else {
                    // keep Sean's original mesh in this slot
                    let df0 = tables[cat][i];
                    let off = b.tbl_end + df0[1] as usize;
                    let blob = buf[off..off + df0[2] as usize].to_vec();
                    let mut df = df0;
                    place(&mut df, &blob, df0[3], &mut cursor, &mut data);
                    tables[cat][i] = df;
                }
            } else if cat == albs::CAT_TEX && place_tex {
                let (hash, is_n, rec) = &texset[i];
                let mut df = tables[cat][i];
                df[0] = *hash; // texture name-hash (what WSAO references)
                df[5] = if *is_n { 1 } else { 0 }; // color/normal flag
                let usz = dtex_uncompressed(rec);
                place(&mut df, rec, usz, &mut cursor, &mut data);
                tables[cat][i] = df;
            } else {
                // phys / flash, or tex when not placing Mattias textures -> keep original blob
                let df0 = tables[cat][i];
                let off = b.tbl_end + df0[1] as usize;
                let blob = buf[off..off + df0[2] as usize].to_vec();
                let mut df = df0;
                place(&mut df, &blob, df0[3], &mut cursor, &mut data);
                tables[cat][i] = df;
            }
        }
    }

    let mut out = Vec::with_capacity(8 + b.tbl_end + data.len() + trailing.len());
    out.extend_from_slice(b"ALBS");
    out.extend_from_slice(&0u32.to_le_bytes());
    for cat in 0..4 {
        for df in &tables[cat] {
            for &w in df {
                out.extend_from_slice(&w.to_le_bytes());
            }
        }
    }
    out.extend_from_slice(&data);
    out.extend_from_slice(trailing);
    Ok(out)
}

// ─────────────────── ISOLATION TEST A: Sean's mesh, Mattias's skins ───────────────────

/// Classify a DTEX record's role from its length-prefixed name.
fn dtex_role(rec: &[u8]) -> &'static str {
    let nlen = u32at(rec, 0) as usize;
    if 4 + nlen > rec.len() {
        return "diffuse";
    }
    let name = String::from_utf8_lossy(&rec[4..4 + nlen]).to_ascii_lowercase();
    if name.ends_with("_nm") || name.ends_with("_n") || name.contains("normal") {
        "normal"
    } else if name.ends_with("_s") || name.contains("spec") {
        "spec"
    } else if name.ends_with("_wm") || name.contains("mask") {
        "mask"
    } else {
        "diffuse"
    }
}

/// Author the Sean bundle keeping ALL original mesh/phys/flash, but swapping each texture slot's DATA
/// for a role-matched Mattias skin (round-robin within the role) — the slot's identity hash `df[0]` is
/// KEPT, so Sean's own materials resolve to it and the mesh renders with Mattias's pixels. A texture role
/// Mattias has nothing for (mask/eyes/etc.) keeps Sean's original.
fn author_retex_bundle(
    buf: &[u8],
    b: &albs::Bundle,
    mattias_by_role: &std::collections::HashMap<&'static str, Vec<Vec<u8>>>,
) -> Result<(Vec<u8>, usize), String> {
    let mut tables = b.tables.clone();
    let trailing = &buf[b.tbl_end + b.data_ext..];
    let mut data: Vec<u8> = Vec::new();
    let mut cursor = 0u32;
    let mut rr: std::collections::HashMap<&'static str, usize> = std::collections::HashMap::new();
    let mut swapped = 0usize;

    for cat in 0..4 {
        for i in 0..tables[cat].len() {
            let df0 = tables[cat][i];
            let off = b.tbl_end + df0[1] as usize;
            let orig = &buf[off..off + df0[2] as usize];
            let (blob, usz): (Vec<u8>, u32) = if cat == albs::CAT_TEX {
                let role = dtex_role(orig);
                match mattias_by_role.get(role).filter(|l| !l.is_empty()) {
                    Some(list) => {
                        let idx = rr.entry(role).or_insert(0);
                        let rec = list[*idx % list.len()].clone();
                        *idx += 1;
                        swapped += 1;
                        let usz = dtex_uncompressed(&rec);
                        (rec, usz)
                    }
                    None => (orig.to_vec(), df0[3]),
                }
            } else {
                (orig.to_vec(), df0[3]) // Sean's original mesh/phys/flash, verbatim
            };
            let mut df = df0;
            df[1] = cursor;
            df[2] = blob.len() as u32;
            df[3] = usz;
            data.extend_from_slice(&blob);
            cursor += blob.len() as u32;
            tables[cat][i] = df;
        }
    }

    let mut out = Vec::with_capacity(8 + b.tbl_end + data.len() + trailing.len());
    out.extend_from_slice(b"ALBS");
    out.extend_from_slice(&0u32.to_le_bytes());
    for cat in 0..4 {
        for df in &tables[cat] {
            for &w in df {
                out.extend_from_slice(&w.to_le_bytes());
            }
        }
    }
    out.extend_from_slice(&data);
    out.extend_from_slice(trailing);
    Ok((out, swapped))
}

/// ISOLATION TEST A. Keep Sean's original mesh; only rebind his materials to Mattias's skins. Restores
/// Sean's ORIGINAL `France.materials` (so his own material→texture bindings are used) and installs a
/// patch that re-textures only the `FBS_RS_Sean` base bundle.
fn deploy_retex_sean(f: &Flags) -> Result<(), String> {
    let game = &f.game;
    let portdir = std::path::Path::new("mattias_port");
    println!("[A] ISOLATION TEST — Sean's ORIGINAL mesh + Mattias's skins (role-matched)");

    // Mattias texture hash -> role, from the glTF material roles (same keying deploy() uses).
    let (_gdir, roles) = crate::gltf::material_roles(&f.gltf)?;
    let mut role_of_hash: std::collections::HashMap<u32, &'static str> = std::collections::HashMap::new();
    for (i, r) in roles.iter().enumerate() {
        for (role_i, suffix, rolename) in [(0usize, "d", "diffuse"), (1usize, "n", "normal"), (2usize, "s", "spec")] {
            if r[role_i].is_some() {
                role_of_hash.insert(pack::pandemic_hash(&format!("mattias_m{i}_{suffix}")), rolename);
            }
        }
    }
    // Load the Mattias DTEX the port wrote, grouped by role.
    let mut mattias_by_role: std::collections::HashMap<&'static str, Vec<Vec<u8>>> = std::collections::HashMap::new();
    for e in std::fs::read_dir(portdir.join("dtex")).map_err(|e| format!("read dtex dir: {e}"))? {
        let p = e.map_err(|e| e.to_string())?.path();
        let stem = p.file_stem().and_then(|s| s.to_str()).unwrap_or("");
        let Ok(hash) = u32::from_str_radix(stem, 16) else { continue };
        let raw = std::fs::read(&p).map_err(|e| e.to_string())?;
        let rec = if raw.len() > 4 && &raw[0..4] == b"DTEX" { raw[4..].to_vec() } else { raw };
        if let Some(role) = role_of_hash.get(&hash) {
            mattias_by_role.entry(role).or_default().push(rec);
        }
    }
    let counts: Vec<String> = ["diffuse", "normal", "spec"].iter()
        .map(|r| format!("{r}:{}", mattias_by_role.get(r).map_or(0, |v| v.len()))).collect();
    println!("    Mattias skins by role: {}", counts.join("  "));

    // Sean's base bundle.
    let mp = pack::Megapack::open(&format!("{game}/Global/Dynamic0.megapack"))?;
    let entry = *mp.entries().iter().find(|e| e.index == SEAN_PLAYER_INDEX).ok_or("FBS_RS_Sean not in Dynamic0")?;
    let sub = mp.slice(&entry);
    let d = albs::Dyn { asset_index: SEAN_PLAYER_INDEX, name: "FBS_RS_Sean".into(), n_mesh: 8, n_phys: 8, n_flash: 0, n_tex: 29 };
    let b = albs::parse_bundle(sub, &d)?;
    let (nb, swapped) = author_retex_bundle(sub, &b, &mattias_by_role)?;
    println!("    re-textured {swapped}/{} of Sean's texture slots with Mattias skins", b.tables[albs::CAT_TEX].len());

    // Write + install the patch (Sean's mesh, Mattias's pixels).
    let patch_path = portdir.join("patch_retex_sean.megapack");
    albs::write_patch_megapack(patch_path.to_str().unwrap(), &[(entry.crc, entry.index, nb)])?;
    let dst_patch = format!("{game}/Global/patchdynamic0.megapack");
    std::fs::copy(&patch_path, &dst_patch).map_err(|e| format!("install patch: {e}"))?;
    println!("    + {dst_patch}");

    // Use Sean's ORIGINAL France.materials so HIS bindings (opaque body pass) are what render.
    let fm = format!("{game}/France.materials");
    let bak = format!("{game}/France.materials.bak");
    if std::path::Path::new(&bak).exists() {
        std::fs::copy(&bak, &fm).map_err(|e| format!("restore France.materials: {e}"))?;
        println!("    restored Sean's original France.materials");
    }
    println!("\nDEPLOYED (Test A). Launch: Sean's real mesh wearing Mattias's skins.");
    println!("  SOLID  => textures/materials are fine; the see-through is Mattias's MESH.");
    println!("  SEE-THROUGH => the textures/materials are the cause.");
    println!("Uninstall: del \"{dst_patch}\"   (France.materials is already Sean's original)");
    Ok(())
}

/// ISOLATION TEST B. Mattias's merged mesh with EVERY drawcall forced to Sean's known-opaque body
/// material `0x0CBFA52B`, placed in the LB slot under Sean's ORIGINAL `France.materials` (which already
/// defines that material). Renders garbled (wrong UVs) but the solid-vs-see-through answer isolates
/// whether the see-through is Mattias's geometry or his materials' render pass.
fn deploy_mattias_opaque(f: &Flags) -> Result<(), String> {
    const SEAN_OPAQUE_MAT: u32 = 0x0CBF_A52B; // Sean's opaque body (cloth) material — in France.materials
    const SEAN_LB_HASH: u32 = 0xE159_5A4B; // CH_AL_SeanDevlin_01_LB (combined-LOD/cutscene slot)
    let game = &f.game;
    let portdir = std::path::Path::new("mattias_port");
    println!("[B] ISOLATION TEST — Mattias's mesh + Sean's opaque body material 0x{SEAN_OPAQUE_MAT:08x}");

    // 1. Rewrite Mattias's mesh so every drawcall uses Sean's opaque material.
    let msha = std::fs::read(portdir.join("pmc_hum_mattias.msha")).map_err(|e| format!("read msha: {e}"))?;
    let (unc0, unc1) = (u32at(&msha, 4), u32at(&msha, 8));
    let (c0, c1) = (u32at(&msha, 12) as usize, u32at(&msha, 16) as usize);
    let body = inflate(&msha[276..276 + c0])?;
    if body.len() != unc0 as usize {
        return Err(format!("mesh body {} != unc0 {}", body.len(), unc0));
    }
    let (body2, ndraws) = crate::mesh::force_drawcall_material(&body, SEAN_OPAQUE_MAT)?;
    let dat_z = &msha[276 + c0..276 + c0 + c1]; // keep .dat (VB/IB) compressed as-is
    let b0 = deflate(&body2);
    let mut modified: Vec<u8> = Vec::with_capacity(276 + b0.len() + c1);
    modified.extend_from_slice(b"AHSM");
    modified.extend_from_slice(&(body2.len() as u32).to_le_bytes()); // unc0
    modified.extend_from_slice(&unc1.to_le_bytes());
    modified.extend_from_slice(&(b0.len() as u32).to_le_bytes()); // c0
    modified.extend_from_slice(&(c1 as u32).to_le_bytes());
    modified.extend_from_slice(&msha[20..276]); // keep the name field (author_bundle re-identifies it)
    modified.extend_from_slice(&b0);
    modified.extend_from_slice(dat_z);
    println!("    forced {ndraws} drawcalls -> 0x{SEAN_OPAQUE_MAT:08x}");

    let empty = std::fs::read(portdir.join("pmc_empty.msha")).map_err(|e| format!("read empty: {e}"))?;

    // 2. Author the base bundle: modified Mattias in LB, stubs elsewhere, KEEP Sean's textures.
    let mp = pack::Megapack::open(&format!("{game}/Global/Dynamic0.megapack"))?;
    let entry = *mp.entries().iter().find(|e| e.index == SEAN_PLAYER_INDEX).ok_or("FBS_RS_Sean not in Dynamic0")?;
    let sub = mp.slice(&entry);
    let d = albs::Dyn { asset_index: SEAN_PLAYER_INDEX, name: "FBS_RS_Sean".into(), n_mesh: 8, n_phys: 8, n_flash: 0, n_tex: 29 };
    let b = albs::parse_bundle(sub, &d)?;
    let nb = author_bundle(sub, &b, &modified, Some(&empty), &[], Fill::CleanByHash(SEAN_LB_HASH), false)?;

    // 3. Write + install patch.
    let patch_path = portdir.join("patch_mattias_opaque.megapack");
    albs::write_patch_megapack(patch_path.to_str().unwrap(), &[(entry.crc, entry.index, nb)])?;
    let dst_patch = format!("{game}/Global/patchdynamic0.megapack");
    std::fs::copy(&patch_path, &dst_patch).map_err(|e| format!("install patch: {e}"))?;
    println!("    + {dst_patch}");

    // 4. Sean's ORIGINAL France.materials defines 0x0CBFA52B — restore it.
    let fm = format!("{game}/France.materials");
    let bak = format!("{game}/France.materials.bak");
    if std::path::Path::new(&bak).exists() {
        std::fs::copy(&bak, &fm).map_err(|e| format!("restore France.materials: {e}"))?;
        println!("    restored Sean's original France.materials");
    }
    println!("\nDEPLOYED (Test B). Launch: Mattias's geometry under Sean's opaque body material.");
    println!("  SOLID       => Mattias's MATERIALS (render pass) caused the see-through.");
    println!("  SEE-THROUGH => Mattias's MESH GEOMETRY is the cause.");
    println!("Uninstall: del \"{dst_patch}\"   (France.materials is already Sean's original)");
    Ok(())
}
