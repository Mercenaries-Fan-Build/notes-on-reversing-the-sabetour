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
mod settings;
mod skinning;
mod wsao;

/// Resolved input paths (CLI overrides the built-in defaults).
#[derive(Clone)]
pub struct Config {
    /// The game install root. Every game-side path below is DERIVED from this (see `settings.rs`);
    /// it is carried here as a first-class field so nothing has to recover it by walking parents up
    /// from a megapack path, which is how it used to work in four separate places.
    pub game_dir: String,
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
    /// WSAO material library (`France.materials`) — the engine's material hash → texture binding.
    /// Defaults to the one in `game_dir`; `--wsao` overrides it.
    pub wsao: Option<String>,
    /// Directory of loose `<hash>.dtex` files (from `sab_poc mattias`) to load WSAO-resolved textures from.
    pub dtex_dir: Option<String>,
    /// User settings (install location, default language, output slot, type scale).
    pub settings: crate::settings::Settings,
}

/// Where this repo's generated assets (`skeletons/`, `anim_bone_map.json`) live.
///
/// This used to be one author's absolute checkout path, compiled into the binary — correct on
/// exactly one machine and a dead default in every release build. Resolved instead, in order:
/// `SAB_WORKSHOP_OUTPUT`, then the nearest `output/` walking up from the working directory and from
/// the executable, then a bare relative `output`. `--mesh`/`--skel`/`--index` still override.
fn output_dir() -> String {
    if let Ok(v) = std::env::var("SAB_WORKSHOP_OUTPUT") {
        return v.replace('\\', "/");
    }
    let starts = [std::env::current_dir().ok(), std::env::current_exe().ok().and_then(|p| p.parent().map(|d| d.to_path_buf()))];
    for start in starts.into_iter().flatten() {
        let mut dir = start.as_path();
        loop {
            let cand = dir.join("output");
            if cand.join("skeletons").is_dir() {
                return cand.to_string_lossy().replace('\\', "/");
            }
            match dir.parent() {
                Some(p) => dir = p,
                None => break,
            }
        }
    }
    "output".into()
}

impl Config {
    /// Build a config from persisted settings, deriving every game-side path from the one root.
    pub fn from_settings(s: crate::settings::Settings) -> Config {
        let out = output_dir();
        Config {
            game_dir: s.game_dir.clone(),
            mesh: format!("{out}/skeletons/sean_full.smsh"),
            skel: format!("{out}/skeletons/CH_AL_SeanDevlin.skel"),
            index: format!("{out}/anim_bone_map.json"),
            pack: s.anim_pack(),
            megapack: s.megapack(),
            char_token: "SeanDevlinn".into(),
            palettes: s.palettes(),
            wsao: Some(s.wsao()),
            dtex_dir: None,
            settings: s,
        }
    }
}

impl Default for Config {
    fn default() -> Self {
        Config::from_settings(crate::settings::Settings::load())
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
    // Settings supply the defaults; the flags below override for a one-off run WITHOUT persisting,
    // so scripting against another install never rewrites what the user chose in the UI.
    let mut settings = crate::settings::Settings::load();
    if let Some(v) = get("--game") {
        settings.game_dir = v;
        settings.clamp();
    }
    let mut cfg = Config::from_settings(settings);
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
         \x20 --game  <dir>    game install root   (default: the saved setting, else auto-detected)\n\
         \x20 --mesh  <path>   SMSH skinned mesh   (default: <output>/skeletons/sean_full.smsh)\n\
         \x20 --skel  <path>   .skel skeleton      (default: <output>/skeletons/CH_AL_SeanDevlin.skel)\n\
         \x20 --index <path>   anim_bone_map.json  (default: <output>/anim_bone_map.json)\n\
         \x20 --pack  <path>   Animations.pack     (default: <game>/Animations.pack)\n\
         \x20 --help           show this help\n\n\
         PATHS:\n\
         \x20 <game>   from settings.json, or auto-detected (GOG / Galaxy / Steam / Pandemic layouts)\n\
         \x20 <output> $SAB_WORKSHOP_OUTPUT, else the nearest output/ above the CWD or the exe\n\n\
         CONTROLS (in the window):\n\
         \x20 LMB drag  orbit    |  MMB drag  pan    |  wheel  zoom\n\
         \x20 left panel: search + click a clip to play; bottom panel: play/pause, loop, speed, scrubber"
    );
}
