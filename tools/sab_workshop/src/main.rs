//! sab_workshop — a native wgpu + egui viewer for The Saboteur characters.
//!
//! Loads a merged skinned mesh (SMSH) + skeleton (.skel), lists every animation clip from
//! `anim_bone_map.json` in a searchable panel, decodes the selected clip on demand from
//! `Animations.pack`, and plays it back with GPU skinning under an orbit camera.
//!
//! Run:
//!   cargo run -p sab_workshop --release
//!   cargo run -p sab_workshop --release -- --mesh <smsh> --skel <skel> --index <json> --pack <pack>
//!   cargo run -p sab_workshop --release -- --help

mod anim_index;
mod app;
mod assets;
mod camera;
mod dtex;
mod editor;
mod formats;
mod gui;
mod havok;
mod meshload;
mod models;
mod pack;
mod render;
mod resolve;
mod skinning;
mod wsao;

/// Resolved input paths (CLI overrides the built-in defaults).
#[derive(Clone)]
pub struct Config {
    pub mesh: String,
    pub skel: String,
    pub index: String,
    pub pack: String,
    /// Megapack the character's DTEX texture bundles live in (in-app texture resolution).
    pub megapack: String,
    /// Case-insensitive DTEX-name token identifying the character's textures (e.g. "SeanDevlinn").
    pub char_token: String,
    /// The shared palette archive — props/vehicles keep their skins here rather than beside the mesh.
    pub palettes: String,
    /// Optional WSAO material library (`France.materials`). When set, textures resolve the engine's way
    /// (submesh material hash → material record → texture hashes) instead of the name heuristic.
    pub wsao: Option<String>,
    /// Directory of loose `<hash>.dtex` files (from `sab_poc mattias`) to load WSAO-resolved textures from.
    pub dtex_dir: Option<String>,
}

impl Default for Config {
    fn default() -> Self {
        Config {
            mesh: "c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/sean_full.smsh".into(),
            skel: "c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/CH_AL_SeanDevlin.skel".into(),
            index: "c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/anim_bone_map.json".into(),
            pack: "C:/GOG Games/The Saboteur/Animations.pack".into(),
            megapack: "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack".into(),
            char_token: "SeanDevlinn".into(),
            palettes: "C:/GOG Games/The Saboteur/Global/Palettes0.megapack".into(),
            wsao: None,
            dtex_dir: None,
        }
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.iter().any(|a| a == "--help" || a == "-h") {
        print_help();
        return;
    }
    let get = |flag: &str| {
        args.iter().position(|a| a == flag).and_then(|i| args.get(i + 1)).cloned()
    };
    let mut cfg = Config::default();
    if let Some(v) = get("--mesh") { cfg.mesh = v; }
    if let Some(v) = get("--skel") { cfg.skel = v; }
    if let Some(v) = get("--index") { cfg.index = v; }
    if let Some(v) = get("--pack") { cfg.pack = v; }
    if let Some(v) = get("--megapack") { cfg.megapack = v; }
    if let Some(v) = get("--char") { cfg.char_token = v; }
    if let Some(v) = get("--palettes") { cfg.palettes = v; }
    if let Some(v) = get("--wsao") { cfg.wsao = Some(v); }
    if let Some(v) = get("--dtexdir") { cfg.dtex_dir = Some(v); }

    // Headless verification of the load -> decode -> skin path (no window). Optional clip index
    // into the playable list: `--selftest [N]`.
    if let Some(i) = args.iter().position(|a| a == "--anim-sweep") {
        let n: usize = args.get(i + 1).and_then(|s| s.parse().ok()).unwrap_or(200);
        std::process::exit(app::anim_sweep(cfg, n));
    }
    if let Some(i) = args.iter().position(|a| a == "--selftest") {
        let n: usize = args.get(i + 1).and_then(|s| s.parse().ok()).unwrap_or(0);
        std::process::exit(app::selftest(cfg, n));
    }
    // Headless texture-binding verification: `--texcheck [nameSubstr]` (default all assets).
    if let Some(i) = args.iter().position(|a| a == "--texcheck") {
        let filter = args.get(i + 1).filter(|s| !s.starts_with("--")).cloned().unwrap_or_default();
        std::process::exit(app::texcheck(cfg, &filter));
    }

    app::run(cfg);
}

fn print_help() {
    println!(
        "sab_workshop — The Saboteur character/animation viewer (wgpu + egui)\n\n\
         USAGE:\n  sab_workshop [OPTIONS]\n\n\
         OPTIONS:\n\
         \x20 --mesh  <path>   SMSH skinned mesh   (default: output/skeletons/sean_full.smsh)\n\
         \x20 --skel  <path>   .skel skeleton      (default: output/skeletons/CH_AL_SeanDevlin.skel)\n\
         \x20 --index <path>   anim_bone_map.json  (default: output/anim_bone_map.json)\n\
         \x20 --pack  <path>   Animations.pack     (default: C:/GOG Games/The Saboteur/Animations.pack)\n\
         \x20 --help           show this help\n\n\
         CONTROLS (in the window):\n\
         \x20 LMB drag  orbit    |  MMB drag  pan    |  wheel  zoom\n\
         \x20 left panel: search + click a clip to play; bottom panel: play/pause, loop, speed, scrubber"
    );
}
