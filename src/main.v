module main

import gg
import gx
import physics.bodies
import physics.car
import math.vec
import rend
import extmath
import time

const (
	width     = 1280
	height    = 720
	framerate = 60
)

[heap]
struct State {
mut:
	ctx      &gg.Context
	rb       rend.RenderedBody
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
	state.rb = rend.RenderedBody{
		position: vec.vec2[f32](150, 150)
		velocity: vec.vec2[f32](0, 0)
		rotation: 0.0
		angular_velocity: 0.0
		mass: 15.0
	}
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

	// update rb
	state.rb.move()

	// apply forces
	state.rb.apply_local_force(vec.vec2[f32](.1, 0), vec.vec2[f32](-17, 10))
	state.rb.apply_local_force(vec.vec2[f32](.1, 0), vec.vec2[f32](-17, -10))
	state.rb.apply_local_force(vec.vec2[f32](1, 1).normalize().mul_scalar(.1), vec.vec2[f32](17,
		10))
	state.rb.apply_local_force(vec.vec2[f32](1, 1).normalize().mul_scalar(.1), vec.vec2[f32](17,
		-10))

	draw(mut state)
}

fn draw(mut state State) {
	state.ctx.begin()

	// end no matter what
	defer {
		state.ctx.end()
	}

	// draw forces
	state.rb.render(mut state.ctx)
	state.rb.clear()

	// draw center
	pos := state.rb.position
	rend.draw_arrow(mut state.ctx, pos, pos + extmath.from_angle(state.rb.rotation).mul_scalar(15),
		gx.black)
}

fn get_time() i64 {
	return time.now().unix_time_milli()
}
