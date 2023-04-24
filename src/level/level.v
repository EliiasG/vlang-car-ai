module level

import math.vec
import rand
import math
import extmath

pub struct Level {
pub:
	left_points  []vec.Vec2[f32]
	right_points []vec.Vec2[f32]
}

pub fn generate_random_level(seg_len f32, seg_rot f32, width f32, seg_amt int) Level {
	mut r := f32(0)
	mut r_amt := f32(0)
	mut points := []vec.Vec2[f32]{cap: seg_amt + 2}
	mut left_points := []vec.Vec2[f32]{cap: seg_amt + 1}
	mut right_points := []vec.Vec2[f32]{cap: seg_amt + 1}

	points << vec.vec2[f32](0, 0)

	for i in 0 .. seg_amt + 1 {
		// update rotation amount
		r_amt += rand.f32_in_range(-seg_rot, seg_rot) or { panic(err) }
		// clamp rotation amount
		r_amt = extmath.clampf(r_amt, -seg_rot * 10, seg_rot * 10)

		// update rotation
		r += r_amt
		// clamp rotation
		if r > math.pi_2 {
			r = math.pi_2
			r_amt = -seg_rot
		}
		if r < -math.pi_2 {
			r = -math.pi_2
			r_amt = seg_rot
		}
		// the segment as a vector
		seg := extmath.from_angle(r).mul_scalar[f32](seg_len)
		// calculate left and right point
		r_seg := vec.vec2[f32](seg.y, -seg.x).normalize().mul_scalar(width)
		l_seg := r_seg.mul_scalar(-1)
		// add point, since a element is added at the start [i] will be the previous point
		points << points[i] + seg
		left_points << points[i] + l_seg
		right_points << points[i] + r_seg
	}
	return Level{
		left_points: left_points
		right_points: right_points
	}
}

pub fn generate_default_random_level(len f32) Level {
	// settings for default level
	seg_len := f32(50)
	seg_rot := f32(math.radians(8))
	width := f32(50)

	return generate_random_level(seg_len, seg_rot, width, int(math.ceil(len / seg_len)))
}
