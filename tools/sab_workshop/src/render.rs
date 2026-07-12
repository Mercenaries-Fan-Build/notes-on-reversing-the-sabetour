//! wgpu renderer: GPU-skinned mesh (skinning in the vertex shader) + ground grid + depth,
//! all drawn under an egui overlay. wgpu 0.20.

use std::sync::Arc;

use glam::Mat4;
use wgpu::util::DeviceExt;
use winit::window::Window;

use crate::formats::Smsh;
use crate::gui::Gui;

const DEPTH_FORMAT: wgpu::TextureFormat = wgpu::TextureFormat::Depth32Float;

#[repr(C)]
#[derive(Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
struct Vertex {
    pos: [f32; 3],
    normal: [f32; 3],
    joints: [u16; 4],
    weights: [f32; 4],
}

#[repr(C)]
#[derive(Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
struct GridVertex {
    pos: [f32; 3],
    color: [f32; 3],
}

#[repr(C)]
#[derive(Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
struct CameraUniform {
    view_proj: [[f32; 4]; 4],
}

pub struct Renderer {
    surface: wgpu::Surface<'static>,
    device: wgpu::Device,
    queue: wgpu::Queue,
    config: wgpu::SurfaceConfiguration,
    surface_format: wgpu::TextureFormat,

    depth_view: wgpu::TextureView,

    camera_buf: wgpu::Buffer,
    joint_buf: wgpu::Buffer,
    bind_group: wgpu::BindGroup,

    mesh_pipeline: wgpu::RenderPipeline,
    vbo: wgpu::Buffer,
    ibo: wgpu::Buffer,
    index_count: u32,

    grid_pipeline: wgpu::RenderPipeline,
    grid_vbo: wgpu::Buffer,
    grid_count: u32,

    joint_count: usize,
    pub show_grid: bool,
}

