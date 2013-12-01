Master = require 'components/master'
MonoOsc = require 'generators/mono'
Keyboard = require 'input/keyboard'


@ctx = new (AudioContext ? webkitAudioContext)

@osc = new MonoOsc ctx,
	oscillator:
		shape: 'triangle'
		octave: 0
		envelope:
			attack: 1
			decay: 1
			sustain: .1
			release: 1
	modulation:
		gain: 10
		frequency: 6
		envelope:
			attack: 1
			decay: .5
			sustain: 1
			release: 1

@master = new Master ctx
@keyboard = new Keyboard
osc.connect to:master
keyboard.connect osc