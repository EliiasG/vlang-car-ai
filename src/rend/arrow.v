module rend

import gg
import math.vec
import extmath
import math

const (
	arrow_head_size = 10
	line_thickness  = 1
)

pub fn draw_centered_line(mut ctx gg.Context, start vec.Vec2[f32], end vec.Vec2[f32], thickness int, col gg.Color) {
	cfg := gg.PenConfig{
		color: col
		line_type: .solid
		thickness: thickness
	}
	ctx.draw_line_with_config(start.x, start.y, end.x, end.y, cfg)
	ctx.draw_line_with_config(end.x, end.y, start.x, start.y, cfg)
}

pub fn draw_arrow(mut ctx gg.Context, start vec.Vec2[f32], end vec.Vec2[f32], col gg.Color) {
	draw_centered_line(mut ctx, start, end, rend.line_thickness, col)
	a := (start - end).angle()
	p1 := end + extmath.from_angle(a + math.pi_4).mul_scalar(rend.arrow_head_size)
	p2 := end + extmath.from_angle(a - math.pi_4).mul_scalar(rend.arrow_head_size)
	draw_centered_line(mut ctx, end, p1, rend.line_thickness, col)
	draw_centered_line(mut ctx, end, p2, rend.line_thickness, col)
}
