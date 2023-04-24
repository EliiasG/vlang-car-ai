module rend

import gg
import math.vec
import extmath
import math
import screen

const (
	arrow_head_size = 10
	line_thickness  = 1
)

pub fn draw_centered_line(mut scr screen.Screen, start vec.Vec2[f32], end vec.Vec2[f32], thickness int, col gg.Color) {
	cfg := gg.PenConfig{
		color: col
		line_type: .solid
		thickness: thickness
	}
	st := scr.cam.to_local(start)
	en := scr.cam.to_local(end)
	scr.ctx.draw_line_with_config(st.x, st.y, en.x, en.y, cfg)
	scr.ctx.draw_line_with_config(en.x, en.y, st.x, st.y, cfg)
}

pub fn draw_triangle(mut scr screen.Screen, p1 vec.Vec2[f32], p2 vec.Vec2[f32], p3 vec.Vec2[f32]) {
	panic('not impl')
	// TODO
}

pub fn draw_path(mut scr screen.Screen, points []vec.Vec2[f32], thickness int, col gg.Color) {
	mut prev := points.first()
	for point in points[1..] {
		draw_centered_line(mut scr, prev, point, thickness, col)
		prev = point
	}
}

pub fn draw_arrow(mut scr screen.Screen, start vec.Vec2[f32], end vec.Vec2[f32], col gg.Color) {
	draw_centered_line(mut scr, start, end, rend.line_thickness, col)
	a := (start - end).angle()
	p1 := end + extmath.from_angle(a + math.pi_4).mul_scalar(rend.arrow_head_size)
	p2 := end + extmath.from_angle(a - math.pi_4).mul_scalar(rend.arrow_head_size)
	draw_centered_line(mut scr, end, p1, rend.line_thickness, col)
	draw_centered_line(mut scr, end, p2, rend.line_thickness, col)
}
