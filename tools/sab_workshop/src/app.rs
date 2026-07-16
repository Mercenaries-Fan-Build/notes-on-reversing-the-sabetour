//! Application: load assets, run the winit event loop, draw the UI, drive playback.
//!
//! Data flow:
//!   startup        load SMSH + .skel + anim_bone_map.json + Animations.pack (parse AP0L/packfile
//!                  once -> list of spline-anim offsets `scas`); compute bind-pose joint matrices.
//!   select a clip  re-parse the packfile, `read_spline_anim(scas[clip.index])`, keep the
//!                  self-contained `SplineAnim` + its per-track bone map.
//!   each frame     `sample_at(time)` -> per-track local transforms -> `skinning::posed` -> joint
//!                  matrices uploaded to the GPU; the vertex shader skins the mesh.

use std::sync::Arc;
use std::time::Instant;

use glam::Vec3;
use winit::event::{ElementState, Event, MouseButton, MouseScrollDelta, WindowEvent};
use winit::event_loop::EventLoop;
use winit::keyboard::{KeyCode, PhysicalKey};
use winit::window::WindowBuilder;

use crate::anim_index::{self, AnimCatalog};
use crate::camera::OrbitCamera;
use crate::formats::{self, Bone, Smsh, SubMesh};
use crate::gui::theme;
use crate::havok::{self, Packfile, SplineAnim};
use crate::meshload;
use crate::pack;
use crate::render::Renderer;
use crate::resolve;
use crate::skinning;
use crate::Config;

/// The animation pack, parsed once: raw bytes + the ordered spline-anim object offsets.
struct PackData {
    file: Vec<u8>,
    blob_off: usize,
    hk_size: usize,
    scas: Vec<usize>, // data-relative offset of the N-th hkaSplineCompressedAnimation
}

impl PackData {
    fn load(path: &str) -> Result<PackData, String> {
        let file = std::fs::read(path).map_err(|e| format!("read {path}: {e}"))?;
        let ap = havok::parse_ap0l(&file)?;
        let blob = &file[ap.blob_off..ap.blob_off + ap.hk_size];
        let pk = Packfile::parse(blob)?;
        let scas: Vec<usize> = pk
            .vfixups
            .iter()
            .filter(|(_, c)| c == "hkaSplineCompressedAnimation")
            .map(|(s, _)| *s)
            .collect();
        Ok(PackData { file, blob_off: ap.blob_off, hk_size: ap.hk_size, scas })
    }
    fn blob(&self) -> &[u8] {
        &self.file[self.blob_off..self.blob_off + self.hk_size]
    }
}

/// A clip decoded and ready to sample.
struct LoadedClip {
    anim: SplineAnim,
    track_to_bone: Vec<i32>,
    name: String,
    duration: f32,
    frame_duration: f32,
    frame_count: usize,
}

/// Playback state.
struct Playback {
    time: f32,
    playing: bool,
    looping: bool,
    speed: f32,
}

