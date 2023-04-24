module camera

import math.vec

[heap]
pub struct Camera {
pub mut:
	position vec.Vec2[f32]
	zoom     f32 = 1
}

pub fn (c &Camera) to_global(v vec.Vec2[f32]) vec.Vec2[f32] {
	return c.position + v.mul_scalar[f32](c.zoom)
}

pub fn (c &Camera) to_local(v vec.Vec2[f32]) vec.Vec2[f32] {
	return (v - c.position).div_scalar[f32](c.zoom)
}
