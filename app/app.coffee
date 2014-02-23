Master = require 'components/master'
MonoOsc = require 'generators/mono'
Keyboard = require 'input/keyboard'


@ctx = new (AudioContext ? webkitAudioContext)

@oscA = new MonoOsc ctx,
	oscillator_octave: -1
	oscillator_attack: .01
	oscillator_decay: .2
	oscillator_sustain: .1
	oscillator_release: .2
	modulation_gain: 40
	modulation_frequency: 6

@oscB = new MonoOsc ctx,
	oscillator_octave: -3
	oscillator_detune: 15
	oscillator_attack: 1
	oscillator_decay: .2
	oscillator_sustain: .1
	oscillator_release: .9
	modulation_gain: 20
	modulation_frequency: 3

@master = new Master ctx
@keyboard = new Keyboard

oscA.outputs.out.connect master.inputs.in
oscB.outputs.out.connect master.inputs.in

keyboard.connect oscA
keyboard.connect oscB