pub fn run(cfg: Config) {
    let mut errors: Vec<String> = Vec::new();

    // --- essential assets: mesh + skeleton (no viewer without them) ---
    let mut mesh: Smsh = match std::fs::read(&cfg.mesh).map_err(|e| e.to_string()).and_then(|b| formats::read_smsh(&b)) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("[sab_workshop] FATAL: cannot load mesh {}: {e}", cfg.mesh);
            return;
        }
    };
    let mut skel: Vec<Bone> = match std::fs::read_to_string(&cfg.skel) {
        Ok(t) => formats::read_skel(&t),
        Err(e) => {
            eprintln!("[sab_workshop] FATAL: cannot load skeleton {}: {e}", cfg.skel);
            return;
        }
    };
    if skel.is_empty() {
        eprintln!("[sab_workshop] FATAL: skeleton {} parsed to 0 bones", cfg.skel);
        return;
    }
    // Place rigid accessories (hat/props) now that both mesh and rig are in hand.
    formats::bind_rigid_attachments(&mut mesh, &skinning::bind_world(&skel));
    println!(
        "[sab_workshop] mesh: {} verts, {} tris | skeleton: {} bones",
        mesh.positions.len(),
        mesh.indices.len() / 3,
        skel.len()
    );

    // --- optional assets: clip catalog + pack (bind pose still works without them) ---
    let catalog: AnimCatalog = match anim_index::load(&cfg.index) {
        Ok(c) => {
            let playable = c.clips.iter().filter(|c| c.playable).count();
            println!(
                "[sab_workshop] anim index: {} clips ({} playable on this skeleton), skeleton_bones={}",
                c.clips.len(), playable, c.skeleton_bones
            );
            c
        }
        Err(e) => {
            errors.push(format!("anim index: {e}"));
            AnimCatalog { clips: Vec::new(), skeleton_bones: skel.len(), num_main_clips: 0 }
        }
    };
    let pack: Option<PackData> = match PackData::load(&cfg.pack) {
        Ok(p) => {
            println!("[sab_workshop] pack: {} hkaSplineCompressedAnimation clips", p.scas.len());
            Some(p)
        }
        Err(e) => {
            errors.push(format!("pack: {e}"));
            None
        }
    };

    // Playable clip rows (index into catalog.clips), pre-filtered to the ones authored on this rig.
    let playable_rows: Vec<usize> = catalog
        .clips
        .iter()
        .enumerate()
        .filter(|(_, c)| c.playable)
        .map(|(i, _)| i)
        .collect();

    // --- bounding sphere for the camera ---
    let (center, radius) = bounds(&mesh);

    // --- window + renderer ---
    let event_loop = match EventLoop::new() {
        Ok(e) => e,
        Err(e) => {
            eprintln!("[sab_workshop] FATAL: event loop: {e}");
            return;
        }
    };
    let window = match WindowBuilder::new()
        .with_title("sab_workshop — The Saboteur character viewer")
        .with_inner_size(winit::dpi::LogicalSize::new(1280.0, 800.0))
        .build(&event_loop)
    {
        Ok(w) => Arc::new(w),
        Err(e) => {
            eprintln!("[sab_workshop] FATAL: window: {e}");
            return;
        }
    };
    let mut renderer = match pollster::block_on(Renderer::new(window.clone(), &mesh, skel.len())) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("[sab_workshop] FATAL: renderer init: {e}");
            return;
        }
    };
    let mut gui = crate::gui::Gui::new(renderer.device(), renderer.surface_format(), &window);

    // --- initial GPU state: bind pose ---
    let bind = skinning::bind_pose(&skel);
    renderer.update_joints(&bind);

    // --- textures: resolve the character's DTEX from the megapack (in-app), then assign per submesh:
    // a saved sidecar (user-authored, via the Materials picker) wins; otherwise auto-seed by body
    // part. A ~715 MB read → a brief blocking load at startup (run --release). ---
    println!("[sab_workshop] opening {} …", cfg.megapack);
    let megapack: Option<pack::Megapack> = match pack::Megapack::open(&cfg.megapack) {
        Ok(m) => Some(m),
        Err(e) => {
            eprintln!("[sab_workshop] megapack unavailable ({e}) — no browsing / textures");
            errors.push(format!("megapack: {e}"));
            None
        }
    };
    // Shared palette archive — searched as a texture fallback for props/vehicles.
    let palettes: Option<pack::Megapack> = pack::Megapack::open(&cfg.palettes).ok();
    if palettes.is_none() {
        eprintln!("[sab_workshop] palettes archive unavailable ({}) — prop textures may not resolve", cfg.palettes);
    }
    // The browsable model catalog: a header-only sweep, so this is cheap (no inflate).
    let mesh_list: Vec<meshload::MeshEntry> =
        megapack.as_ref().map(|m| meshload::list_meshes(m.raw())).unwrap_or_default();

    let mut assets: Vec<resolve::TexAsset> = Vec::new();
    let mut submesh_tex: Vec<Option<usize>> = vec![None; renderer.submeshes().len()];
    if let Some(mp) = &megapack {
        let a = resolve::textures_in(mp, &cfg.char_token);
        let n = renderer.submeshes().len();
        let from_sidecar = resolve::load_sidecar(&cfg.mesh, n, &a);
        let seeded = from_sidecar.is_none();
        submesh_tex =
            from_sidecar.unwrap_or_else(|| resolve::autoseed(&cfg.mesh, renderer.submeshes(), &a));
        // Decode only the handful actually bound (see TexAsset: decoding is lazy).
        for (i, slot) in submesh_tex.iter().enumerate() {
            if let Some(ai) = slot {
                match a[*ai].decode() {
                    Ok(tex) => renderer.set_submesh_texture(i, &tex),
                    Err(e) => eprintln!("[sab_workshop] decode {}: {e}", a[*ai].name),
                }
            }
        }
        let applied = submesh_tex.iter().filter(|s| s.is_some()).count();
        let diffuse = a.iter().filter(|x| x.role == resolve::Role::Diffuse).count();
        println!(
            "[sab_workshop] {} models | textures: {} assets ({diffuse} diffuse) from {}; {} {applied}/{n} submeshes",
            mesh_list.len(),
            a.len(),
            cfg.char_token,
            if seeded { "auto-seeded" } else { "from sidecar," }
        );
        assets = a;
    }
    let mut mesh_stats = (mesh.positions.len(), mesh.indices.len() / 3, skel.len());
    let mut submeshes = renderer.submeshes().to_vec();
    // The clip catalog's track→bone indices are authored against the startup rig; a model with a
    // different bone count cannot use them.
    let rig_bones = skel.len();
    let mut model_name = std::path::Path::new(&cfg.mesh)
        .file_stem()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|| "model".into());

    // --- interactive state (all locals, captured by the move closure) ---
    let mut camera = OrbitCamera::framing(center, radius);
    let mut show_all = false; // include non-playable clips in the list
    let mut current: Option<LoadedClip> = None;
    let mut playback = Playback { time: 0.0, playing: true, looping: true, speed: 1.0 };
    let mut pending_load: Option<usize> = None; // catalog.clips index requested this frame
    // Materials picker request: (submesh, Some(asset) | None to unassign), applied after the UI runs.
    let mut pending_tex: Option<(usize, Option<usize>)> = None;
    // Navigator: which category is shown, and a click-to-load request (index into `mesh_list`).
    // Root motion walks the character out of a fixed-camera preview; lock it by default.
    let mut lock_root = true;
    let mut nav_tab = NavTab::Models;
    let mut pending_model: Option<usize> = None;
    let mut nav_search = String::new();
    // Outcome of the last click-to-load, surfaced in the status bar: (message, is_error).
    let mut load_status: Option<(String, bool)> = None;
    let mut last_frame = Instant::now();

    // mouse
    let mut mouse: (f32, f32) = (0.0, 0.0);
    let mut lmb = false;
    let mut mmb = false;

    let result = event_loop.run(move |event, elwt| match event {
        Event::AboutToWait => window.request_redraw(),
        Event::WindowEvent { window_id, event } if window_id == window.id() => {
            let gui_took = gui.on_event(&event);
            match event {
                WindowEvent::CloseRequested => elwt.exit(),
                WindowEvent::Resized(size) => renderer.resize(size.width, size.height),
                WindowEvent::KeyboardInput { event, .. } => {
                    if event.state == ElementState::Pressed && !gui.ctx.wants_keyboard_input() {
                        match event.physical_key {
                            PhysicalKey::Code(KeyCode::Escape) => elwt.exit(),
                            PhysicalKey::Code(KeyCode::Space) => playback.playing = !playback.playing,
                            _ => {}
                        }
                    }
                }
                WindowEvent::MouseInput { state, button, .. } => {
                    let pressed = state == ElementState::Pressed;
                    match button {
                        MouseButton::Left => lmb = pressed && !gui_took,
                        MouseButton::Middle => mmb = pressed && !gui_took,
                        _ => {}
                    }
                }
                WindowEvent::CursorMoved { position, .. } => {
                    let (nx, ny) = (position.x as f32, position.y as f32);
                    let (dx, dy) = (nx - mouse.0, ny - mouse.1);
                    mouse = (nx, ny);
                    if !gui_took {
                        if lmb {
                            camera.rotate(dx, dy);
                        } else if mmb {
                            camera.pan(dx, dy);
                        }
                    }
                }
                WindowEvent::MouseWheel { delta, .. } => {
                    if !gui_took {
                        let s = match delta {
                            MouseScrollDelta::LineDelta(_, y) => y,
                            MouseScrollDelta::PixelDelta(p) => p.y as f32 / 40.0,
                        };
                        camera.zoom(s);
                    }
                }
                WindowEvent::RedrawRequested => {
                    // --- advance playback ---
                    let now = Instant::now();
                    let dt = (now - last_frame).as_secs_f32().min(0.1);
                    last_frame = now;
                    if let Some(clip) = &current {
                        if playback.playing && clip.duration > 0.0 {
                            playback.time += dt * playback.speed;
                            if playback.looping {
                                playback.time = playback.time.rem_euclid(clip.duration);
                            } else if playback.time > clip.duration {
                                playback.time = clip.duration;
                                playback.playing = false;
                            }
                        }
                    }

                    // --- pose -> joint matrices ---
                    if let (Some(clip), Some(pk)) = (&current, &pack) {
                        let pose = clip.anim.sample_at(pk.blob(), playback.time);
                        let mats = skinning::posed(&skel, &pose, &clip.track_to_bone, lock_root);
                        renderer.update_joints(&mats);
                    }

                    renderer.update_camera(camera.view_proj(renderer.aspect()));

                    // --- UI ---
                    let rig_ok = skel.len() == rig_bones;
                    gui.run(|ctx| {
                        build_ui(
                            ctx, &catalog, &playable_rows, &mut show_all,
                            &current, &mut playback, &mut pending_load, &mut renderer.show_grid,
                            &mut renderer.show_textures, &mut lock_root, &errors, pack.is_some(), rig_ok,
                            mesh_stats, &model_name, &load_status,
                            &mut MatsCtx {
                                submeshes: &submeshes,
                                assets: &assets,
                                submesh_tex: &submesh_tex,
                                pending_tex: &mut pending_tex,
                            },
                            &mut NavCtx {
                                tab: &mut nav_tab,
                                search: &mut nav_search,
                                models: &mesh_list,
                                assets: &assets,
                                pending_model: &mut pending_model,
                                current_model: &model_name,
                            },
                        );
                    });

                    // --- act on a navigator model click: swap mesh + rig + textures + camera ---
                    if let Some(mi) = pending_model.take() {
                        if let (Some(mp), Some(entry)) = (&megapack, mesh_list.get(mi)) {
                            match meshload::load(mp.raw(), entry) {
                                Ok(lm) => {
                                    let nbones = lm.bones.len();
                                    renderer.set_mesh(&lm.mesh, nbones);
                                    skel = lm.bones;
                                    renderer.update_joints(&skinning::bind_pose(&skel));
                                    submeshes = renderer.submeshes().to_vec();
                                    mesh_stats =
                                        (lm.mesh.positions.len(), lm.mesh.indices.len() / 3, nbones);
                                    // Its own bundle first, then a name-token sweep of the pack.
                                    let bundle = mp
                                        .entry_containing(entry.file_off)
                                        .map(|e| mp.slice(&e).to_vec())
                                        .unwrap_or_default();
                                    let mut packs: Vec<&pack::Megapack> = vec![mp];
                                    if let Some(pal) = &palettes {
                                        packs.push(pal);
                                    }
                                    assets = resolve::texture_pool_for(&packs, &lm.name, &bundle);
                                    submesh_tex =
                                        resolve::autoseed_generic(submeshes.len(), &assets);
                                    for (i, slot) in submesh_tex.iter().enumerate() {
                                        if let Some(ai) = slot {
                                            if let Ok(t) = assets[*ai].decode() {
                                                renderer.set_submesh_texture(i, &t);
                                            }
                                        }
                                    }
                                    let (c, r) = bounds(&lm.mesh);
                                    camera = OrbitCamera::framing(c, r);
                                    // The clip catalog is authored against the startup rig.
                                    current = None;
                                    playback.time = 0.0;
                                    model_name = lm.name.clone();
                                    load_status = Some((
                                        format!(
                                            "{}: {} tris, {nbones} bones, {} textures",
                                            lm.name,
                                            mesh_stats.1,
                                            assets.len()
                                        ),
                                        false,
                                    ));
                                    println!(
                                        "[sab_workshop] loaded {}: {} verts, {} tris, {nbones} bones, {} submeshes, {} textures",
                                        lm.name,
                                        mesh_stats.0,
                                        mesh_stats.1,
                                        submeshes.len(),
                                        assets.len()
                                    );
                                }
                                Err(e) => {
                                    // Most pack entries are STATIC props; the MESH reader we ported
                                    // from sab_mesh only handles skinned meshes, so say so in the UI
                                    // rather than appearing to ignore the click.
                                    eprintln!("[sab_workshop] load {}: {e}", entry.name);
                                    load_status = Some((format!("{}: {e}", entry.name), true));
                                }
                            }
                        }
                    }

                    // --- act on a Materials picker change: rebind + persist the sidecar ---
                    if let Some((i, ai)) = pending_tex.take() {
                        match ai {
                            Some(ai) => match assets[ai].decode() {
                                Ok(tex) => renderer.set_submesh_texture(i, &tex),
                                Err(e) => eprintln!("[sab_workshop] decode {}: {e}", assets[ai].name),
                            },
                            None => renderer.clear_submesh_texture(i),
                        }
                        submesh_tex[i] = ai;
                        match resolve::save_sidecar(&cfg.mesh, &submesh_tex, &assets) {
                            Ok(()) => println!(
                                "[sab_workshop] submesh {i} -> {} (saved {})",
                                ai.map(|x| assets[x].name.as_str()).unwrap_or("(none)"),
                                resolve::sidecar_path(&cfg.mesh)
                            ),
                            Err(e) => eprintln!("[sab_workshop] sidecar save failed: {e}"),
                        }
                    }

                    // --- act on a clip request ---
                    if let Some(ci) = pending_load.take() {
                        match load_clip(&pack, &catalog, ci) {
                            Ok(c) => {
                                println!(
                                    "[sab_workshop] loaded clip '{}' ({} tracks, {} frames, {:.3}s)",
                                    c.name, c.anim.num_transform_tracks, c.frame_count, c.duration
                                );
                                current = Some(c);
                                playback.time = 0.0;
                                playback.playing = true;
                            }
                            Err(e) => {
                                eprintln!("[sab_workshop] load clip failed: {e}");
                            }
                        }
                    }

                    match renderer.render(&mut gui) {
                        Ok(()) => {}
                        Err(wgpu::SurfaceError::OutOfMemory) => elwt.exit(),
                        Err(e) => eprintln!("[sab_workshop] surface error: {e:?}"),
                    }
                }
                _ => {}
            }
        }
        _ => {}
    });
    if let Err(e) = result {
        eprintln!("[sab_workshop] event loop error: {e}");
    }
}

