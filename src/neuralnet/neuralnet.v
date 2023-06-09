module neuralnet

import extmath
import rand

pub struct Neuron {
mut:
	weights []f32
	bias    f32
}

[heap; noinit]
pub struct NeuralNetwork {
mut:
	layers [][]Neuron
}

pub fn (mut n NeuralNetwork) copy_data(other &NeuralNetwork) {
	// iterate over layers
	for l_i, layer in other.layers {
		// iterate over neurons
		for n_i, o_neuron in layer {
			// o_neuron is neuron of other n_neuron is own neuron
			mut n_neuron := &n.layers[l_i][n_i]
			// set weights
			for w_i, w in o_neuron.weights {
				n_neuron.weights[w_i] = w
			}
			// set bias
			n_neuron.bias = o_neuron.bias
		}
	}
}

pub fn (n &NeuralNetwork) evaluate(inputs []f32) []f32 {
	// previous evaluation, in the start this is the input
	mut prev := inputs.clone()
	// the current evaluation
	mut eval := []f32{}
	for layer in n.layers {
		eval.clear()
		// set neurons of evaluation
		for neu in layer {
			// bias is applied here
			mut v := -neu.bias
			// sum weights multiplied by previous evaluation
			for i, weight in neu.weights {
				v += prev[i] * weight
			}
			// using sigmoid to get value between 0 and 1
			eval << extmath.sigmoid(v)
		}
		prev = eval.clone()
	}
	// last evaluation will be output
	return eval
}

pub fn (mut n NeuralNetwork) evolve(amt int, magnitude f32) {
	for _ in 0 .. amt {
		n.evolve_once(magnitude)
	}
}

fn (mut n NeuralNetwork) evolve_once(magnitude f32) {
	// choose amount
	amt := rand.f32_in_range(-magnitude, magnitude) or { panic(err) }
	// choose neuron
	layer_idx := rand.int_in_range(0, n.layers.len) or { panic(err) }
	layer := n.layers[layer_idx]
	neuron_idx := rand.int_in_range(0, layer.len) or { panic(err) }
	mut neuron := &layer[neuron_idx]
	// choose index
	idx := rand.int_in_range(-1, neuron.weights.len) or { panic(err) }
	// apply change to weight or bias
	if idx == -1 {
		neuron.bias += amt
	} else {
		neuron.weights[idx] += amt
	}
}

pub fn new_neural_network(inputs int, layers ...int) NeuralNetwork {
	// create network
	mut r := NeuralNetwork{
		layers: [][]Neuron{cap: layers.len + 1}
	}

	// amount of neurons in previous layer, starts at input since they have no weights
	mut prev_amt := inputs
	// generate layers
	for layer_amt in layers {
		// create layer with layer_amt neurons that have prev_amt weights each
		r.layers << []Neuron{len: layer_amt, init: Neuron{
			weights: []f32{len: prev_amt, init: 0}
		}}
		prev_amt = layer_amt
	}

	return r
}
