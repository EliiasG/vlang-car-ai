module rend

import screen
import gx
import persp

pub fn draw_car_perspective(mut scr screen.Screen, c &persp.CarPerspective, zoom int) {
	for x in 0 .. c.pixels.len {
		for y in 0 .. c.pixels.len {
			col := if c.pixels[x][y] { gx.white } else { gx.black }
			scr.ctx.draw_rect_filled(x * zoom, y * zoom, zoom, zoom, col)
		}
	}
}
