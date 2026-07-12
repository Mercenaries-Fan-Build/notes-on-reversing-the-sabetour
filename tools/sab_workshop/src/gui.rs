//! egui host: a hand-rolled winit-0.29 -> egui event bridge plus the egui-wgpu paint path.
//!
//! ADAPTED from the Mercs2 workshop's `gui.rs`. Hand-rolled because `egui-winit` 0.28 targets
//! winit 0.30 while we are on 0.29. Clipboard delivery was dropped (not needed here).

use std::sync::Arc;

use winit::event::{ElementState, KeyEvent, MouseButton, MouseScrollDelta, WindowEvent};
use winit::keyboard::{KeyCode, PhysicalKey};
use winit::window::Window;

pub struct Gui {
    pub ctx: egui::Context,
    renderer: egui_wgpu::Renderer,
    events: Vec<egui::Event>,
    modifiers: egui::Modifiers,
    pointer: egui::Pos2,
    ppp: f32,
    size: [u32; 2],
    jobs: Vec<egui::ClippedPrimitive>,
    tex_delta: egui::TexturesDelta,
    start: std::time::Instant,
}

impl Gui {
    pub fn new(device: &wgpu::Device, format: wgpu::TextureFormat, window: &Arc<Window>) -> Gui {
        let ctx = egui::Context::default();
        let mut style = (*ctx.style()).clone();
        style.visuals = egui::Visuals::dark();
        ctx.set_style(style);
        let size = window.inner_size();
        Gui {
            ctx,
            renderer: egui_wgpu::Renderer::new(device, format, None, 1),
            events: Vec::new(),
            modifiers: egui::Modifiers::default(),
            pointer: egui::Pos2::ZERO,
            ppp: window.scale_factor() as f32,
            size: [size.width, size.height],
            jobs: Vec::new(),
            tex_delta: egui::TexturesDelta::default(),
            start: std::time::Instant::now(),
        }
    }

    /// Feed a winit event. Returns true when egui CONSUMED it (pointer over a panel, text into a
    /// widget) — the caller then skips its own camera/shortcut handling.
    pub fn on_event(&mut self, event: &WindowEvent) -> bool {
        match event {
            WindowEvent::Resized(s) => {
                self.size = [s.width, s.height];
                false
            }
            WindowEvent::ScaleFactorChanged { scale_factor, .. } => {
                self.ppp = *scale_factor as f32;
                false
            }
            WindowEvent::ModifiersChanged(m) => {
                let s = m.state();
                self.modifiers = egui::Modifiers {
                    alt: s.alt_key(),
                    ctrl: s.control_key(),
                    shift: s.shift_key(),
                    mac_cmd: false,
                    command: s.control_key(),
                };
                false
            }
            WindowEvent::CursorMoved { position, .. } => {
                self.pointer = egui::pos2(position.x as f32 / self.ppp, position.y as f32 / self.ppp);
                self.events.push(egui::Event::PointerMoved(self.pointer));
                self.ctx.is_using_pointer()
            }
            WindowEvent::MouseInput { state, button, .. } => {
                let button = match button {
                    MouseButton::Left => egui::PointerButton::Primary,
                    MouseButton::Right => egui::PointerButton::Secondary,
                    MouseButton::Middle => egui::PointerButton::Middle,
                    _ => return false,
                };
                let pressed = *state == ElementState::Pressed;
                self.events.push(egui::Event::PointerButton {
                    pos: self.pointer,
                    button,
                    pressed,
                    modifiers: self.modifiers,
                });
                self.ctx.is_pointer_over_area() || self.ctx.wants_pointer_input()
            }
            WindowEvent::MouseWheel { delta, .. } => {
                let (unit, d) = match delta {
                    MouseScrollDelta::LineDelta(x, y) => {
                        (egui::MouseWheelUnit::Line, egui::vec2(*x, *y))
                    }
                    MouseScrollDelta::PixelDelta(p) => (
                        egui::MouseWheelUnit::Point,
                        egui::vec2(p.x as f32 / self.ppp, p.y as f32 / self.ppp),
                    ),
                };
                self.events.push(egui::Event::MouseWheel { unit, delta: d, modifiers: self.modifiers });
                self.ctx.is_pointer_over_area() || self.ctx.wants_pointer_input()
            }
            WindowEvent::KeyboardInput {
                event: KeyEvent { physical_key: PhysicalKey::Code(code), state, text, repeat, .. },
                ..
            } => {
                if let Some(key) = map_key(*code) {
                    self.events.push(egui::Event::Key {
                        key,
                        physical_key: None,
                        pressed: *state == ElementState::Pressed,
                        repeat: *repeat,
                        modifiers: self.modifiers,
                    });
                }
                if *state == ElementState::Pressed && self.ctx.wants_keyboard_input() {
                    if let Some(t) = text {
                        let printable: String = t.chars().filter(|c| !c.is_control()).collect();
                        if !printable.is_empty() {
                            self.events.push(egui::Event::Text(printable));
                        }
                    }
                }
                self.ctx.wants_keyboard_input()
            }
            _ => false,
        }
    }

