//! Character texture resolver — the "name-hash path" that replaces the (PC-absent) WSAO lookup.
//!
//! WSAO would map a prim's `materialHash` to its textures, but the `.materials` container isn't in
//! the retail PC install (see memory `wsao-material-format-and-gap`). Instead we read the character's
//! DTEX bundles straight from the megapack: DTEX names are PLAINTEXT, so we find the bundles that
//! carry the character token, walk their records, and classify each by name suffix
//! (`_D` diffuse, `_N`/`_NM` normal, `_S` spec, `_WM`/`_MASK` mask). The submesh→texture identity
//! WSAO would have given is supplied instead by the auto-seed + inspector picker (see `app`).

use crate::dtex::{self, CpuTexture};
use crate::pack::{self, Megapack};

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Role {
    Diffuse,
    Normal,
    Spec,
    Mask,
    Other,
}

impl Role {
    pub fn label(self) -> &'static str {
        match self {
            Role::Diffuse => "diffuse",
            Role::Normal => "normal",
            Role::Spec => "spec",
            Role::Mask => "mask",
            Role::Other => "other",
        }
    }
}

/// One texture found in the character's bundles. Holds the RAW (still-compressed) DTEX record and
/// only its header metadata — decoding is LAZY (`decode()`), because a bundle sweep turns up a couple
/// hundred records and eagerly BC-decoding them all would cost seconds and hundreds of MB of RGBA for
/// the handful actually bound to a submesh.
pub struct TexAsset {
    pub name: String,
    pub role: Role,
    pub width: u32,
    pub height: u32,
    pub format: String,
    record: Vec<u8>,
}

impl TexAsset {
    /// Decode this record's finest mip to RGBA (call when binding it to a submesh).
    pub fn decode(&self) -> Result<CpuTexture, String> {
        dtex::decode(&self.record)
    }
}

/// Classify a DTEX by its name suffix (the game's role convention).
pub fn classify(name: &str) -> Role {
    let n = name.to_ascii_lowercase();
    if n.ends_with("_nm") || n.ends_with("_n") {
        Role::Normal
    } else if n.ends_with("_s") {
        Role::Spec
    } else if n.ends_with("_wm") || n.ends_with("_mask") {
        Role::Mask
    } else if n.ends_with("_d") {
        Role::Diffuse
    } else {
        Role::Other
    }
}

/// Load the textures from the character's bundles in `megapack_path`. `token` is an ASCII substring
/// (e.g. "SeanDevlinn") matched case-insensitively against the raw bundle bytes to select which
/// bundles are this character's — the pre-scan keeps us from running the expensive record walk over
/// the whole 715 MB pack.
///
/// EVERY DTEX record in a matched bundle is returned, not just token-named ones: a character bundle
/// also carries its accessory textures (`CH_AC_Eyes_*`, `CH_AC_Mouth`), which are exactly what the
/// head submeshes need. Duplicate names collapse to the first occurrence.
pub fn load_character_textures(megapack_path: &str, token: &str) -> Result<Vec<TexAsset>, String> {
    let mp = Megapack::open(megapack_path)?;
    Ok(textures_in(&mp, token))
}

/// As `load_character_textures`, but over an already-open megapack (the app keeps one resident for
/// browsing + click-to-load, so re-reading 715 MB per asset would be wasteful).
pub fn textures_in(mp: &Megapack, token: &str) -> Vec<TexAsset> {
    let mut out: Vec<TexAsset> = Vec::new();
    let mut seen: Vec<String> = Vec::new();
    for e in mp.entries() {
        let sub = mp.slice(e);
        if sub.is_empty() || !pack::contains_ascii_ci(sub, token) {
            continue;
        }
        collect_records(sub, &mut out, &mut seen);
    }
    out.sort_by(|a, b| a.name.to_ascii_lowercase().cmp(&b.name.to_ascii_lowercase()));
    out
}

/// Every texture in ONE bundle — used for a model loaded from the navigator (its own bundle carries
/// its skins).
pub fn textures_in_slice(sub: &[u8]) -> Vec<TexAsset> {
    let mut out = Vec::new();
    let mut seen = Vec::new();
    collect_records(sub, &mut out, &mut seen);
    out.sort_by(|a, b| a.name.to_ascii_lowercase().cmp(&b.name.to_ascii_lowercase()));
    out
}