impl Renderer {
    pub async fn new(window: Arc<Window>, mesh: &Smsh, joint_count: usize) -> Result<Renderer, String> {
        let size = window.inner_size();
        let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
            backends: wgpu::Backends::PRIMARY,
            ..Default::default()
        });
        let surface = instance
            .create_surface(window.clone())
            .map_err(|e| format!("create_surface: {e}"))?;
        let adapter = instance
            .request_adapter(&wgpu::RequestAdapterOptions {
                power_preference: wgpu::PowerPreference::HighPerformance,
                compatible_surface: Some(&surface),
                force_fallback_adapter: false,
            })
            .await
            .ok_or("no suitable GPU adapter")?;
        let (device, queue) = adapter
            .request_device(
                &wgpu::DeviceDescriptor {
                    label: Some("sab_workshop device"),
                    required_features: wgpu::Features::empty(),
                    required_limits: wgpu::Limits::default(),
                },
                None,
            )
            .await
            .map_err(|e| format!("request_device: {e}"))?;

        let mut config = surface
            .get_default_config(&adapter, size.width.max(1), size.height.max(1))
            .ok_or("surface unsupported by adapter")?;
        config.usage = wgpu::TextureUsages::RENDER_ATTACHMENT;
        surface.configure(&device, &config);
        let surface_format = config.format;

        let depth_view = make_depth(&device, &config);

        // --- uniforms / storage ---
        let camera_buf = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("camera"),
            size: std::mem::size_of::<CameraUniform>() as u64,
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        // Joint matrices (skinning). Start at bind pose (identity == bind if inv_bind consistent).
        let jc = joint_count.max(1);
        let ident: Vec<[[f32; 4]; 4]> = vec![Mat4::IDENTITY.to_cols_array_2d(); jc];
        let joint_buf = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("joints"),
            contents: bytemuck::cast_slice(&ident),
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
        });

        let bgl = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("scene bgl"),
            entries: &[
                wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::VERTEX | wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Buffer {
                        ty: wgpu::BufferBindingType::Uniform,
                        has_dynamic_offset: false,
                        min_binding_size: None,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 1,
                    visibility: wgpu::ShaderStages::VERTEX,
                    ty: wgpu::BindingType::Buffer {
                        ty: wgpu::BufferBindingType::Storage { read_only: true },
                        has_dynamic_offset: false,
                        min_binding_size: None,
                    },
                    count: None,
                },
            ],
        });
        let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("scene bg"),
            layout: &bgl,
            entries: &[
                wgpu::BindGroupEntry { binding: 0, resource: camera_buf.as_entire_binding() },
                wgpu::BindGroupEntry { binding: 1, resource: joint_buf.as_entire_binding() },
            ],
        });

        let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("scene pl"),
            bind_group_layouts: &[&bgl],
            push_constant_ranges: &[],
        });

        // --- mesh pipeline ---
        let mesh_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("mesh shader"),
            source: wgpu::ShaderSource::Wgsl(MESH_WGSL.into()),
        });
        let mesh_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("mesh pipeline"),
            layout: Some(&pipeline_layout),
            vertex: wgpu::VertexState {
                module: &mesh_shader,
                entry_point: "vs_main",
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<Vertex>() as u64,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![
                        0 => Float32x3, 1 => Float32x3, 2 => Uint16x4, 3 => Float32x4
                    ],
                }],
                compilation_options: Default::default(),
            },
            fragment: Some(wgpu::FragmentState {
                module: &mesh_shader,
                entry_point: "fs_main",
                targets: &[Some(wgpu::ColorTargetState {
                    format: surface_format,
                    blend: None,
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: Default::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::TriangleList,
                cull_mode: None,
                ..Default::default()
            },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: DEPTH_FORMAT,
                depth_write_enabled: true,
                depth_compare: wgpu::CompareFunction::Less,
                stencil: wgpu::StencilState::default(),
                bias: wgpu::DepthBiasState::default(),
            }),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
        });

        // --- mesh buffers ---
        let n = mesh.positions.len();
        let mut verts = Vec::with_capacity(n);
        for i in 0..n {
            verts.push(Vertex {
                pos: mesh.positions[i],
                normal: *mesh.normals.get(i).unwrap_or(&[0.0, 1.0, 0.0]),
                joints: *mesh.joints.get(i).unwrap_or(&[0, 0, 0, 0]),
                weights: *mesh.weights.get(i).unwrap_or(&[1.0, 0.0, 0.0, 0.0]),
            });
        }
        let vbo = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("mesh vbo"),
            contents: bytemuck::cast_slice(&verts),
            usage: wgpu::BufferUsages::VERTEX,
        });
        let ibo = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("mesh ibo"),
            contents: bytemuck::cast_slice(&mesh.indices),
            usage: wgpu::BufferUsages::INDEX,
        });
        let index_count = mesh.indices.len() as u32;

        // --- grid pipeline + geometry ---
        let grid_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("grid shader"),
            source: wgpu::ShaderSource::Wgsl(GRID_WGSL.into()),
        });
        let grid_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("grid pipeline"),
            layout: Some(&pipeline_layout),
            vertex: wgpu::VertexState {
                module: &grid_shader,
                entry_point: "vs_main",
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<GridVertex>() as u64,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x3, 1 => Float32x3],
                }],
                compilation_options: Default::default(),
            },
            fragment: Some(wgpu::FragmentState {
                module: &grid_shader,
                entry_point: "fs_main",
                targets: &[Some(wgpu::ColorTargetState {
                    format: surface_format,
                    blend: None,
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: Default::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::LineList,
                cull_mode: None,
                ..Default::default()
            },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: DEPTH_FORMAT,
                depth_write_enabled: true,
                depth_compare: wgpu::CompareFunction::Less,
                stencil: wgpu::StencilState::default(),
                bias: wgpu::DepthBiasState::default(),
            }),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
        });
        let grid_verts = build_grid(10, 0.5);
        let grid_count = grid_verts.len() as u32;
        let grid_vbo = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("grid vbo"),
            contents: bytemuck::cast_slice(&grid_verts),
            usage: wgpu::BufferUsages::VERTEX,
        });

        Ok(Renderer {
            surface,
            device,
            queue,
            config,
            surface_format,
            depth_view,
            camera_buf,
            joint_buf,
            bind_group,
            mesh_pipeline,
            vbo,
            ibo,
            index_count,
            grid_pipeline,
            grid_vbo,
            grid_count,
            joint_count: jc,
            show_grid: true,
        })
    }

    pub fn device(&self) -> &wgpu::Device { &self.device }
    pub fn surface_format(&self) -> wgpu::TextureFormat { self.surface_format }
    pub fn size(&self) -> [u32; 2] { [self.config.width, self.config.height] }
    pub fn aspect(&self) -> f32 { self.config.width as f32 / self.config.height.max(1) as f32 }

    pub fn resize(&mut self, w: u32, h: u32) {
        if w == 0 || h == 0 {
            return;
        }
        self.config.width = w;
        self.config.height = h;
        self.surface.configure(&self.device, &self.config);
        self.depth_view = make_depth(&self.device, &self.config);
    }

    pub fn update_camera(&self, view_proj: Mat4) {
        let u = CameraUniform { view_proj: view_proj.to_cols_array_2d() };
        self.queue.write_buffer(&self.camera_buf, 0, bytemuck::bytes_of(&u));
    }

    pub fn update_joints(&self, mats: &[Mat4]) {
        let mut data: Vec<[[f32; 4]; 4]> = Vec::with_capacity(self.joint_count);
        for i in 0..self.joint_count {
            data.push(mats.get(i).copied().unwrap_or(Mat4::IDENTITY).to_cols_array_2d());
        }
        self.queue.write_buffer(&self.joint_buf, 0, bytemuck::cast_slice(&data));
    }

    /// Draw one frame: 3D scene (grid + skinned mesh) then the egui overlay.
    pub fn render(&mut self, gui: &mut Gui) -> Result<(), wgpu::SurfaceError> {
        let output = match self.surface.get_current_texture() {
            Ok(o) => o,
            Err(wgpu::SurfaceError::Lost | wgpu::SurfaceError::Outdated) => {
                self.surface.configure(&self.device, &self.config);
                self.surface.get_current_texture()?
            }
            Err(e) => return Err(e),
        };
        let view = output.texture.create_view(&wgpu::TextureViewDescriptor::default());
        let mut encoder = self
            .device
            .create_command_encoder(&wgpu::CommandEncoderDescriptor { label: Some("frame") });
        {
            let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("scene pass"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &view,
                    resolve_target: None,
                    ops: wgpu::Operations {
                        load: wgpu::LoadOp::Clear(wgpu::Color { r: 0.08, g: 0.09, b: 0.11, a: 1.0 }),
                        store: wgpu::StoreOp::Store,
                    },
                })],
                depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                    view: &self.depth_view,
                    depth_ops: Some(wgpu::Operations {
                        load: wgpu::LoadOp::Clear(1.0),
                        store: wgpu::StoreOp::Store,
                    }),
                    stencil_ops: None,
                }),
                timestamp_writes: None,
                occlusion_query_set: None,
            });
            pass.set_bind_group(0, &self.bind_group, &[]);
            if self.show_grid {
                pass.set_pipeline(&self.grid_pipeline);
                pass.set_vertex_buffer(0, self.grid_vbo.slice(..));
                pass.draw(0..self.grid_count, 0..1);
            }
            pass.set_pipeline(&self.mesh_pipeline);
            pass.set_vertex_buffer(0, self.vbo.slice(..));
            pass.set_index_buffer(self.ibo.slice(..), wgpu::IndexFormat::Uint32);
            pass.draw_indexed(0..self.index_count, 0, 0..1);
        }
        gui.paint(&self.device, &self.queue, &mut encoder, &view, self.size());
        self.queue.submit(std::iter::once(encoder.finish()));
        output.present();
        Ok(())
    }
}

