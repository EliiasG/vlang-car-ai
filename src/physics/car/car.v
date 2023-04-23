module car

import math.vec
import rend
import extmath
import math

[heap]
pub struct Material {
pub:
	friction f32
}

pub interface Wheel {
	local_pos vec.Vec2[f32]
	powered bool
	mass f32
mut:
	speed f32
	material &Material
}

pub fn (mut w Wheel) set_material(m &Material) {
	w.material = m
}

pub fn (w &Wheel) get_angle() f32 {
	return if w is TurningWheel { w.angle } else { 0 }
}

fn (mut w Wheel) apply_acceleration(c &Car, throttle f32) {
	// axle friction
	w.speed -= extmath.clampf(w.speed, -c.passive_braking, c.passive_braking)
	// braking
	if throttle != 0 && math.sign(throttle) != math.sign(w.speed) {
		w.speed = extmath.move_towards(w.speed, 0, c.brake_power)
	}
	// if we are moving or should move forwards
	if w.speed > 0 || (w.speed == 0 && throttle > 0) {
		// accelerate
		if w.powered {
			// target speed
			tgt := c.max_speed * throttle
			// remaining speed to reach target
			diff := tgt - w.speed
			// apply acceleration
			w.speed += extmath.clampf(diff, 0, c.acceleration)
		}
	}
	// if we are moving or should move backwards
	if w.speed < 0 || (w.speed == 0 && throttle < 0) {
		// accelerate
		if w.powered {
			// target speed
			tgt := c.max_reverse_speed * throttle
			// remaining speed to reach target
			diff := tgt - w.speed
			// apply acceleration
			w.speed += extmath.clampf(diff, -c.acceleration, 0)
		}
	}
}

// mut to brake wheel
fn (mut w Wheel) apply_forces(mut c Car) {
	// local angle of wheel
	l_ang := w.get_angle()
	// local direction of wheel
	l_dir := extmath.from_angle(l_ang)
	// global angle of wheel
	ang := c.rotation + l_ang
	// turn angle into direction
	dir := extmath.from_angle(ang)
	// velocity at wheel
	v := c.velocity_at(w.local_pos)

	// amount of speed that is in wheels direction
	spd := if v.is_approx_zero(0.001) {
		f32(1)
	} else {
		p := extmath.project(dir, v)
		extmath.rotated(p, -v.angle()).x
	}

	// slide friction

	// the amount of friction to apply
	mut fric := -c.slide_friction * w.material.friction
	// the local friction force
	mut fric_force := c.to_local_force(extmath.project(v, extmath.rotated(dir, math.pi_2)).mul_scalar(fric))
	// clamp
	if extmath.len_squared(fric_force) > extmath.len_squared(v) {
		fric_force = fric_force.normalize().mul_scalar(v.magnitude())
		// TODO UUUUUUH
	}

	// apply the friction force
	c.apply_local_force(fric_force, w.local_pos)

	// speed forces

	// speed of the car relative to the wheel
	car_relative_spd := spd * v.magnitude()
	// difference between wheel speed and car speed
	diff := w.speed - car_relative_spd

	// amount of speed force to apply, may be negative if wheel is faster than ground
	amt := diff * w.material.friction // f32(math.copysign(diff * diff, diff)) * w.material.friction
	w.speed -= amt / w.mass

	// apply speed force
	c.apply_local_force(l_dir.mul_scalar(amt), w.local_pos)
}

pub struct BaseWheel {
pub:
	local_pos vec.Vec2[f32]
	powered   bool
	mass      f32
pub mut:
	speed    f32
	material &Material
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
	max_speed         f32
	max_reverse_speed f32
	acceleration      f32
	brake_power       f32
	passive_braking   f32
	turn_speed        f32
	slide_friction    f32
pub mut:
	wheels []Wheel
}

pub fn (mut c Car) update(turn_angle f32, throttle f32) {
	for mut wheel in c.wheels {
		if mut wheel is TurningWheel {
			wheel.angle = extmath.move_towards(wheel.angle, turn_angle, c.turn_speed)
		}
		wheel.apply_forces(mut c)
		wheel.apply_acceleration(c, throttle)
	}
	c.move()
}

pub fn get_standard_car(pos vec.Vec2[f32], rot f32, mat &Material) Car {
	wheel_mass := 2
	return Car{
		max_speed: 15
		max_reverse_speed: 2
		acceleration: 3
		brake_power: 10
		passive_braking: .15
		turn_speed: math.tau / 200
		slide_friction: 5
		wheels: [
			BaseWheel{
				local_pos: vec.vec2[f32](-20, 0)
				powered: true
				mass: wheel_mass
				material: mat
			},
			TurningWheel{
				local_pos: vec.vec2[f32](16, -8)
				powered: false
				mass: wheel_mass
				material: mat
			},
			TurningWheel{
				local_pos: vec.vec2[f32](16, 8)
				powered: false
				mass: wheel_mass
				material: mat
			},
		]
		position: pos
		velocity: vec.vec2[f32](0, 0)
		rotation: rot
		angular_velocity: 0.0
		mass: 100
	}
}
