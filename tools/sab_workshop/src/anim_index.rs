//! Parse `anim_bone_map.json` — the clip catalog (name, duration, per-track bone bindings).
//!
//! Clip `index` N == the N-th `hkaSplineCompressedAnimation` in the pack's main blob
//! (file order). We keep every clip but flag the ones playable on Sean's skeleton
//! (`bone_repr == "index"` && `subset_of_skeleton == true`).

// A couple of catalog fields are retained for provenance but not read by the viewer.
#![allow(dead_code)]

use serde::Deserialize;

const UNBOUND: i64 = 4294967295; // 0xFFFFFFFF sentinel for an unbound track

#[derive(Deserialize)]
struct RawClip {
    index: usize,
    name: String,
    #[serde(default)]
    duration: f32,
    #[serde(default)]
    num_transform_tracks: usize,
    #[serde(default)]
    num_tracks: usize,
    #[serde(default)]
    bone_ids: Vec<i64>,
    #[serde(default)]
    bone_repr: String,
    #[serde(default)]
    subset_of_skeleton: bool,
}

#[derive(Deserialize)]
struct RawIndex {
    #[serde(default)]
    num_main_clips: usize,
    #[serde(default)]
    skeleton_bones: usize,
    clips: Vec<RawClip>,
}

/// One playable clip descriptor.
#[derive(Clone)]
pub struct ClipInfo {
    pub index: usize,     // == N-th spline anim in the pack
    pub name: String,
    pub duration: f32,
    pub num_tracks: usize,
    /// Per-track skeleton bone index; -1 == unbound (was 0xFFFFFFFF).
    pub track_to_bone: Vec<i32>,
    pub playable: bool,
}

pub struct AnimCatalog {
    pub clips: Vec<ClipInfo>,
    pub skeleton_bones: usize,
    pub num_main_clips: usize,
}

pub fn load(path: &str) -> Result<AnimCatalog, String> {
    let text = std::fs::read_to_string(path).map_err(|e| format!("read {path}: {e}"))?;
    let raw: RawIndex = serde_json::from_str(&text).map_err(|e| format!("parse {path}: {e}"))?;
    let clips = raw
        .clips
        .into_iter()
        .map(|c| {
            let track_to_bone = c
                .bone_ids
                .iter()
                .map(|&b| if b == UNBOUND || b < 0 || b > i32::MAX as i64 { -1 } else { b as i32 })
                .collect();
            let playable = c.bone_repr == "index" && c.subset_of_skeleton;
            let num_tracks = if c.num_transform_tracks > 0 { c.num_transform_tracks } else { c.num_tracks };
            ClipInfo { index: c.index, name: c.name, duration: c.duration, num_tracks, track_to_bone, playable }
        })
        .collect();
    Ok(AnimCatalog { clips, skeleton_bones: raw.skeleton_bones, num_main_clips: raw.num_main_clips })
}
