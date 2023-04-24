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

/*
from http://totologic.blogspot.com/2014/01/accurate-point-in-triangle-test.html
function pointInTriangle(x1, y1, x2, y2, x3, y3, x, y:Number):Boolean
{
 var denominator:Number = ((y2 - y3)*(x1 - x3) + (x3 - x2)*(y1 - y3));
 var a:Number = ((y2 - y3)*(x - x3) + (x3 - x2)*(y - y3)) / denominator;
 var b:Number = ((y3 - y1)*(x - x3) + (x1 - x3)*(y - y3)) / denominator;
 var c:Number = 1 - a - b;

 return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1;
}
*/
pub fn is_in_triangle(p1 vec.Vec2[f32], p2 vec.Vec2[f32], p3 vec.Vec2[f32], p vec.Vec2[f32]) bool {
	den := (p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y)
	a := ((p2.y - p3.y) * (p.x - p3.x) + (p3.x - p2.x) * (p.y - p3.y)) / den
	b := ((p3.y - p1.y) * (p.x - p3.x) + (p1.x - p3.x) * (p.y - p3.y)) / den
	c := 1 - a - b
	return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1
}
