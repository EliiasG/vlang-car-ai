module main

import gg
import gx
import math.vec
import rend
import time
import screen
import gamesim
import evolution

const (
	width     = 1280
	height    = 720
	framerate = 60
)

[heap]
struct State {
mut:
	scr       screen.Screen
	sim       evolution.EvolutionSimulator
	old_time  i64
	old_space bool
	fast      bool
}

fn main() {
	mut state := &State{
		sim: evolution.new_evolution_sim()
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
	space := state.scr.ctx.pressed_keys[' '[0]]
	if space && !state.old_space {
		state.fast = !state.fast
	}
	state.old_space = space
	amt := if state.fast {
		10
	} else {
		1
	}
	for _ in 0 .. amt {
		state.sim.update()
	}
	draw(mut state)
}

fn draw(mut state State) {
	// move camera

	// find best car
	mut best := state.sim.sims[0]
	for sim in state.sim.sims {
		if sim.gamesim.car.position.x > best.gamesim.car.position.x {
			best = sim
		}
	}
	// set camera pos
	state.scr.cam.position = best.gamesim.car.position - vec.vec2[f32](width / 2, height / 2)
	state.scr.ctx.begin()

	// end no matter what
	defer {
		state.scr.ctx.end()
	}

	// draw evolution number
	cfg := gx.TextCfg{
		color: gx.white
		size: 32
		bold: true
	}
	state.scr.ctx.draw_text(32 * 5, 0, 'Generation ${state.sim.generation}', cfg)
	// draw perspective
	rend.draw_car_perspective(mut state.scr, best.persp, 5)
	// draw sim
	rend.draw_evolution_sim(mut state.scr, state.sim)
}

fn get_time() i64 {
	return time.now().unix_time_milli()
}