/// Headless self-test: load assets, decode the N-th playable clip, run skinning over a few
/// frames, and print sanity stats. Returns a process exit code. Exercises the whole
/// load -> decode -> skin path without opening a window.
pub fn selftest(cfg: Config, n: usize) -> i32 {
    let mesh = match std::fs::read(&cfg.mesh).map_err(|e| e.to_string()).and_then(|b| formats::read_smsh(&b)) {
        Ok(m) => m,
        Err(e) => { eprintln!("selftest: mesh: {e}"); return 1; }
    };
    let skel = match std::fs::read_to_string(&cfg.skel) {
        Ok(t) => formats::read_skel(&t),
        Err(e) => { eprintln!("selftest: skel: {e}"); return 1; }
    };
    let catalog = match anim_index::load(&cfg.index) {
        Ok(c) => c,
        Err(e) => { eprintln!("selftest: index: {e}"); return 1; }
    };
    let pack = match PackData::load(&cfg.pack) {
        Ok(p) => Some(p),
        Err(e) => { eprintln!("selftest: pack: {e}"); return 1; }
    };
    println!(
        "selftest: mesh {} verts / {} tris, skeleton {} bones, catalog {} clips",
        mesh.positions.len(), mesh.indices.len() / 3, skel.len(), catalog.clips.len()
    );

    // Max joint index referenced by the mesh — must be < bone count for skinning to be valid.
    let max_joint = mesh.joints.iter().flat_map(|j| j.iter()).copied().max().unwrap_or(0);
    println!("selftest: max mesh joint index = {max_joint} (skeleton has {} bones)", skel.len());

    // Bind-pose joint matrices: each should be ~identity if inv_bind is consistent.
    let bind = skinning::bind_pose(&skel);
    let mut worst = 0f32;
    for m in &bind {
        let d = *m - glam::Mat4::IDENTITY;
        for c in d.to_cols_array() { worst = worst.max(c.abs()); }
    }
    println!("selftest: bind-pose max deviation of jointMatrix from identity = {worst:.5} (expect ~0)");

    let playable: Vec<usize> = catalog.clips.iter().enumerate().filter(|(_, c)| c.playable).map(|(i, _)| i).collect();
    let ci = *playable.get(n).unwrap_or(&0);
    let clip = match load_clip(&pack, &catalog, ci) {
        Ok(c) => c,
        Err(e) => { eprintln!("selftest: load clip: {e}"); return 1; }
    };
    println!(
        "selftest: clip '{}' — {} tracks, {} frames, {:.3}s, frameDur {:.5}",
        clip.name, clip.anim.num_transform_tracks, clip.frame_count, clip.duration, clip.frame_duration
    );
    let pk = pack.as_ref().unwrap();
    let mut max_disp = 0f32;
    let steps = clip.frame_count.min(8).max(1);
    for f in 0..steps {
        let t = f as f32 * clip.duration / steps as f32;
        let pose = clip.anim.sample_at(pk.blob(), t);
        // Root locked: otherwise this measures root TRAVEL (metres), not pose error.
        let mats = skinning::posed(&skel, &pose, &clip.track_to_bone, true);
        // How far a unit vertex at each bone origin moves vs bind — a coarse "is it animating" probe.
        for (m, b) in mats.iter().zip(&bind) {
            let d = m.w_axis - b.w_axis;
            max_disp = max_disp.max(d.truncate().length());
        }
        if mats.len() != skel.len() { eprintln!("selftest: joint count mismatch!"); return 1; }
    }
    println!("selftest: sampled {steps} frames, max joint-origin displacement vs bind = {max_disp:.4} m");

    // DIAGNOSTIC: how many tracks does the clip actually store translation for? Havok animates most
    // bones by ROTATION only, leaving translation absent = "keep the reference pose". If the decoder
    // hands back (0,0,0) for those, every such bone collapses onto its parent's origin.
    {
        let pose0 = clip.anim.sample_at(pk.blob(), 0.0);
        let zero_t = pose0.iter().filter(|q| q.t[0] == 0.0 && q.t[1] == 0.0 && q.t[2] == 0.0).count();
        let ident_r = pose0
            .iter()
            .filter(|q| q.r[0] == 0.0 && q.r[1] == 0.0 && q.r[2] == 0.0 && q.r[3] == 1.0)
            .count();
        println!(
            "selftest: at t=0 of {} tracks -> {} have translation exactly (0,0,0), {} have identity rotation",
            pose0.len(),
            zero_t,
            ident_r
        );
        // What SHOULD those bones' translations be? Compare against the rig's bind locals.
        let mut nonzero_bind = 0;
        for (k, q) in pose0.iter().enumerate() {
            let bone = clip.track_to_bone.get(k).copied().unwrap_or(-1);
            if bone < 0 || bone as usize >= skel.len() {
                continue;
            }
            let bt = skel[bone as usize].t;
            let bind_len = (bt[0] * bt[0] + bt[1] * bt[1] + bt[2] * bt[2]).sqrt();
            if q.t[0] == 0.0 && q.t[1] == 0.0 && q.t[2] == 0.0 && bind_len > 1e-4 {
                nonzero_bind += 1;
            }
        }
        println!(
            "selftest: {} of those zero-translation tracks drive a bone whose BIND translation is non-zero",
            nonzero_bind
        );
        // Compare decoded values against the rig's bind locals: at t=0 a sane clip should sit near
        // the bind pose in scale/order-of-magnitude, and quats must be unit.
        println!("selftest: track -> bone | decoded t | bind t | |q| | decoded s");
        for (k, q) in pose0.iter().enumerate().take(8) {
            let bone = clip.track_to_bone.get(k).copied().unwrap_or(-1);
            let (bt, nm) = if bone >= 0 && (bone as usize) < skel.len() {
                (skel[bone as usize].t, skel[bone as usize].name.clone())
            } else {
                ([0.0; 3], "(unbound)".into())
            };
            let qn = (q.r[0] * q.r[0] + q.r[1] * q.r[1] + q.r[2] * q.r[2] + q.r[3] * q.r[3]).sqrt();
            println!(
                "  {k:2} -> {bone:3} {nm:22} t=({:8.3},{:8.3},{:8.3}) bind=({:8.3},{:8.3},{:8.3}) |q|={qn:.3} s=({:.2},{:.2},{:.2})",
                q.t[0], q.t[1], q.t[2], bt[0], bt[1], bt[2], q.s[0], q.s[1], q.s[2]
            );
        }
        // Magnitude sweep: how far do decoded translations stray from bind across all tracks?
        let mut worst = (0usize, 0f32);
        for (k, q) in pose0.iter().enumerate() {
            let bone = clip.track_to_bone.get(k).copied().unwrap_or(-1);
            if bone < 0 || bone as usize >= skel.len() {
                continue;
            }
            let bt = skel[bone as usize].t;
            let d = ((q.t[0] - bt[0]).powi(2) + (q.t[1] - bt[1]).powi(2) + (q.t[2] - bt[2]).powi(2)).sqrt();
            if d > worst.1 {
                worst = (k, d);
            }
        }
        println!(
            "selftest: worst |decoded_t - bind_t| = {:.3} m at track {} (a rotation-only rig should be ~0)",
            worst.1, worst.0
        );
        // track -> bone mapping sanity: in range? duplicated? how much of the rig is driven?
        let n_tracks = clip.anim.num_transform_tracks;
        let map = &clip.track_to_bone;
        let unbound = map.iter().take(n_tracks).filter(|&&b| b < 0).count();
        let oob = map.iter().take(n_tracks).filter(|&&b| b >= skel.len() as i32).count();
        let mut seen = std::collections::HashSet::new();
        let dupes = map
            .iter()
            .take(n_tracks)
            .filter(|&&b| b >= 0 && !seen.insert(b))
            .count();
        println!(
            "selftest: track_to_bone: len={} tracks={} unbound={} out_of_range={} duplicate_targets={} distinct_bones={} / {} rig bones",
            map.len(), n_tracks, unbound, oob, dupes, seen.len(), skel.len()
        );
        // Which bones are NOT driven? They keep their bind local (correct), but if a driven bone's
        // PARENT is undriven-but-should-be, the pose tears.
        println!(
            "selftest: {} rig bones have no track (they hold bind local)",
            skel.len() - seen.len()
        );
    }

    // Texture pipeline (no GPU): submesh cover + in-app resolve + auto-seed.
    let cover = formats::submesh_cover(&mesh.prims, mesh.indices.len() as u32);
    println!("selftest: submesh cover = {} draw ranges", cover.len());
    match resolve::load_character_textures(&cfg.megapack, &cfg.char_token) {
        Ok(assets) => {
            let diffuse = assets.iter().filter(|a| a.role == resolve::Role::Diffuse).count();
            let seed = resolve::autoseed(&cfg.mesh, &cover, &assets);
            let applied = seed.iter().filter(|a| a.is_some()).count();
            println!("selftest: resolved {} textures ({diffuse} diffuse); auto-seeded {applied}/{} submeshes", assets.len(), cover.len());
            for (i, a) in seed.iter().enumerate() {
                let tex = a.map(|ai| assets[ai].name.as_str()).unwrap_or("(none)");
                println!(
                    "  submesh {i:2} [{:6}..{:6}] -> {tex}",
                    cover[i].index_start,
                    cover[i].index_start + cover[i].index_count
                );
            }
        }
        Err(e) => println!("selftest: textures unavailable ({e})"),
    }
    println!("selftest: OK");
    0
}

