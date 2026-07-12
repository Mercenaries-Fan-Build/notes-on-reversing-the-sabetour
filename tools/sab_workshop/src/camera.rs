//! Orbit camera: LMB-drag rotates, wheel zooms, MMB-drag pans. Right-handed, +Y up.

use glam::{Mat4, Vec3};

pub struct OrbitCamera {
    pub target: Vec3,
    pub yaw: f32,    // radians, around +Y
    pub pitch: f32,  // radians, clamped away from the poles
    pub distance: f32,
    pub fov_y: f32,
    pub near: f32,
    pub far: f32,
}

impl OrbitCamera {
    /// Frame a bounding sphere (center + radius).
    pub fn framing(center: Vec3, radius: f32) -> Self {
        let radius = radius.max(0.1);
        OrbitCamera {
            target: center,
            yaw: 0.7,
            pitch: 0.25,
            distance: radius * 2.8,
            fov_y: 45f32.to_radians(),
            near: (radius * 0.01).max(0.01),
            far: radius * 40.0,
        }
    }

    pub fn eye(&self) -> Vec3 {
        let cp = self.pitch.cos();
        let dir = Vec3::new(cp * self.yaw.sin(), self.pitch.sin(), cp * self.yaw.cos());
        self.target + dir * self.distance
    }

    pub fn view_proj(&self, aspect: f32) -> Mat4 {
        let view = Mat4::look_at_rh(self.eye(), self.target, Vec3::Y);
        let proj = Mat4::perspective_rh(self.fov_y, aspect.max(0.0001), self.near, self.far);
        proj * view
    }

    pub fn rotate(&mut self, dx: f32, dy: f32) {
        self.yaw -= dx * 0.01;
        self.pitch = (self.pitch + dy * 0.01).clamp(-1.54, 1.54);
    }

    pub fn zoom(&mut self, scroll: f32) {
        // Multiplicative so zoom feels even at any distance.
        self.distance = (self.distance * (1.0 - scroll * 0.1)).clamp(0.05, self.far);
    }

    pub fn pan(&mut self, dx: f32, dy: f32) {
        let fwd = (self.target - self.eye()).normalize_or_zero();
        let right = fwd.cross(Vec3::Y).normalize_or_zero();
        let up = right.cross(fwd).normalize_or_zero();
        let scale = self.distance * 0.0015;
        self.target += right * (-dx * scale) + up * (dy * scale);
    }
}
