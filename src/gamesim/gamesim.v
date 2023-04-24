module gamesim

import level
import physics.car
import extmath

[noinit]
pub struct GameSimulation {
pub:
	level &level.Level
pub mut:
	car             car.Car
	done            bool
	current_section int
}

pub fn new_simulation(lvl &level.Level, c &car.Car) GameSimulation {
	return GameSimulation{
		level: lvl
		car: c
	}
}

pub fn (mut g GameSimulation) update() {
	// if done return
	if g.done {
		return
	}
	// is in current section
	if g.in_section(g.current_section) {
		return
	}
	// is in next section
	if g.in_section(g.current_section + 1) {
		g.current_section++
		return
	}
	// is in previous section
	if g.in_section(g.current_section - 1) {
		g.current_section--
		return
	}

	// not in level - dead
	g.done = true
}

fn (g &GameSimulation) in_section(sec int) bool {
	// return if section does not exist
	if sec < 0 || sec >= g.level.right_points.len - 1 {
		return false
	}

	// section bounds
	p1 := g.level.right_points[sec]
	p2 := g.level.right_points[sec + 1]
	p3 := g.level.left_points[sec]
	p4 := g.level.left_points[sec + 1]

	return extmath.is_in_triangle(p1, p2, p3, g.car.position)
		|| extmath.is_in_triangle(p2, p3, p4, g.car.position)
}