/// Sweep many clips and report which ones decode to an insane pose — the fast way to tell a
/// systemic decoder bug from one confined to a specific path (multi-block, a rarer rotation
/// quantization, …). A track's translation should stay near its bone's BIND translation; only a
/// root-motion bone legitimately travels.
pub fn anim_sweep(cfg: Config, limit: usize) -> i32 {
    let skel = match std::fs::read_to_string(&cfg.skel) {
        Ok(t) => formats::read_skel(&t),
        Err(e) => { eprintln!("sweep: skel: {e}"); return 1; }
    };
    let catalog = match anim_index::load(&cfg.index) {
        Ok(c) => c,
        Err(e) => { eprintln!("sweep: index: {e}"); return 1; }
    };
    let pack = match PackData::load(&cfg.pack) {
        Ok(p) => Some(p),
        Err(e) => { eprintln!("sweep: pack: {e}"); return 1; }
    };
    let pk = pack.as_ref().unwrap();
    let playable: Vec<usize> =
        catalog.clips.iter().enumerate().filter(|(_, c)| c.playable).map(|(i, _)| i).collect();
    let n = limit.min(playable.len());
    println!("sweep: checking {n} clips (bad = a NON-root-chain limb bone >0.75 m from its bind local translation)");
    let (mut bad, mut multi_block_bad, mut single_block_bad) = (0usize, 0usize, 0usize);
    let mut by_blocks: std::collections::BTreeMap<usize, (usize, usize)> = Default::default();
    let mut ctrl_tally: std::collections::BTreeMap<String, (usize, usize)> = Default::default();
    let mut max_scale_dev = (String::new(), 0f32);
    let (mut tot_nonfinite, mut tot_nonunit) = (0usize, 0usize);
    for &ci in playable.iter().take(n) {
        let clip = match load_clip(&pack, &catalog, ci) { Ok(c) => c, Err(_) => continue };
        let nb = clip.anim.num_blocks;
        let mut worst = 0f32;
        let mut worst_bone = (-1i32, String::new(), 0f32);
        let mut worst_scale = 0f32;
        let mut nonfinite = 0usize;
        let mut nonunit = 0usize;
        for f in 0..4 {
            let t = f as f32 * clip.duration / 4.0;
            let pose = clip.anim.sample_at(pk.blob(), t);
            for (k, q) in pose.iter().enumerate() {
                let bone = clip.track_to_bone.get(k).copied().unwrap_or(-1);
                if bone < 0 || bone as usize >= skel.len() {
                    continue;
                }
                // The root chain (GlobalSRT / Bone_Root / Bone_Hips) LEGITIMATELY translates —
                // climbing/hanging/getup clips move the body metres. A LIMB bone's local
                // translation is its fixed bone length, so any drift there is a decode fault.
                let nm = skel[bone as usize].name.to_ascii_lowercase();
                let is_root_chain = nm.contains("globalsrt") || nm.contains("bone_root") || nm.contains("hips");
                if is_root_chain { continue; }
                let bt = skel[bone as usize].t;
                let d = ((q.t[0]-bt[0]).powi(2) + (q.t[1]-bt[1]).powi(2) + (q.t[2]-bt[2]).powi(2)).sqrt();
                if d > worst { worst = d; worst_bone = (bone, skel[bone as usize].name.clone(), d); }
            }
            // SCALE check: the memory/decomp says the corpus is uniformly ctrl=0x45 with scale == 1.
            // A bad scale is the only channel that can STRETCH geometry (rotations can't), so this is
            // the prime suspect for the shredded mesh.
            for q in pose.iter() {
                for c in 0..3 {
                    let dev = (q.s[c] - 1.0).abs();
                    if dev > worst_scale { worst_scale = dev; }
                }
                if !q.s[0].is_finite() || !q.s[1].is_finite() || !q.s[2].is_finite() { nonfinite += 1; }
                if !q.t[0].is_finite() || !q.t[1].is_finite() || !q.t[2].is_finite() { nonfinite += 1; }
                let qn = (q.r[0]*q.r[0]+q.r[1]*q.r[1]+q.r[2]*q.r[2]+q.r[3]*q.r[3]).sqrt();
                if (qn - 1.0).abs() > 1e-3 { nonunit += 1; }
            }
        }
        let e = by_blocks.entry(nb).or_insert((0, 0));
        e.0 += 1;
        // Which quantization paths does this clip use? Corpus was reported uniformly ctrl=0x45.
        let masks = clip.anim.track_masks(pk.blob(), 0);
        let mut ctrls: Vec<u8> = masks.iter().map(|m| m[0]).collect();
        ctrls.sort_unstable();
        ctrls.dedup();
        let ctrl_str = ctrls.iter().map(|c| format!("{c:#04x}")).collect::<Vec<_>>().join(",");
        let te = ctrl_tally.entry(ctrl_str.clone()).or_insert((0usize, 0usize));
        te.0 += 1;
        if worst > 0.75 { te.1 += 1; }
        if worst_scale > max_scale_dev.1 { max_scale_dev = (clip.name.clone(), worst_scale); }
        tot_nonfinite += nonfinite;
        tot_nonunit += nonunit;
        if worst > 0.75 {
            bad += 1;
            e.1 += 1;
            if nb > 1 { multi_block_bad += 1 } else { single_block_bad += 1 }
            if bad <= 8 {
                println!(
                    "  BAD {:<38} frames={} worst={:.2} m on bone {} '{}'",
                    clip.name, clip.frame_count, worst, worst_bone.0, worst_bone.1
                );
            }
        }
    }
    println!("sweep: {bad}/{n} bad  (single-block bad: {single_block_bad}, multi-block bad: {multi_block_bad})");
    println!("sweep: worst |scale-1| = {:.4} in '{}'  (corpus should be scale==1)", max_scale_dev.1, max_scale_dev.0);
    println!("sweep: non-finite components: {tot_nonfinite}   non-unit quaternions: {tot_nonunit}");
    println!("sweep: by ctrl-byte set -> (checked, bad):");
    for (c, (tot, b)) in &ctrl_tally {
        println!("   ctrl={{{c}}}  checked={tot:<5} bad={b}");
    }
    println!("sweep: by num_blocks -> (checked, bad):");
    for (nb, (tot, b)) in by_blocks {
        println!("   blocks={nb:<3} checked={tot:<5} bad={b}");
    }
    0
}

