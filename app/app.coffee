Master = require 'components/master'
MonoOsc = require 'generators/mono'
Keyboard = require 'input/keyboard'


@ctx = new (AudioContext ? webkitAudioContext)

@osc = new MonoOsc ctx,
	oscillator:
		shape: 'triangle'
		octave: -2
		envelope:
			attack: .001
			decay: .1
			sustain: .2
			release: 2
	modulation:
		gain: 40
		frequency: 6
		envelope:
			attack: 2
			decay: 0
			sustain: 1
			release: 1

@master = new Master ctx
@keyboard = new Keyboard
osc.connect to:master
keyboard.connect osc