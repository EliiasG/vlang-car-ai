module evolution

import neuralnet
import gamesim
import level
import physics.car
import math.vec
import os
import json
import persp
import net

const (
	thread_count        = 16
	save_path           = 'save.json'
	view_size           = 32
	view_zoom           = f32(12)
	layers              = [
		48,
		4,
	]
	frame_amount        = 60 * 8
	level_length        = frame_amount * car.get_standard_car(vec.vec2[f32](0, 0), 0,
		mat).max_speed
	parent_count        = 8
	child_count         = 16
	evolution_amount    = 2
	sim_amount          = parent_count * child_count + parent_count
	evolution_magnitude = f32(.25)
	init_amount         = 32
	init_magnitude      = f32(1)
	mat                 = car.Material{
		friction: 1
	}
)

[heap; noinit]
pub struct EvolutionSimulator {
pub mut:
	save       thread int
	level      level.Level
	frame      int
	generation u32
	sims       []NeuralSimulator
}

struct ParentState {
	generation u32
	networks   []neuralnet.NeuralNetwork
}

pub fn new_evolution_sim() EvolutionSimulator {
	// create sim
	mut sim := EvolutionSimulator{
		sims: []NeuralSimulator{cap: evolution.sim_amount}
	}

	for _ in 0 .. sim.sims.cap {
		sim.sims << new_sim()
	}
	// load or init sim
	if dat := os.read_file(evolution.save_path) {
		// load save
		state := json.decode(ParentState, dat) or { panic('invalid save, maybe delete it') }
		sim.generation = state.generation
		// evolve save
		sim.evolve(state)
	} else {
		for mut n_sim in sim.sims {
			// start evolution
			n_sim.network.evolve(evolution.init_amount, evolution.init_magnitude)
		}
	}
	return sim
}

pub fn (mut e EvolutionSimulator) update() {
	// just started or reset
	if e.frame == 0 {
		e.level = level.generate_default_random_level(evolution.level_length)
		for mut sim in e.sims {
			sim.reset(e.level)
		}
	}
	// update
	e.update_sims()
	e.frame++
	// done
	if e.frame >= evolution.frame_amount {
		// find survivors / parents for next generation
		state := e.find_parents()
		// save
		if e.generation % 10 == 0 {
			println('saving')
			spawn fn [state] () {
				os.write_file(evolution.save_path, json.encode(state)) or {
					println('could not save')
				}
				println('saved')
			}()
		}
		e.evolve(state)
		e.frame = 0
	}
}

pub fn (mut e EvolutionSimulator) evolve(state &ParentState) {
	e.generation = state.generation + 1
	// create winners
	for i in 0 .. evolution.parent_count {
		e.sims[i].network.copy_data(state.networks[i])
	}
	// create children
	for i in 0 .. evolution.sim_amount - evolution.parent_count {
		mut sim := e.sims[i + evolution.parent_count]
		sim.network.copy_data(state.networks[i / evolution.child_count])
		sim.network.evolve(evolution.evolution_amount, evolution.evolution_magnitude)
	}
}

pub fn (mut e EvolutionSimulator) find_parents() ParentState {
	mut networks := []neuralnet.NeuralNetwork{len: evolution.parent_count, init: new_net()}
	// sort sims by who made it furthest
	e.sims.sort_with_compare(fn (a &NeuralSimulator, b &NeuralSimulator) int {
		s1 := get_score(a.gamesim)
		s2 := get_score(b.gamesim)
		if s2 > s1 {
			return 1
		}
		if s1 > s2 {
			return -1
		}
		return 0
	})
	println(e.sims[0].gamesim.current_section)
	for i, mut net in networks {
		net.copy_data(e.sims[i].network)
	}
	// return state with top networks
	return ParentState{
		generation: e.generation
		networks: networks
	}
}

[inline]
fn get_score(sim gamesim.GameSimulation) int {
	// divide score if dead
	return if sim.done {
		sim.current_section / 5
	} else {
		sim.current_section
	}
}

fn (mut e EvolutionSimulator) update_sims() {
	// amount of sims per thread
	amt := e.sims.len / evolution.thread_count
	// thread list
	mut threads := []thread{cap: e.sims.len}
	for i in 0 .. amt {
		// update sims
		threads << spawn fn [i, e] () {
			start := i * evolution.thread_count
			for mut sim in e.sims[start..start + evolution.thread_count] {
				sim.update()
			}
		}()
	}
	// update remaining
	threads << spawn fn [e, amt] () {
		for mut sim in e.sims[amt * evolution.thread_count..] {
			sim.update()
		}
	}()
	threads.wait()
}

[heap]
struct NeuralSimulator {
pub mut:
	network neuralnet.NeuralNetwork
	gamesim &gamesim.GameSimulation = unsafe { nil }
	persp   persp.CarPerspective
}

fn new_sim() NeuralSimulator {
	// must be reset before use
	return NeuralSimulator{
		network: new_net()
		persp: persp.new_car_perspective(evolution.view_size, evolution.view_zoom)
	}
}

fn new_net() neuralnet.NeuralNetwork {
	return neuralnet.new_neural_network(evolution.view_size * evolution.view_size, ...evolution.layers)
}

fn (mut n NeuralSimulator) reset(lvl &level.Level) {
	sim := gamesim.new_simulation(lvl, car.get_standard_car(vec.vec2[f32](15, 0), 0, evolution.mat))
	n.gamesim = &sim
}

fn (mut n NeuralSimulator) update() bool {
	if n.gamesim.done {
		return true
	}
	// draw perspective
	n.persp.plot_sim(n.gamesim)
	// evaluate network
	thr, steer := evaluate_sim(n)
	// update sim
	n.gamesim.car.update(steer, thr)
	n.gamesim.update()
	return false
}

[inline]
fn get_value(p &persp.CarPerspective, i int) f32 {
	return if p.pixels[i % p.pixels.len][i / p.pixels.len] { 1 } else { 0 }
}

pub fn evaluate_sim(sim &NeuralSimulator) (f32, f32) {
	per := sim.persp
	// input to network
	mut inp := []f32{len: per.pixels.len * per.pixels.len, init: get_value(per, index)}
	// cheat to also give network velocity, done to not make retraining required
	inp[inp.len - 1] = sim.gamesim.car.velocity.magnitude() / sim.gamesim.car.max_speed

	// result
	res := sim.network.evaluate(inp)
	// check
	if res.len != 4 {
		panic('invalid network')
	}
	// return throttle, steering
	return res[0] - res[1], res[2] - res[3]
}