/// Decode the requested clip. `ci` indexes `catalog.clips`.
fn load_clip(pack: &Option<PackData>, catalog: &AnimCatalog, ci: usize) -> Result<LoadedClip, String> {
    let pk = pack.as_ref().ok_or("no Animations.pack loaded")?;
    let clip = catalog.clips.get(ci).ok_or("clip index out of range")?;
    let n = clip.index;
    if n >= pk.scas.len() {
        return Err(format!("clip #{n} beyond pack ({} spline anims)", pk.scas.len()));
    }
    // Re-parse the packfile (cheap; only needed to resolve the object's hkArrays).
    let blob = pk.blob();
    let packfile = Packfile::parse(blob)?;
    let anim = havok::read_spline_anim(&packfile, pk.scas[n]);
    let frame_count = anim.num_frames.max(1);
    let frame_duration = if anim.frame_duration.is_finite() && anim.frame_duration > 0.0 {
        anim.frame_duration
    } else {
        1.0 / 30.0
    };
    let duration = if clip.duration > 0.0 { clip.duration } else { anim.duration };
    Ok(LoadedClip {
        anim,
        track_to_bone: clip.track_to_bone.clone(),
        name: clip.name.clone(),
        duration,
        frame_duration,
        frame_count,
    })
}

/// Axis-aligned bounding sphere (center of bbox + half-diagonal) of the mesh.
fn bounds(mesh: &Smsh) -> (Vec3, f32) {
    if mesh.positions.is_empty() {
        return (Vec3::ZERO, 1.0);
    }
    let mut lo = Vec3::splat(f32::MAX);
    let mut hi = Vec3::splat(f32::MIN);
    for p in &mesh.positions {
        let v = Vec3::from_array(*p);
        lo = lo.min(v);
        hi = hi.max(v);
    }
    let center = (lo + hi) * 0.5;
    let radius = (hi - lo).length() * 0.5;
    (center, radius.max(0.1))
}

