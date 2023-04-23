module rend

import gg
import math.vec
import gx
import physics.bodies

pub struct Force {
	pos   vec.Vec2[f32]
	power vec.Vec2[f32]
}

[heap]
pub struct RenderedBody {
	bodies.RigidBody
mut:
	forces []Force = []Force{}
}

pub fn (mut b RenderedBody) apply_local_force(force vec.Vec2[f32], pos vec.Vec2[f32]) {
	b.apply_force(b.to_global_force(force), b.to_global(pos))
}

pub fn (mut b RenderedBody) apply_force(force vec.Vec2[f32], pos vec.Vec2[f32]) {
	b.forces << Force{
		pos: pos
		power: force
	}
	b.RigidBody.apply_force(force, pos)
}

pub fn (b &RenderedBody) render(mut cxt gg.Context) {
	// println(f.forces.len)
	for force in b.forces {
		draw_arrow(mut cxt, force.pos, force.pos + force.power.mul_scalar(2), gx.red)
	}
}

pub fn (mut b RenderedBody) clear() {
	b.forces.clear()
}
