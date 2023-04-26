module rend

import screen
import physics.car
import gx
import extmath

pub fn draw_car(mut scr screen.Screen, c &car.Car) {
	// draw center
	pos := c.position
	draw_arrow(mut scr, pos, pos + extmath.from_angle(c.rotation).mul_scalar(15), gx.black)

	// draw wheels
	for wheel in c.wheels {
		wheel_pos := c.to_global(wheel.local_pos)
		dir := c.to_global_force(extmath.from_angle(wheel.get_angle())).mul_scalar(15)
		draw_arrow(mut scr, wheel_pos, wheel_pos + dir, gx.green)
		// rend.draw_arrow(mut state.ctx, pos, pos +
		// state.car.velocity_at(wheel.local_pos).mul_scalar(5), gx.yellow)
	}
}