/// Which category the navigator is browsing. The mercs2 workshop's navigator is the asset browser
/// (every model + texture in the pack); animations are sab's third category.
#[derive(Clone, Copy, PartialEq, Eq)]
enum NavTab {
    Models,
    Textures,
    Animations,
}

impl NavTab {
    const ALL: [NavTab; 3] = [NavTab::Models, NavTab::Textures, NavTab::Animations];
    fn label(self) -> &'static str {
        match self {
            NavTab::Models => "models",
            NavTab::Textures => "textures",
            NavTab::Animations => "anims",
        }
    }
}

/// The Materials panel's borrowed state: the draw list, the resolved texture pool, the current
/// assignment, and the out-param a picker click writes to.
struct MatsCtx<'a> {
    submeshes: &'a [SubMesh],
    assets: &'a [resolve::TexAsset],
    submesh_tex: &'a [Option<usize>],
    pending_tex: &'a mut Option<(usize, Option<usize>)>,
}

/// The navigator's borrowed state: the browsable catalogs + the click out-params.
struct NavCtx<'a> {
    tab: &'a mut NavTab,
    search: &'a mut String,
    models: &'a [meshload::MeshEntry],
    assets: &'a [resolve::TexAsset],
    pending_model: &'a mut Option<usize>,
    /// Loaded model's name, so the browser can mark the active row.
    current_model: &'a str,
}