fn collect_records(sub: &[u8], out: &mut Vec<TexAsset>, seen: &mut Vec<String>) {
    for (off, len, name) in dtex::find_records(sub) {
        if seen.iter().any(|s: &String| s.eq_ignore_ascii_case(&name)) {
            continue;
        }
        let record = &sub[off..off + len];
        // Header only — no inflate/BC decode here (see TexAsset).
        let Ok(d) = dtex::parse(record) else { continue };
        seen.push(name.clone());
        out.push(TexAsset {
            role: classify(&name),
            name,
            width: d.width as u32,
            height: d.height as u32,
            format: d.format_name(),
            record: record.to_vec(),
        });
    }
}

/// Generic seed for a model loaded from the navigator: we have no part decomposition (that's the
/// merged-Sean case in `autoseed`), so bind every submesh to the pool's first diffuse as a visible
/// starting point. The picker is how it gets correct — see the Materials note in the README.
pub fn autoseed_generic(n_submeshes: usize, assets: &[TexAsset]) -> Vec<Option<usize>> {
    let first_diffuse = assets.iter().position(|a| a.role == Role::Diffuse);
    vec![first_diffuse; n_submeshes]
}

/// Progressively broader search tokens for a model name. Saboteur asset names are
/// `<CAT>_<SUB>_<Thing…>[_variant]` and their textures usually share the `<Thing>` stem but NOT the
/// category prefix (`CH_AL_SeanDevlin_01_GR`'s skins are `CH_MB_SeanDevlinn_*`), so we drop the
/// two-segment prefix and then shed trailing segments, longest token first.
fn name_tokens(model: &str) -> Vec<String> {
    let segs: Vec<&str> = model.split('_').collect();
    // Drop a leading 2-segment category prefix when it looks like one (short codes: CH_AL, GB_WP…).
    let start = if segs.len() > 3 && segs[0].len() <= 3 && segs[1].len() <= 3 { 2 } else { 0 };
    let mut out = Vec::new();
    let mut end = segs.len();
    while end > start {
        let tok = segs[start..end].join("_");
        // A 1-2 char token would match half the pack.
        if tok.len() >= 3 {
            out.push(tok);
        }
        end -= 1;
    }
    out
}

/// The texture pool for a model loaded from the navigator.
///
/// A character's skins sit in its OWN bundle (fast path). Plenty of assets don't work that way
/// though — props keep theirs in the shared palette archive — so if the bundle yields no diffuse we
/// sweep every open pack by name token (longest first) and take the first token that turns up a
/// diffuse. `packs` should be the dynamic pack AND `Palettes0` (see `Config::palettes`). An empty
/// pool means nothing matched: the model renders white and the picker has nothing to offer, which
/// the Materials panel says out loud.
pub fn texture_pool_for(packs: &[&Megapack], model_name: &str, bundle: &[u8]) -> Vec<TexAsset> {
    let own = textures_in_slice(bundle);
    if own.iter().any(|a| a.role == Role::Diffuse) {
        return own;
    }
    for tok in name_tokens(model_name) {
        for mp in packs {
            let hit = textures_in(mp, &tok);
            if hit.iter().any(|a| a.role == Role::Diffuse) {
                return hit;
            }
        }
    }
    own
}

/// Per-submesh texture assignment persisted next to the mesh (`<mesh>.materials.json`). Stores
/// texture NAMES (stable across re-resolves) rather than indices. This is the user-authored map that
/// stands in for the identity WSAO would have provided — the picker writes it, load prefers it over
/// the auto-seed.
#[derive(serde::Serialize, serde::Deserialize, Default)]
pub struct Sidecar {
    pub submeshes: Vec<Option<String>>,
}

pub fn sidecar_path(mesh_path: &str) -> String {
    format!("{mesh_path}.materials.json")
}

/// Read the sidecar and map its texture names onto `assets` indices, per submesh. Returns `None` if
/// there's no sidecar. Unknown names (texture missing this run) resolve to `None` for that submesh.
pub fn load_sidecar(mesh_path: &str, n_submeshes: usize, assets: &[TexAsset]) -> Option<Vec<Option<usize>>> {
    let text = std::fs::read_to_string(sidecar_path(mesh_path)).ok()?;
    let sc: Sidecar = serde_json::from_str(&text).ok()?;
    let mut out = vec![None; n_submeshes];
    for (i, slot) in sc.submeshes.iter().take(n_submeshes).enumerate() {
        if let Some(name) = slot {
            out[i] = assets.iter().position(|a| a.name.eq_ignore_ascii_case(name));
        }
    }
    Some(out)
}

