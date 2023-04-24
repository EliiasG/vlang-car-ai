module main

import gg
import gx
import physics.car
import math.vec
import rend
import extmath
import time
import math
import screen
import level
import gamesim
import neuralnet

const (
	width     = 1280
	height    = 720
	framerate = 60
)

[heap]
struct State {
mut:
	mat      car.Material
	scr      screen.Screen
	persp    rend.CarPerspective
	sim      gamesim.GameSimulation
	old_time i64
}

fn main() {
	mat := car.Material{
		friction: 1
	}
	c := car.get_standard_car(vec.vec2[f32](15, 0), 0, mat)
	lvl := level.generate_default_random_level(50000)
	sim := gamesim.new_simulation(lvl, c)
	persp := rend.new_car_perspective(32, 12)

	mut state := &State{
		mat: mat
		sim: sim
		persp: persp
	}
	state.scr.cam.zoom = 1

	state.scr.ctx = gg.new_context(
		bg_color: gx.rgb(174, 198, 255)
		create_window: true
		width: width
		height: height
		window_title: 'Car Sim'
		frame_fn: frame
		user_data: state
	)

	state.old_time = get_time()
	state.scr.ctx.run()
}

fn frame(mut state State) {
	// keep framerate
	mut now := get_time()
	for state.old_time + 1000 / framerate > now {
		now = get_time()
	}
	state.old_time = get_time()

	thr := if state.scr.ctx.pressed_keys['W'[0]] {
		1
	} else {
		0
	} - if state.scr.ctx.pressed_keys['S'[0]] {
		1
	} else {
		0
	}
	ang := (if state.scr.ctx.pressed_keys['D'[0]] {
		f32(1)
	} else {
		f32(0)
	} - if state.scr.ctx.pressed_keys['A'[0]] {
		f32(1)
	} else {
		f32(0)
	}) * f32(math.radians(30))

	state.sim.car.update(ang, thr)
	state.sim.update()
	state.persp.plot_sim(state.sim)

	if state.sim.done {
		c := car.get_standard_car(vec.vec2[f32](15, 0), 0, state.mat)
		state.sim = gamesim.new_simulation(state.sim.level, c)
	}

	// set camera position
	state.scr.cam.position = state.sim.car.position - vec.vec2[f32](width / 2, height / 2)

	// println(state.sim.current_section)

	draw(mut state)
}

fn draw(mut state State) {
	state.scr.ctx.begin()

	// end no matter what
	defer {
		state.scr.ctx.end()
	}

	// render level
	rend.render_level(mut state.scr, state.sim.level)

	// render perspective
	rend.draw_car_perspective(mut state.scr, state.persp, 10)

	// draw center
	pos := state.sim.car.position
	rend.draw_arrow(mut state.scr, pos, pos +
		extmath.from_angle(state.sim.car.rotation).mul_scalar(15), gx.black)

	// draw wheels
	for wheel in state.sim.car.wheels {
		wheel_pos := state.sim.car.to_global(wheel.local_pos)
		dir := state.sim.car.to_global_force(extmath.from_angle(wheel.get_angle())).mul_scalar(15)
		rend.draw_arrow(mut state.scr, wheel_pos, wheel_pos + dir, gx.green)
		// rend.draw_arrow(mut state.ctx, pos, pos +
		// state.car.velocity_at(wheel.local_pos).mul_scalar(5), gx.yellow)
	}
}

fn get_time() i64 {
	return time.now().unix_time_milli()
}