#[allow(clippy::too_many_arguments)]
fn build_ui(
    ctx: &egui::Context,
    catalog: &AnimCatalog,
    playable_rows: &[usize],
    show_all: &mut bool,
    current: &Option<LoadedClip>,
    playback: &mut Playback,
    pending_load: &mut Option<usize>,
    show_grid: &mut bool,
    show_textures: &mut bool,
    lock_root: &mut bool,
    errors: &[String],
    have_pack: bool,
    rig_ok: bool,
    mesh_stats: (usize, usize, usize), // verts, tris, bones
    model_name: &str,
    load_status: &Option<(String, bool)>,
    mats: &mut MatsCtx,
    nav: &mut NavCtx,
) {
    // ── COMMAND BAR ──
    egui::TopBottomPanel::top("cmdbar").show(ctx, |ui| {
        ui.add_space(3.0);
        ui.horizontal(|ui| {
            theme::brand_mark(ui);
            ui.add_space(2.0);
            ui.label(theme::disp_text("SAB WORKSHOP", 15.0, theme::TX));
            ui.label(theme::disp_text("ASSET WORKBENCH", 10.0, theme::FAINT));
            ui.separator();
            ui.label(theme::disp_text(model_name, 12.0, theme::BRASS));
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                theme::chip(ui, "orbit", true, None);
                theme::chip(
                    ui,
                    if *show_textures { "textured" } else { "untextured" },
                    *show_textures,
                    None,
                );
            });
        });
        ui.add_space(3.0);
    });

    // Non-fatal load failures — visible but non-blocking.
    if !errors.is_empty() {
        egui::TopBottomPanel::top("errors").show(ctx, |ui| {
            for e in errors {
                ui.colored_label(theme::HAZARD, format!("load warning: {e}"));
            }
        });
    }

    // ── STATUS BAR ──
    egui::TopBottomPanel::bottom("status").show(ctx, |ui| {
        ui.add_space(2.0);
        ui.horizontal(|ui| {
            let (ok, msg) = if have_pack { (theme::GOOD, "ready") } else { (theme::HAZARD, "no pack") };
            theme::status_dot(ui, msg, ok);
            ui.separator();
            ui.label(theme::disp_text(
                format!("{} verts · {} tris · {} bones", mesh_stats.0, mesh_stats.1, mesh_stats.2),
                9.5,
                theme::DIM,
            ));
            ui.separator();
            let textured = mats.submesh_tex.iter().filter(|s| s.is_some()).count();
            ui.label(theme::disp_text(
                format!("{textured}/{} submeshes textured", mats.submeshes.len()),
                9.5,
                theme::DIM,
            ));
            if let Some((msg, is_err)) = load_status {
                ui.separator();
                ui.label(
                    egui::RichText::new(msg)
                        .size(10.5)
                        .color(if *is_err { theme::HAZARD } else { theme::GOOD }),
                );
            }
        });
        ui.add_space(2.0);
    });

    // ── TRANSPORT ──
    egui::TopBottomPanel::bottom("transport").show(ctx, |ui| {
        ui.add_space(4.0);
        match current {
            None => {
                ui.label(
                    egui::RichText::new("No clip loaded — pick one from the navigator. Showing bind pose.")
                        .color(theme::DIM),
                );
            }
            Some(clip) => {
                ui.horizontal(|ui| {
                    ui.label(theme::disp_text(&clip.name, 12.0, theme::BRASS));
                    ui.separator();
                    let frame = if clip.frame_duration > 0.0 {
                        (playback.time / clip.frame_duration).round() as i64
                    } else {
                        0
                    };
                    ui.label(
                        egui::RichText::new(format!(
                            "{:.3}s · {} frames · frame {}/{}",
                            clip.duration,
                            clip.frame_count,
                            frame.max(0),
                            clip.frame_count.saturating_sub(1)
                        ))
                        .monospace()
                        .size(11.0)
                        .color(theme::DIM),
                    );
                });
                ui.horizontal(|ui| {
                    if theme::primary_button(ui, if playback.playing { "⏸ Pause" } else { "▶ Play" }, true).clicked() {
                        playback.playing = !playback.playing;
                    }
                    if theme::pill(ui, "loop", playback.looping).clicked() {
                        playback.looping = !playback.looping;
                    }
                    if theme::pill(ui, "grid", *show_grid).clicked() {
                        *show_grid = !*show_grid;
                    }
                    if theme::pill(ui, "textures", *show_textures).clicked() {
                        *show_textures = !*show_textures;
                    }
                    if theme::pill(ui, "lock root", *lock_root).clicked() {
                        *lock_root = !*lock_root;
                    }
                    ui.separator();
                    ui.label(egui::RichText::new("speed").color(theme::DIM).size(11.0));
                    ui.add(egui::Slider::new(&mut playback.speed, 0.0..=3.0).fixed_decimals(2));
                    if ui.button("Reset").clicked() {
                        playback.time = 0.0;
                    }
                });
                let dur = clip.duration.max(0.0001);
                let mut t = playback.time.clamp(0.0, dur);
                if ui
                    .add(egui::Slider::new(&mut t, 0.0..=dur).text("time (s)").fixed_decimals(3))
                    .changed()
                {
                    playback.time = t;
                    playback.playing = false; // scrubbing pauses
                }
            }
        }
        ui.add_space(4.0);
    });

    // ── NAVIGATOR (left): the clip list ──
    egui::SidePanel::left("navigator")
        .resizable(true)
        .default_width(300.0)
        // Hard clamp: a resizable panel sizes to its content's minimum, so ANY row whose width is
        // derived from `available_width()` can feed back and walk the panel across the screen. The
        // rows below are feedback-free, but this bounds the blast radius of a future one.
        .width_range(240.0..=460.0)
        .show(ctx, |ui| {
            theme::eyebrow(ui, "Browser");
            ui.add_space(4.0);
            // Category selector — the navigator browses the PACK, not just clips.
            ui.horizontal(|ui| {
                for t in NavTab::ALL {
                    if theme::pill(ui, t.label(), *nav.tab == t).clicked() {
                        *nav.tab = t;
                    }
                }
            });
            ui.horizontal(|ui| {
                // Right-to-left: the ✕ is placed first (at the right), then the field fills EXACTLY
                // the remainder — so total content == available. Sizing the field from
                // `available_width() - k` and then adding the button overflows by (button - k) every
                // frame, which is what made this panel creep rightward.
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    if ui.button("✕").clicked() {
                        nav.search.clear();
                    }
                    ui.add_sized(
                        [ui.available_width(), 20.0],
                        egui::TextEdit::singleline(nav.search).hint_text("filter by name"),
                    );
                });
            });
            let needle = nav.search.to_ascii_lowercase();
            ui.add_space(2.0);

            match *nav.tab {
                NavTab::Models => {
                    let rows: Vec<usize> = nav
                        .models
                        .iter()
                        .enumerate()
                        .filter(|(_, m)| needle.is_empty() || m.name.to_ascii_lowercase().contains(&needle))
                        .map(|(i, _)| i)
                        .collect();
                    ui.label(theme::disp_text(
                        format!("{} of {} model(s)", rows.len(), nav.models.len()),
                        9.5,
                        theme::FAINT,
                    ));
                    ui.separator();
                    ui.add_space(4.0);
                    egui::ScrollArea::vertical().auto_shrink([false, false]).show_rows(
                        ui,
                        18.0,
                        rows.len(),
                        |ui, range| {
                            for r in range {
                                let i = rows[r];
                                let m = &nav.models[i];
                                let sel = m.name.eq_ignore_ascii_case(nav.current_model);
                                if ui.selectable_label(sel, &m.name).clicked() {
                                    *nav.pending_model = Some(i);
                                }
                            }
                        },
                    );
                }
                NavTab::Textures => {
                    let rows: Vec<usize> = nav
                        .assets
                        .iter()
                        .enumerate()
                        .filter(|(_, a)| needle.is_empty() || a.name.to_ascii_lowercase().contains(&needle))
                        .map(|(i, _)| i)
                        .collect();
                    ui.label(theme::disp_text(
                        format!("{} of {} texture(s) — this asset's bundle", rows.len(), nav.assets.len()),
                        9.5,
                        theme::FAINT,
                    ));
                    ui.separator();
                    ui.add_space(4.0);
                    egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
                        for r in rows {
                            let a = &nav.assets[r];
                            ui.horizontal(|ui| {
                                ui.label(egui::RichText::new(&a.name).size(11.5));
                                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                                    ui.label(
                                        egui::RichText::new(format!("{}x{} {}", a.width, a.height, a.role.label()))
                                            .monospace()
                                            .size(9.0)
                                            .color(theme::FAINT),
                                    );
                                });
                            });
                        }
                    });
                }
                NavTab::Animations => {
                    if theme::pill(ui, "show all (incl. non-rig)", *show_all).clicked() {
                        *show_all = !*show_all;
                    }
                    let rows: Vec<usize> = if *show_all {
                        (0..catalog.clips.len()).collect()
                    } else {
                        playable_rows.to_vec()
                    };
                    let matches: Vec<usize> = rows
                        .into_iter()
                        .filter(|&i| {
                            needle.is_empty() || catalog.clips[i].name.to_ascii_lowercase().contains(&needle)
                        })
                        .collect();
                    ui.label(theme::disp_text(format!("{} clip(s)", matches.len()), 9.5, theme::FAINT));
                    if !have_pack {
                        ui.colored_label(theme::HAZARD, "Animations.pack not loaded — bind pose only.");
                    }
                    if !rig_ok {
                        ui.colored_label(
                            theme::HAZARD,
                            "Loaded model's rig differs from the clip catalog — clips disabled.",
                        );
                    }
                    ui.separator();
                    ui.add_space(4.0);
                    let cur_name = current.as_ref().map(|c| c.name.clone());
                    egui::ScrollArea::vertical().auto_shrink([false, false]).show_rows(
                        ui,
                        18.0,
                        matches.len(),
                        |ui, range| {
                            for r in range {
                                let i = matches[r];
                                let c = &catalog.clips[i];
                                let selected = cur_name.as_deref() == Some(c.name.as_str());
                                let label = if c.playable {
                                    c.name.clone()
                                } else {
                                    format!("{}  (non-rig)", c.name)
                                };
                                if ui.add_enabled(rig_ok, egui::SelectableLabel::new(selected, label)).clicked() {
                                    *pending_load = Some(i);
                                }
                            }
                        },
                    );
                }
            }
        });

    // ── INSPECTOR (right): character + materials + clip ──
    egui::SidePanel::right("inspector")
        .resizable(true)
        .default_width(340.0)
        .width_range(280.0..=460.0) // see the navigator's note on content-width feedback
        .show(ctx, |ui| {
            egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
                theme::card(ui, "Character", None, |ui| {
                    theme::kv(ui, "vertices", egui::RichText::new(mesh_stats.0.to_string()));
                    theme::kv(ui, "triangles", egui::RichText::new(mesh_stats.1.to_string()));
                    theme::kv(ui, "bones", egui::RichText::new(mesh_stats.2.to_string()));
                    theme::kv(ui, "clips", egui::RichText::new(catalog.clips.len().to_string()));
                });

                let textured = mats.submesh_tex.iter().filter(|s| s.is_some()).count();
                let badge = format!("{textured}/{}", mats.submeshes.len());
                theme::section(ui, "Materials", Some(&badge), true, |ui| {
                    if mats.assets.is_empty() {
                        ui.colored_label(theme::HAZARD, "No textures resolved — check --megapack / --char.");
                        return;
                    }
                    ui.label(
                        egui::RichText::new(
                            "Auto-seeded by body part. WSAO (which would name each material) isn't in \
                             the PC build, so fix any wrong slot here — saved next to the mesh.",
                        )
                        .color(theme::FAINT)
                        .size(10.5),
                    );
                    ui.add_space(6.0);
                    for (i, sm) in mats.submeshes.iter().enumerate() {
                        let assigned = mats.submesh_tex[i];
                        let cur = assigned.map(|ai| mats.assets[ai].name.as_str()).unwrap_or("(none)");
                        let (fill, border) = if assigned.is_some() {
                            (theme::BRASS_SOFT, theme::BRASS_DK)
                        } else {
                            (theme::G0, theme::LINE)
                        };
                        theme::row_chip(ui, fill, border, |ui| {
                            ui.vertical(|ui| {
                                ui.horizontal(|ui| {
                                    ui.label(theme::disp_text(format!("{i:02}"), 10.0, theme::BRASS));
                                    ui.label(
                                        egui::RichText::new(format!("{} tris", sm.index_count / 3))
                                            .monospace()
                                            .size(10.0)
                                            .color(theme::DIM),
                                    );
                                    // The prim's material hashes — what WSAO would have resolved.
                                    let hashes: Vec<String> =
                                        sm.materials.iter().map(|m| format!("{m:08X}")).collect();
                                    ui.label(
                                        egui::RichText::new(hashes.join(" "))
                                            .monospace()
                                            .size(9.0)
                                            .color(theme::FAINT),
                                    )
                                    .on_hover_text("prim material hashes (pandemic_hash of a WSAO material name)");
                                });
                                egui::ComboBox::from_id_source(("texpick", i))
                                    .selected_text(egui::RichText::new(cur).size(11.0))
                                    // Never wider than what's actually available (a `.max(k)` floor
                                    // here would overflow the row and creep the panel — see above).
                                    .width((ui.available_width() - 8.0).max(0.0))
                                    .show_ui(ui, |ui| {
                                        if ui.selectable_label(assigned.is_none(), "(none)").clicked() {
                                            *mats.pending_tex = Some((i, None));
                                        }
                                        for (ai, a) in mats.assets.iter().enumerate() {
                                            let lbl = format!("{}  · {}", a.name, a.role.label());
                                            if ui.selectable_label(assigned == Some(ai), lbl).clicked() {
                                                *mats.pending_tex = Some((i, Some(ai)));
                                            }
                                        }
                                    });
                                if let Some(ai) = assigned {
                                    let a = &mats.assets[ai];
                                    ui.label(
                                        egui::RichText::new(format!(
                                            "{}x{} · {} · {}",
                                            a.width,
                                            a.height,
                                            a.format,
                                            a.role.label()
                                        ))
                                        .monospace()
                                        .size(9.5)
                                        .color(theme::FAINT),
                                    );
                                }
                            });
                        });
                    }
                });

                if let Some(clip) = current {
                    theme::card(ui, "Clip", None, |ui| {
                        theme::kv(ui, "name", egui::RichText::new(&clip.name));
                        theme::kv(ui, "duration", egui::RichText::new(format!("{:.3}s", clip.duration)));
                        theme::kv(ui, "frames", egui::RichText::new(clip.frame_count.to_string()));
                        theme::kv(
                            ui,
                            "tracks",
                            egui::RichText::new(clip.anim.num_transform_tracks.to_string()),
                        );
                    });
                }
            });
        });
}