/// Write the current assignment to the sidecar.
pub fn save_sidecar(mesh_path: &str, assign: &[Option<usize>], assets: &[TexAsset]) -> Result<(), String> {
    let sc = Sidecar {
        submeshes: assign.iter().map(|a| a.map(|ai| assets[ai].name.clone())).collect(),
    };
    let text = serde_json::to_string_pretty(&sc).map_err(|e| e.to_string())?;
    std::fs::write(sidecar_path(mesh_path), text).map_err(|e| e.to_string())
}

/// Sean's merged parts, in merge order, paired with the diffuse-name keyword each maps to. The
/// merge (`merge_smsh.py`) concatenates parts in this order, so cumulative index counts give each
/// part's range in the merged buffer. (Character-specific seed; the picker overrides anything wrong.)
const SEAN_PARTS: [(&str, &str); 5] =
    [("HD", "head"), ("UB", "jacket"), ("LB", "pants"), ("GR", "hand"), ("HAT", "hat")];

/// Best-effort submesh → diffuse-asset seed. Reads the sibling `parts/sean_<PART>.smsh` files to
/// recover each merged part's index range, maps a submesh (by its `index_start`) to its part, then
/// to the part's keyword diffuse. Returns `assets` index per submesh, or `None` where unknown.
/// All-`None` if the parts dir is absent (then the picker is the only path).
pub fn autoseed(mesh_path: &str, submeshes: &[crate::formats::SubMesh], assets: &[TexAsset]) -> Vec<Option<usize>> {
    let parts_dir = std::path::Path::new(mesh_path)
        .parent()
        .map(|d| d.join("parts"))
        .unwrap_or_default();
    // (keyword, start, end) per part, in merge order.
    let mut bounds: Vec<(&str, u32, u32)> = Vec::new();
    let mut cursor = 0u32;
    for (part, keyword) in SEAN_PARTS {
        let p = parts_dir.join(format!("sean_{part}.smsh"));
        let Ok(bytes) = std::fs::read(&p) else {
            continue;
        };
        if bytes.len() < 16 || &bytes[0..4] != b"SMSH" {
            continue;
        }
        let ni = u32::from_le_bytes([bytes[12], bytes[13], bytes[14], bytes[15]]);
        bounds.push((keyword, cursor, cursor + ni));
        cursor += ni;
    }
    let diffuse_for = |keyword: &str| -> Option<usize> {
        assets.iter().position(|a| {
            a.role == Role::Diffuse && a.name.to_ascii_lowercase().contains(keyword)
        })
    };
    submeshes
        .iter()
        .map(|sm| {
            let part = bounds.iter().find(|(_, s, e)| sm.index_start >= *s && sm.index_start < *e)?;
            diffuse_for(part.0)
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Against the REAL install: find + decode Sean's diffuse textures from Dynamic0.megapack.
    /// Skips cleanly when the game isn't installed at the default path.
    #[test]
    fn resolve_sean_diffuse_from_megapack() {
        let mp = "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack";
        if !std::path::Path::new(mp).exists() {
            eprintln!("skip: {mp} not present");
            return;
        }
        let assets = load_character_textures(mp, "SeanDevlinn").expect("resolve");
        let diffuse: Vec<&TexAsset> = assets.iter().filter(|a| a.role == Role::Diffuse).collect();
        eprintln!("resolved {} Sean textures ({} diffuse)", assets.len(), diffuse.len());
        assert!(!diffuse.is_empty(), "expected at least one Sean diffuse texture");
        // The head diffuse must be present, correctly sized, and actually decode to real pixels.
        let head = diffuse
            .iter()
            .find(|a| a.name.to_ascii_lowercase().contains("head"))
            .expect("expected a head diffuse");
        assert_eq!((head.width, head.height), (512, 512));
        let tex = head.decode().expect("decode head diffuse");
        assert_eq!(tex.rgba.len(), 512 * 512 * 4);
        let n = (512 * 512) as u64;
        let (r, b) = tex.rgba.chunks_exact(4).fold((0u64, 0u64), |(r, b), p| {
            (r + p[0] as u64, b + p[2] as u64)
        });
        // Skin diffuse reads warm (R > B) — guards a byte-swapped or blank decode.
        assert!(r / n > r.min(b) / n || r > b, "skin warmer than blue (R {} > B {})", r / n, b / n);
        eprintln!("head diffuse decoded: {}x{} mean R={} B={}", tex.width, tex.height, r / n, b / n);
    }
}
