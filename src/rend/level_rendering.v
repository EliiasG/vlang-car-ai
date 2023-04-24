module rend

import level
import screen
import gx

pub fn render_level(mut scr screen.Screen, lvl level.Level) {
	draw_path(mut scr, lvl.left_points, 1, gx.black)
	draw_path(mut scr, lvl.right_points, 1, gx.black)
}
