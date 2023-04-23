module main

import gg
import gx
import physics.bodies
import physics.car
import math.vec
import rend
import extmath
import time
import math
import term

const (
	width     = 1280
	height    = 720
	framerate = 60
)

[heap]
struct State {
mut:
	ctx      &gg.Context
	car      car.Car
	old_time i64
}

fn main() {
	mut state := &State{}
	state.ctx = gg.new_context(
		bg_color: gx.rgb(174, 198, 255)
		create_window: true
		width: width
		height: height
		window_title: 'Car Sim'
		frame_fn: frame
		user_data: state
	)
	mat := car.Material{
		friction: 1
	}
	state.car = car.get_standard_car(vec.vec2[f32](width / 2, height / 2), math.pi_2 + 0.4,
		mat)
	state.old_time = get_time()
	state.ctx.run()
}

fn frame(mut state State) {
	// keep framerate
	mut now := get_time()
	for state.old_time + 1000 / framerate > now {
		now = get_time()
	}
	state.old_time = get_time()

	thr := if state.ctx.pressed_keys['W'[0]] {
		1
	} else {
		0
	} - if state.ctx.pressed_keys['S'[0]] {
		1
	} else {
		0
	}
	ang := (if state.ctx.pressed_keys['D'[0]] {
		f32(1)
	} else {
		f32(0)
	} - if state.ctx.pressed_keys['A'[0]] {
		f32(1)
	} else {
		f32(0)
	}) * f32(math.radians(30))
	state.car.update(ang, thr)
	draw(mut state)
}

fn draw(mut state State) {
	state.ctx.begin()

	// end no matter what
	defer {
		state.ctx.end()
	}

	// draw wheels
	for wheel in state.car.wheels {
		pos := state.car.to_global(wheel.local_pos)
		dir := state.car.to_global_force(extmath.from_angle(wheel.get_angle())).mul_scalar(15)
		rend.draw_arrow(mut state.ctx, pos, pos + dir, gx.green)
	}

	// draw forces
	// state.car.render(mut state.ctx)
	state.car.clear()

	// draw center
	pos := state.car.position
	rend.draw_arrow(mut state.ctx, pos, pos + extmath.from_angle(state.car.rotation).mul_scalar(15),
		gx.black)
}

fn get_time() i64 {
	return time.now().unix_time_milli()
}
