//! Assembled assets, from the game's own `GameTemplates` (not a name heuristic).
//!
//! A character is an **`FxHumanBodySetup`** template that references an `FxHumanHead` + several
//! `FxHumanBodyPart` templates (properties `0x622dd842` / `0xa1757f0a`), each of which references the
//! actual mesh. Weapons / vehicles / props reference their meshes directly. So an *assembled asset* is
//! an asset-kind template, and its *parts* are the meshes it resolves to (directly, or one hop through
//! a body-part template). Proven on `FBS_RS_Sean` → FM/FX/HD, UB, LB, HAT, GR, Hair; 1328/1559 distinct
//! meshes are template-referenced, the rest are `Ungrouped`.

use std::collections::{HashMap, HashSet};

use sab_formats::gametemplates::{GameTemplates, Template};
use sab_formats::pandemic_hash;

use crate::meshload::MeshEntry;

/// One constituent mesh of an assembled asset.
#[derive(Clone)]
pub struct PartRef {
    /// Index into the flat mesh list (what the loader takes).
    pub mesh_index: usize,
    /// The mesh name (shown in the parts panel).
    pub name: String,
    /// A short label — the mesh's part suffix (`UB`, `HD`, `HAT`, `whole`, …).
    pub label: String,
}

/// An assembled asset: a template name, its browser category, and every mesh that folds into it.
pub struct Asset {
    pub name: String,
    pub category: &'static str,
    pub parts: Vec<PartRef>,
}

impl Asset {
    /// The parts to ASSEMBLE when this asset is clicked — one mesh per body slot.
    ///
    /// `parts` is everything the templates reference, which includes things that must NOT be stacked
    /// on top of each other:
    ///   * **LODs** (`…_LB_LOD`) are a lower-detail *substitute* for a part, not extra geometry.
    ///   * **Alternate heads** — a character ships `_HD`, and often `_FM` / `_FX` as well, which are
    ///     the same head at the same triangle count. Merging them all buries three faces in one skull.
    /// So group by slot and take one from each, preferring the plain part over any variant.
    pub fn assembly(&self) -> Vec<usize> {
        // slot key: the head variants collapse to one slot; everything else keys on its own label.
        fn slot(label: &str) -> String {
            let u = label.to_ascii_uppercase();
            match u.as_str() {
                "HD" | "FM" | "FX" | "HEAD" => "HEAD".into(),
                _ => u,
            }
        }
        let mut chosen: std::collections::BTreeMap<String, (&PartRef, i32)> = Default::default();
        for p in &self.parts {
            let u = p.label.to_ascii_uppercase();
            if u.contains("LOD") {
                continue; // a substitute, never an addition
            }
            // rank within a slot: a plain HD beats an FX/FM stand-in.
            let rank = match u.as_str() {
                "HD" | "HEAD" => 0,
                "FM" => 1,
                "FX" => 2,
                _ => 0,
            };
            let k = slot(&p.label);
            match chosen.get(&k) {
                Some((_, r)) if *r <= rank => {}
                _ => {
                    chosen.insert(k, (p, rank));
                }
            }
        }
        if chosen.is_empty() {
            // no labelled parts (a one-mesh prop): fall back to the single primary
            return vec![self.primary()];
        }
        chosen.values().map(|(p, _)| p.mesh_index).collect()
    }

    /// The mesh to load when the asset is clicked: prefer a full non-LOD body part, else first part.
    pub fn primary(&self) -> usize {
        const PREF: &[&str] = &["UB", "HD", "FM", "LB", "whole"];
        for want in PREF {
            if let Some(p) = self.parts.iter().find(|p| p.label.eq_ignore_ascii_case(want)) {
                return p.mesh_index;
            }
        }
        self.parts
            .iter()
            .find(|p| !p.label.to_ascii_uppercase().contains("LOD"))
            .or_else(|| self.parts.first())
            .map(|p| p.mesh_index)
            .unwrap_or(0)
    }
}

/// Browser category for an asset-kind template type, or `None` if the type is not a browsable asset
/// (structural/config templates, sub-parts, etc.).
fn category_for(ttype: &str) -> Option<&'static str> {
    Some(match ttype {
        "FxHumanBodySetup" => "Characters",
        "CAR" | "TrainCarriage" | "TrainEngine" | "TrainItem" => "Vehicles",
        "Weapon" | "MeleeWeapon" | "Ammo" | "Explosion" => "Weapons",
        "Prop" | "Item" => "Props",
        _ => return None,
    })
}

/// A template that stands *between* an asset and its mesh (a character body part / head).
fn is_part_type(ttype: &str) -> bool {
    matches!(ttype, "FxHumanBodyPart" | "FxHumanHead")
}

/// The part label for a mesh name: its trailing token, or the last two if the trailing one is a bare
/// number (`..._01_UB` → `UB`, `..._GR_2` → `GR_2`).
pub fn part_label(name: &str) -> String {
    let toks: Vec<&str> = name.split('_').collect();
    match toks.as_slice() {
        [.., a, b] if b.bytes().all(|c| c.is_ascii_digit()) => format!("{a}_{b}"),
        [.., b] => b.to_string(),
        _ => name.to_string(),
    }
}

