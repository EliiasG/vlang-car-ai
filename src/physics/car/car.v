module car

import physics.bodies
import math.vec
import rend
import extmath
import math

pub struct Material {
	friction f32
}

pub interface Wheel {
	local_pos vec.Vec2[f32]
	speed f32
	powered bool
	material Material
}

pub struct BaseWheel {
pub:
	local_pos vec.Vec2[f32]
	powered   bool
pub mut:
	speed    f32
	material Material
}

pub struct TurningWheel {
	BaseWheel
pub mut:
	angle f32
}

pub struct Car {
	// maybe change
	rend.RenderedBody
pub:
	turn_speed     f32
	slide_friction f32
pub mut:
	wheels []Wheel
}

pub fn (mut c Car) update(turn_angle f32, throttle f32) {
	for mut wheel in c.wheels {
		if mut wheel is TurningWheel {
			wheel.angle = extmath.move_towards(wheel.angle, turn_angle, c.turn_speed)
		}
		wheel.apply_forces(mut c, throttle)
	}
}

pub fn (w &Wheel) apply_forces(mut c Car, throttle f32) {
	w.apply_slide_friction(mut c, throttle)
	// TODO more
}

fn (w &Wheel) apply_slide_friction(mut c Car, throttle f32) {
	// local angle of wheel
	l_ang := if w is TurningWheel { w.angle } else { 0 }
	// global angle of wheel
	ang := c.rotation + l_ang
	// turn angle into direction
	dir := extmath.from_angle(ang)
	// amount of speed that is in wheels direction
	spd := if c.velocity.is_approx_zero(0.001) {
		1
	} else {
		dir.project(c.velocity).magnitude()
	}

	// the amount of friction to apply
	fric := c.slide_friction * (1 - spd) * extmath.len_squared(c.velocity)
	// the local friction force
	fric_force := extmath.from_angle(l_ang + math.pi_2).mul_scalar(fric)

	if dir.cross(c.velocity) > 0 {
		c.apply_local_force(fric_force, w.local_pos)
	} else {
		c.apply_local_force(fric_force.mul_scalar(-1), w.local_pos)
	}
}

pub fn get_standard_car() Car {
	panic('not implemented')
}
