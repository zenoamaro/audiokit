Master = require 'components/master'
MonoOsc = require 'generators/mono'
Keyboard = require 'input/keyboard'


@ctx = new (AudioContext ? webkitAudioContext)

@osc = new MonoOsc ctx,
	oscillator:
		envelope:
			attack: .1
			decay: .2
			sustain: .2
			release: 1
	modulation:
		gain: 100
		frequency: 10
		envelope:
			attack: 3
			sustain: 1
			release: 1

@master = new Master ctx
@keyboard = new Keyboard
osc.connect to:master
keyboard.connect osc