//! `sab_poc` — a bundle of The Saboteur reverse-engineering proof-of-concepts.
//!
//! This crate is a deliberate holding pen: as we prove out pieces of the modding write-path we drop
//! them here as subcommands, rather than spinning up a crate per experiment. Once a command's shape is
//! clear it graduates into a proper tool under `tools/`. See `README.md`.
//!
//! Commands:
//!   sab_poc repack        --game <dir> [--out patchdynamic0.megapack] [--tex <substr>]
//!       Byte-right texture replacement: inject a synthetic checker into a texture slot -> patch megapack.
//!   sab_poc repack-audit  --game <dir>
//!       Null-round-trip coverage of the ALBS bundle rebuild across every texture bundle.
//!   sab_poc mesh-roundtrip --game <dir> [--name <substr, default SeanDevlin>]
//!       Stage 1 of the Mattias port: parse a MESH/MSHA and re-serialize it byte-exact.
//!   sab_poc mesh-audit    --game <dir>
//!       Byte-exact MESH round-trip coverage across every skinned model.

mod albs;
mod deploy;
mod dtex;
mod gltf;
mod inventory;
mod mesh;
mod pack;
mod repack;
mod tex;
mod wsao;

// Dev-tool defaults (absolute; overridable via flags). The Mattias source and Sean's rig live in the
// sibling repo / this repo respectively, not the game dir.
const DEFAULT_GLTF: &str =
    "C:/Users/Shadow/Desktop/notes-on-the-released-game/tools/wad_simulator/workshop_export/pmc_hum_mattias/model.gltf";
const DEFAULT_SKEL: &str = "C:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/CH_AL_SeanDevlin.skel";

/// Minimal flag parser shared by the subcommands.
pub struct Flags {
    pub game: String,
    pub out: String,
    pub tex: Option<String>,
    pub name: Option<String>,
    pub gltf: String,
    pub skel: String,
    /// deploy: put Mattias in only this one mesh slot (leave the other parts as Sean's originals).
    pub slot: Option<usize>,
    /// deploy: put the full Mattias in ALL 8 slots (debug; overlapping copies Z-fight).
    pub all: bool,
    /// deploy: ISOLATION TEST A — keep Sean's ORIGINAL mesh, only rebind his materials to Mattias's
    /// skins (role-matched). Solid ⇒ textures fine, see-through is Mattias's mesh. See-through ⇒ textures.
    pub retex_sean: bool,
    /// deploy: ISOLATION TEST B — Mattias's mesh with every drawcall forced to Sean's known-opaque body
    /// material. Solid ⇒ Mattias's materials caused it. See-through ⇒ Mattias's mesh geometry is the cause.
    pub mattias_opaque: bool,
}

fn parse_flags(args: &[String]) -> Result<Flags, String> {
    let (mut game, mut out, mut tex, mut name, mut gltf, mut skel, mut slot) = (None, None, None, None, None, None, None);
    let mut all = false;
    let mut retex_sean = false;
    let mut mattias_opaque = false;
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--game" => game = it.next().cloned(),
            "--out" => out = it.next().cloned(),
            "--tex" => tex = it.next().cloned(),
            "--name" => name = it.next().cloned(),
            "--gltf" => gltf = it.next().cloned(),
            "--skel" => skel = it.next().cloned(),
            "--slot" => slot = it.next().and_then(|s| s.parse().ok()),
            "--all" => all = true,
            "--retex-sean" => retex_sean = true,
            "--mattias-opaque" => mattias_opaque = true,
            other => return Err(format!("unknown flag {other}")),
        }
    }
    Ok(Flags {
        // --game is only required by some commands; default empty and let those that need it complain.
        game: game.unwrap_or_default(),
        out: out.unwrap_or_else(|| "patchdynamic0.megapack".into()),
        tex,
        name,
        gltf: gltf.unwrap_or_else(|| DEFAULT_GLTF.into()),
        skel: skel.unwrap_or_else(|| DEFAULT_SKEL.into()),
        slot,
        all,
        retex_sean,
        mattias_opaque,
    })
}

const USAGE: &str = "sab_poc <command> --game <SaboteurDir> [opts]\n\
    commands:\n\
    \x20 repack          inject a synthetic checker into a texture slot -> patch megapack  [--out --tex]\n\
    \x20 repack-audit    ALBS bundle null-round-trip coverage\n\
    \x20 mesh-roundtrip  byte-exact MESH/MSHA re-serialize of a model                      [--name]\n\
    \x20 mesh-audit      byte-exact MESH round-trip coverage across skinned models\n\
    \x20 gltf-info       parse Mattias glTF + bone hash-remap onto Sean's rig             [--gltf --skel]";

fn main() {
    let argv: Vec<String> = std::env::args().skip(1).collect();
    let Some(cmd) = argv.first().cloned() else {
        eprintln!("{USAGE}");
        std::process::exit(2);
    };
    let flags = match parse_flags(&argv[1..]) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("error: {e}\n\n{USAGE}");
            std::process::exit(2);
        }
    };
    let r = match cmd.as_str() {
        "repack" => repack::repack(&flags),
        "repack-audit" => repack::audit(&flags.game),
        "mesh-roundtrip" => mesh::roundtrip(&flags),
        "mesh-audit" => mesh::audit(&flags.game),
        "mesh-encode-test" => mesh::encode_test(&flags),
        "mesh-import" => mesh::import(&flags),
        "retarget" => mesh::retarget(&flags),
        "tex-import" => tex::import(&flags),
        "wsao-resolve" => wsao::resolve(&flags),
        "mattias" => mesh::port(&flags),
        "basicfig" => mesh::basic_fig(&flags),
        "deploy" => deploy::deploy(&flags),
        "inventory" => inventory::inventory(&flags),
        "gltf-info" => gltf::info(&flags),
        "-h" | "--help" | "help" => {
            println!("{USAGE}");
            return;
        }
        other => Err(format!("unknown command '{other}'\n\n{USAGE}")),
    };
    if let Err(e) = r {
        eprintln!("error: {e}");
        std::process::exit(1);
    }
}
