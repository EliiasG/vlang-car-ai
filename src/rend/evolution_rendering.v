module rend

import evolution
import screen

pub fn draw_evolution_sim(mut scr screen.Screen, sim &evolution.EvolutionSimulator) {
	draw_level(mut scr, sim.level)
	for n_sim in sim.sims {
		draw_car(mut scr, n_sim.gamesim.car)
	}
}
