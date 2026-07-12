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
use crate::formats::{self, Bone, Smsh};
use crate::havok::{self, Packfile, SplineAnim};
use crate::render::Renderer;
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
    let mesh: Smsh = match std::fs::read(&cfg.mesh).map_err(|e| e.to_string()).and_then(|b| formats::read_smsh(&b)) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("[sab_workshop] FATAL: cannot load mesh {}: {e}", cfg.mesh);
            return;
        }
    };
    let skel: Vec<Bone> = match std::fs::read_to_string(&cfg.skel) {
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

    // --- interactive state (all locals, captured by the move closure) ---
    let mut camera = OrbitCamera::framing(center, radius);
    let mut search = String::new();
    let mut show_all = false; // include non-playable clips in the list
    let mut current: Option<LoadedClip> = None;
    let mut playback = Playback { time: 0.0, playing: true, looping: true, speed: 1.0 };
    let mut pending_load: Option<usize> = None; // catalog.clips index requested this frame
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
                        let mats = skinning::posed(&skel, &pose, &clip.track_to_bone);
                        renderer.update_joints(&mats);
                    }

                    renderer.update_camera(camera.view_proj(renderer.aspect()));

                    // --- UI ---
                    gui.run(|ctx| {
                        build_ui(
                            ctx, &catalog, &playable_rows, &mut search, &mut show_all,
                            &current, &mut playback, &mut pending_load, &mut renderer.show_grid,
                            &errors, pack.is_some(),
                        );
                    });

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
        let mats = skinning::posed(&skel, &pose, &clip.track_to_bone);
        // How far a unit vertex at each bone origin moves vs bind — a coarse "is it animating" probe.
        for (m, b) in mats.iter().zip(&bind) {
            let d = m.w_axis - b.w_axis;
            max_disp = max_disp.max(d.truncate().length());
        }
        if mats.len() != skel.len() { eprintln!("selftest: joint count mismatch!"); return 1; }
    }
    println!("selftest: sampled {steps} frames, max joint-origin displacement vs bind = {max_disp:.4} m");
    println!("selftest: OK");
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

#[allow(clippy::too_many_arguments)]
fn build_ui(
    ctx: &egui::Context,
    catalog: &AnimCatalog,
    playable_rows: &[usize],
    search: &mut String,
    show_all: &mut bool,
    current: &Option<LoadedClip>,
    playback: &mut Playback,
    pending_load: &mut Option<usize>,
    show_grid: &mut bool,
    errors: &[String],
    have_pack: bool,
) {
    // Errors banner (non-fatal load failures) — keeps the app running but visible.
    if !errors.is_empty() {
        egui::TopBottomPanel::top("errors").show(ctx, |ui| {
            for e in errors {
                ui.colored_label(egui::Color32::from_rgb(240, 140, 100), format!("load warning: {e}"));
            }
        });
    }

    // Left: searchable clip list.
    egui::SidePanel::left("clips")
        .resizable(true)
        .default_width(300.0)
        .show(ctx, |ui| {
            ui.heading("Animations");
            ui.horizontal(|ui| {
                ui.label("Search:");
                ui.add(egui::TextEdit::singleline(search).hint_text("filter by name"));
                if ui.button("x").clicked() {
                    search.clear();
                }
            });
            ui.checkbox(show_all, "show all (incl. non-rig clips)");

            // Which rows to consider.
            let rows: Vec<usize> = if *show_all {
                (0..catalog.clips.len()).collect()
            } else {
                playable_rows.to_vec()
            };
            let needle = search.to_ascii_lowercase();
            let matches: Vec<usize> = rows
                .into_iter()
                .filter(|&i| needle.is_empty() || catalog.clips[i].name.to_ascii_lowercase().contains(&needle))
                .collect();

            ui.separator();
            ui.label(format!("{} clip(s)", matches.len()));
            if !have_pack {
                ui.colored_label(
                    egui::Color32::from_rgb(240, 180, 90),
                    "Animations.pack not loaded — clips cannot play (bind pose only).",
                );
            }
            ui.separator();

            let cur_name = current.as_ref().map(|c| c.name.clone());
            egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
                for &i in &matches {
                    let c = &catalog.clips[i];
                    let selected = cur_name.as_deref() == Some(c.name.as_str());
                    let label = if c.playable {
                        c.name.clone()
                    } else {
                        format!("{}  (non-rig)", c.name)
                    };
                    if ui.selectable_label(selected, label).clicked() {
                        *pending_load = Some(i);
                    }
                }
            });
        });

    // Bottom: playback controls.
    egui::TopBottomPanel::bottom("playback").show(ctx, |ui| {
        ui.add_space(4.0);
        match current {
            None => {
                ui.label("No clip loaded — pick one from the list. Showing bind pose.");
            }
            Some(clip) => {
                ui.horizontal(|ui| {
                    ui.strong(&clip.name);
                    ui.separator();
                    ui.label(format!("{:.3}s", clip.duration));
                    ui.separator();
                    ui.label(format!("{} frames", clip.frame_count));
                    ui.separator();
                    let frame = if clip.frame_duration > 0.0 {
                        (playback.time / clip.frame_duration).round() as i64
                    } else {
                        0
                    };
                    ui.label(format!("frame {}/{}", frame.max(0), clip.frame_count.saturating_sub(1)));
                });
                ui.horizontal(|ui| {
                    let lbl = if playback.playing { "⏸ Pause" } else { "▶ Play" };
                    if ui.button(lbl).clicked() {
                        playback.playing = !playback.playing;
                    }
                    ui.checkbox(&mut playback.looping, "Loop");
                    ui.label("Speed");
                    ui.add(egui::Slider::new(&mut playback.speed, 0.0..=3.0).fixed_decimals(2));
                    if ui.button("Reset").clicked() {
                        playback.time = 0.0;
                    }
                    ui.separator();
                    ui.checkbox(show_grid, "Grid");
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
}
