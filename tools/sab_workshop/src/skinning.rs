//! Skeleton pose composition -> per-bone joint matrices for GPU skinning.
//!
//! Convention (glTF, validated by our exporter): column-vector, `world[i] =
//! world[parent] * local[i]`, `jointMatrix[i] = world[i] * inv_bind[i]`.
//! `inv_bind` is stored row-major in the `.skel`; we transpose to glam's column-major.

use glam::{Mat4, Quat, Vec3};

use crate::formats::Bone;
use crate::havok::QsTransform;

/// Local (bind-pose) matrix of a bone.
fn bind_local(b: &Bone) -> Mat4 {
    Mat4::from_scale_rotation_translation(
        Vec3::from_array(b.s),
        Quat::from_xyzw(b.r[0], b.r[1], b.r[2], b.r[3]),
        Vec3::from_array(b.t),
    )
}

/// Local matrix from a sampled animation transform.
fn anim_local(q: &QsTransform) -> Mat4 {
    Mat4::from_scale_rotation_translation(
        Vec3::new(q.s[0], q.s[1], q.s[2]),
        Quat::from_xyzw(q.r[0], q.r[1], q.r[2], q.r[3]),
        Vec3::new(q.t[0], q.t[1], q.t[2]),
    )
}

/// Inverse-bind matrix for a bone as a glam Mat4 (row-major .skel -> column-major).
fn inv_bind(b: &Bone) -> Mat4 {
    match b.inv_bind {
        Some(rm) => {
            // rm is row-major m[r*4+c]; glam wants column-major -> transpose.
            let mut cm = [0f32; 16];
            for c in 0..4 {
                for r in 0..4 {
                    cm[c * 4 + r] = rm[r * 4 + c];
                }
            }
            Mat4::from_cols_array(&cm)
        }
        None => Mat4::IDENTITY,
    }
}

/// Compose world matrices for every bone. Parent-before-child is NOT assumed:
/// we iterate to a fixed point so any bone ordering resolves.
fn world_matrices(skel: &[Bone], locals: &[Mat4]) -> Vec<Mat4> {
    let n = skel.len();
    let mut world = vec![Mat4::IDENTITY; n];
    let mut done = vec![false; n];
    let mut remaining = n;
    let mut guard = 0;
    while remaining > 0 && guard <= n {
        guard += 1;
        for i in 0..n {
            if done[i] {
                continue;
            }
            let p = skel[i].parent;
            if p < 0 || p as usize >= n {
                world[i] = locals[i];
                done[i] = true;
                remaining -= 1;
            } else if done[p as usize] {
                world[i] = world[p as usize] * locals[i];
                done[i] = true;
                remaining -= 1;
            }
        }
    }
    // Any cycle-stranded bones keep their bind-pose local as world (best-effort).
    for i in 0..n {
        if !done[i] {
            world[i] = locals[i];
        }
    }
    world
}

/// Joint matrices for the bind pose (all animated tracks unset). At bind pose each
/// `jointMatrix` should be ~identity if inv_bind is consistent.
pub fn bind_pose(skel: &[Bone]) -> Vec<Mat4> {
    let locals: Vec<Mat4> = skel.iter().map(bind_local).collect();
    let world = world_matrices(skel, &locals);
    world.iter().zip(skel).map(|(w, b)| *w * inv_bind(b)).collect()
}

/// Joint matrices for a posed frame. `pose` is one QsTransform per animation track,
/// `track_to_bone[k]` the skeleton bone that track k drives (-1 = unbound, ignored).
pub fn posed(skel: &[Bone], pose: &[QsTransform], track_to_bone: &[i32]) -> Vec<Mat4> {
    let mut locals: Vec<Mat4> = skel.iter().map(bind_local).collect();
    for (k, q) in pose.iter().enumerate() {
        let bone = track_to_bone.get(k).copied().unwrap_or(-1);
        if bone >= 0 && (bone as usize) < locals.len() {
            locals[bone as usize] = anim_local(q);
        }
    }
    let world = world_matrices(skel, &locals);
    world.iter().zip(skel).map(|(w, b)| *w * inv_bind(b)).collect()
}