fn make_depth(device: &wgpu::Device, config: &wgpu::SurfaceConfiguration) -> wgpu::TextureView {
    let tex = device.create_texture(&wgpu::TextureDescriptor {
        label: Some("depth"),
        size: wgpu::Extent3d {
            width: config.width.max(1),
            height: config.height.max(1),
            depth_or_array_layers: 1,
        },
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: DEPTH_FORMAT,
        usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
        view_formats: &[],
    });
    tex.create_view(&wgpu::TextureViewDescriptor::default())
}

fn build_grid(half: i32, step: f32) -> Vec<GridVertex> {
    let mut v = Vec::new();
    let ext = half as f32 * step;
    let line = |v: &mut Vec<GridVertex>, a: [f32; 3], b: [f32; 3], c: [f32; 3]| {
        v.push(GridVertex { pos: a, color: c });
        v.push(GridVertex { pos: b, color: c });
    };
    for i in -half..=half {
        let p = i as f32 * step;
        let axis = i == 0;
        let cz = if axis { [0.45, 0.30, 0.30] } else { [0.22, 0.22, 0.26] };
        let cx = if axis { [0.30, 0.30, 0.45] } else { [0.22, 0.22, 0.26] };
        line(&mut v, [p, 0.0, -ext], [p, 0.0, ext], cz); // lines parallel to Z
        line(&mut v, [-ext, 0.0, p], [ext, 0.0, p], cx); // lines parallel to X
    }
    v
}