    /// Run one GUI frame: `build` lays out the panels; paint jobs are stashed for `paint`.
    pub fn run(&mut self, build: impl FnOnce(&egui::Context)) {
        let screen = egui::Rect::from_min_size(
            egui::Pos2::ZERO,
            egui::vec2(self.size[0] as f32, self.size[1] as f32) / self.ppp,
        );
        let mut raw = egui::RawInput {
            screen_rect: Some(screen),
            time: Some(self.start.elapsed().as_secs_f64()),
            modifiers: self.modifiers,
            events: std::mem::take(&mut self.events),
            focused: true,
            ..Default::default()
        };
        raw.viewports
            .entry(egui::ViewportId::ROOT)
            .or_default()
            .native_pixels_per_point = Some(self.ppp);
        let out = self.ctx.run(raw, build);
        self.jobs = self.ctx.tessellate(out.shapes, out.pixels_per_point);
        self.tex_delta = out.textures_delta;
    }

    /// Paint the last `run` onto the swapchain view (its own render pass, load = keep).
    pub fn paint(
        &mut self,
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        encoder: &mut wgpu::CommandEncoder,
        view: &wgpu::TextureView,
        size: [u32; 2],
    ) {
        for (id, delta) in &self.tex_delta.set {
            self.renderer.update_texture(device, queue, *id, delta);
        }
        let desc = egui_wgpu::ScreenDescriptor { size_in_pixels: size, pixels_per_point: self.ppp };
        self.renderer.update_buffers(device, queue, encoder, &self.jobs, &desc);
        {
            let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("egui pass"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view,
                    resolve_target: None,
                    ops: wgpu::Operations { load: wgpu::LoadOp::Load, store: wgpu::StoreOp::Store },
                })],
                depth_stencil_attachment: None,
                timestamp_writes: None,
                occlusion_query_set: None,
            });
            self.renderer.render(&mut pass, &self.jobs, &desc);
        }
        for id in &self.tex_delta.free {
            self.renderer.free_texture(id);
        }
        self.tex_delta = egui::TexturesDelta::default();
    }
}

fn map_key(code: KeyCode) -> Option<egui::Key> {
    use egui::Key as K;
    Some(match code {
        KeyCode::ArrowUp => K::ArrowUp,
        KeyCode::ArrowDown => K::ArrowDown,
        KeyCode::ArrowLeft => K::ArrowLeft,
        KeyCode::ArrowRight => K::ArrowRight,
        KeyCode::Enter | KeyCode::NumpadEnter => K::Enter,
        KeyCode::Escape => K::Escape,
        KeyCode::Tab => K::Tab,
        KeyCode::Backspace => K::Backspace,
        KeyCode::Delete => K::Delete,
        KeyCode::Space => K::Space,
        KeyCode::Home => K::Home,
        KeyCode::End => K::End,
        KeyCode::PageUp => K::PageUp,
        KeyCode::PageDown => K::PageDown,
        KeyCode::KeyA => K::A,
        KeyCode::KeyC => K::C,
        KeyCode::KeyV => K::V,
        KeyCode::KeyX => K::X,
        KeyCode::KeyZ => K::Z,
        _ => return None,
    })
}
