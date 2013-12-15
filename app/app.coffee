Master = require 'components/master'
MonoOsc = require 'generators/mono'
Keyboard = require 'input/keyboard'


@ctx = new (AudioContext ? webkitAudioContext)

@oscA = new MonoOsc ctx,
	oscillator:
		shape: 'triangle'
		octave: -2
		envelope:
			attack: .001
			decay: .1
			sustain: .2
			release: .01
	modulation:
		gain: 40
		frequency: 6
		envelope:
			attack: 2
			decay: 0
			sustain: 1
			release: 1

@oscB = new MonoOsc ctx,
	oscillator:
		gain: 1
		shape: 'triangle'
		octave: -3
		tune: 15
		envelope:
			attack: .001
			decay: .1
			sustain: .2
			release: .01
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
oscA.outputs.out.connect master.inputs.in
oscB.outputs.out.connect master.inputs.in
keyboard.connect oscA
keyboard.connect oscB