const MESH_WGSL: &str = r#"
struct Camera { view_proj: mat4x4<f32> };
@group(0) @binding(0) var<uniform> camera: Camera;
@group(0) @binding(1) var<storage, read> joints: array<mat4x4<f32>>;

struct VsIn {
    @location(0) pos: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) joints: vec4<u32>,
    @location(3) weights: vec4<f32>,
};
struct VsOut {
    @builtin(position) clip: vec4<f32>,
    @location(0) normal: vec3<f32>,
};

@vertex
fn vs_main(in: VsIn) -> VsOut {
    let wsum = in.weights.x + in.weights.y + in.weights.z + in.weights.w;
    var world_pos: vec4<f32>;
    var world_nrm: vec3<f32>;
    if (wsum < 0.0001) {
        // Unweighted vertex: leave it in bind space.
        world_pos = vec4<f32>(in.pos, 1.0);
        world_nrm = in.normal;
    } else {
        let m = joints[in.joints.x] * in.weights.x
              + joints[in.joints.y] * in.weights.y
              + joints[in.joints.z] * in.weights.z
              + joints[in.joints.w] * in.weights.w;
        world_pos = m * vec4<f32>(in.pos, 1.0);
        world_nrm = (m * vec4<f32>(in.normal, 0.0)).xyz;
    }
    var out: VsOut;
    out.clip = camera.view_proj * world_pos;
    out.normal = world_nrm;
    return out;
}

@fragment
fn fs_main(in: VsOut) -> @location(0) vec4<f32> {
    let n = normalize(in.normal);
    let l = normalize(vec3<f32>(0.4, 0.85, 0.55));
    // Two-sided lambert so backfaces aren't black.
    let d = abs(dot(n, l));
    let shade = 0.18 + 0.82 * d;
    return vec4<f32>(shade * 0.90, shade * 0.93, shade, 1.0);
}
"#;

const GRID_WGSL: &str = r#"
struct Camera { view_proj: mat4x4<f32> };
@group(0) @binding(0) var<uniform> camera: Camera;

struct VsIn {
    @location(0) pos: vec3<f32>,
    @location(1) color: vec3<f32>,
};
struct VsOut {
    @builtin(position) clip: vec4<f32>,
    @location(0) color: vec3<f32>,
};

@vertex
fn vs_main(in: VsIn) -> VsOut {
    var out: VsOut;
    out.clip = camera.view_proj * vec4<f32>(in.pos, 1.0);
    out.color = in.color;
    return out;
}

@fragment
fn fs_main(in: VsOut) -> @location(0) vec4<f32> {
    return vec4<f32>(in.color, 1.0);
}
"#;
