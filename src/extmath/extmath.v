module extmath

import math
import math.vec

pub fn atan(x f32) f32 {
	// not ideal
	return f32(math.atan(x))
}

pub fn atan2(y f32, x f32) f32 {
	return atan(y / x)
}

pub fn from_angle(a f32) vec.Vec2[f32] {
	return vec.vec2[f32](math.cosf(a), math.sinf(a))
}

pub fn rotated(v vec.Vec2[f32], a f32) vec.Vec2[f32] {
	new_a := a + v.angle()
	return from_angle(new_a).mul_scalar(v.magnitude())
}

pub fn len_squared(a vec.Vec2[f32]) f32 {
	return a.x * a.x + a.y * a.y
}

pub fn closest_point_on_line(point vec.Vec2[f32], a vec.Vec2[f32], b vec.Vec2[f32]) vec.Vec2[f32] {
	ap := point - a
	ab := b - a

	dst := ap.dot(ab) / len_squared(ab)

	return a + ab.mul_scalar(dst)
}

pub fn clampf(v f32, a f32, b f32) f32 {
	if v < a {
		return a
	} else if v > b {
		return b
	}
	return v
}

pub fn move_towards(value f32, target f32, amount f32) f32 {
	return value + clampf(target - value, -amount, amount)
}

pub fn project(u vec.Vec2[f32], v vec.Vec2[f32]) vec.Vec2[f32] {
	return v.mul_scalar(u.dot(v) / len_squared(v))
}