/// Build the assembled-asset list from the game templates + the mesh list. Templates whose meshes
/// aren't in this megapack (world assets live in `Mega*`) resolve to nothing and are skipped; meshes
/// no asset references become one-part `Ungrouped` assets so nothing is hidden.
pub fn build(gt: &GameTemplates, mesh_list: &[MeshEntry]) -> Vec<Asset> {
    // mesh name-hash → first mesh_list index, and → its name (for labels).
    let mut mesh_idx: HashMap<u32, usize> = HashMap::new();
    let mut mesh_nm: HashMap<u32, &str> = HashMap::new();
    for (i, m) in mesh_list.iter().enumerate() {
        let h = pandemic_hash(&m.name);
        mesh_idx.entry(h).or_insert(i);
        mesh_nm.entry(h).or_insert(m.name.as_str());
    }
    // template name-hash → template (for the one-hop body-part resolution).
    let mut tpl_by_hash: HashMap<u32, &Template> = HashMap::new();
    for (_, t) in gt.templates() {
        tpl_by_hash.entry(pandemic_hash(&t.name)).or_insert(t);
    }
    // a template's directly-referenced mesh hashes (a 4-byte value that is a known mesh name-hash).
    let direct = |t: &Template| -> Vec<u32> {
        t.pairs.iter().filter_map(|p| p.as_u32()).filter(|u| mesh_idx.contains_key(u)).collect()
    };

    let mut assets: Vec<Asset> = Vec::new();
    let mut used: HashSet<u32> = HashSet::new(); // mesh name-hashes claimed by an asset

    for (_, t) in gt.templates() {
        let Some(cat) = category_for(&t.ttype) else { continue };
        // Resolve meshes: direct refs, plus one hop through FxHumanBodyPart / FxHumanHead.
        let mut hashes: Vec<u32> = Vec::new();
        for p in &t.pairs {
            let Some(u) = p.as_u32() else { continue };
            if mesh_idx.contains_key(&u) {
                hashes.push(u);
            } else if let Some(sub) = tpl_by_hash.get(&u) {
                if is_part_type(&sub.ttype) {
                    hashes.extend(direct(sub));
                }
            }
        }
        if hashes.is_empty() {
            continue; // a template with no renderable mesh in this pack — not browsable here
        }
        let mut seen = HashSet::new();
        let mut parts = Vec::new();
        for u in hashes {
            if !seen.insert(u) {
                continue;
            }
            used.insert(u);
            parts.push(PartRef {
                mesh_index: mesh_idx[&u],
                name: mesh_nm[&u].to_string(),
                label: part_label(mesh_nm[&u]),
            });
        }
        assets.push(Asset { name: t.name.clone(), category: cat, parts });
    }

    // Everything a template didn't claim → one-part Ungrouped assets (deduped by name).
    let mut seen_ung = HashSet::new();
    for (i, m) in mesh_list.iter().enumerate() {
        let h = pandemic_hash(&m.name);
        if used.contains(&h) || !seen_ung.insert(h) {
            continue;
        }
        assets.push(Asset {
            name: m.name.clone(),
            category: "Ungrouped",
            parts: vec![PartRef { mesh_index: i, name: m.name.clone(), label: "whole".into() }],
        });
    }
    assets
}

/// Fallback when GameTemplates can't be loaded: every mesh becomes its own `Ungrouped` asset, so the
/// browser still works (just without the assembled grouping).
pub fn build_flat(mesh_list: &[MeshEntry]) -> Vec<Asset> {
    let mut seen = HashSet::new();
    let mut out = Vec::new();
    for (i, m) in mesh_list.iter().enumerate() {
        if !seen.insert(pandemic_hash(&m.name)) {
            continue;
        }
        out.push(Asset {
            name: m.name.clone(),
            category: "Ungrouped",
            parts: vec![PartRef { mesh_index: i, name: m.name.clone(), label: "whole".into() }],
        });
    }
    out
}

/// Load the full `GameTemplates` object DB. The main DB is embedded in `France/loosefiles_BinPC.pack`
/// (magic `AULB`); we scan for it and parse the largest occurrence. Returns `None` if unavailable.
pub fn load_gametemplates(game_dir: &str) -> Option<GameTemplates> {
    let path = format!("{game_dir}/France/loosefiles_BinPC.pack");
    let data = std::fs::read(&path).ok()?;
    // Find every "AULB" and parse the one with the most entries (the main object DB).
    let mut best: Option<GameTemplates> = None;
    let mut best_n = 0usize;
    let mut from = 0usize;
    while let Some(rel) = data[from..].windows(4).position(|w| w == b"AULB") {
        let off = from + rel;
        if let Ok((gt, _)) = GameTemplates::parse(&data[off..]) {
            let n = gt.templates().count();
            if n > best_n {
                best_n = n;
                best = Some(gt);
            }
        }
        from = off + 4;
    }
    best
}
