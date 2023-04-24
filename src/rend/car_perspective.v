module rend

import math.vec
import math
import gamesim
import screen
import gx
import extmath

[noinit]
pub struct CarPerspective {
mut:
	zoom f32
pub mut:
	pixels [][]bool
}

pub fn (mut c CarPerspective) plot_sim(sim &gamesim.GameSimulation) {
	c.clear()

	for i in -int(math.ceil(c.zoom / 2)) .. int(math.ceil(c.zoom * 5)) {
		sec := sim.current_section + i

		if sec < 0 || sec >= sim.level.left_points.len {
			continue
		}

		// gather points
		p1 := c.to_local(sim, sim.level.right_points[sec])
		p2 := c.to_local(sim, sim.level.right_points[sec + 1])
		p3 := c.to_local(sim, sim.level.left_points[sec])
		p4 := c.to_local(sim, sim.level.left_points[sec + 1])
		// draw lines
		c.draw_line(p1, p2)
		// println(p1)
		c.draw_line(p3, p4)
	}
}

fn (c &CarPerspective) to_local(sim &gamesim.GameSimulation, point vec.Vec2[f32]) vec.Vec2[f32] {
	// car to point
	cp := (point - sim.car.position)
	// scaled and rotated
	trans := extmath.rotated(cp.div_scalar(c.zoom), -sim.car.rotation)
	return trans + vec.vec2[f32](0, c.pixels.len / 2)
}

fn (mut c CarPerspective) clear() {
	for x in 0 .. c.pixels.len {
		for y in 0 .. c.pixels.len {
			c.pixels[x][y] = false
		}
	}
}

fn (mut c CarPerspective) draw_line(start vec.Vec2[f32], end vec.Vec2[f32]) {
	// line as vector
	line := end - start
	len := line.magnitude()
	// not using normalize, as it would calculate the length again
	dir := line.div_scalar(len)
	for i in 0 .. int(math.ceil(len)) {
		// current point
		p := start + dir.mul_scalar(i)
		// to int
		x, y := int(p.x), int(p.y)
		// check if is in screen
		if x < 0 || x >= c.pixels.len {
			continue
		}
		if y < 0 || y >= c.pixels.len {
			continue
		}
		// plot point
		c.pixels[x][y] = true
	}
}

pub fn new_car_perspective(size int, zoom f32) CarPerspective {
	return CarPerspective{
		pixels: [][]bool{len: size, init: []bool{len: size}}
		zoom: zoom
	}
}

pub fn draw_car_perspective(mut scr screen.Screen, c &CarPerspective, zoom int) {
	for x in 0 .. c.pixels.len {
		for y in 0 .. c.pixels.len {
			col := if c.pixels[x][y] { gx.white } else { gx.black }
			scr.ctx.draw_rect_filled(x * zoom, y * zoom, zoom, zoom, col)
		}
	}
}
