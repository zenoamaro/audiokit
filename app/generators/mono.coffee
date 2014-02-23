u = require 'utils'
debug = require 'utils/debug'
music = require 'core/music'
Gain = require 'components/gain'
Oscillator = require 'components/oscillator'
Envelope = require 'components/envelope'
Generator = require 'core/generator'


module.exports = class MonoOsc extends Generator

	outputs:
		out:
			label: 'Output'
			source: -> @_out.outputs.out

	params:

		modulation_gain:
			label: 'Modulation gain'
			default: 0
		modulation_frequency:
			label: 'Modulation frequency'
			default: 6
		modulation_attack:
			label: 'Modulation attack'
			default: 1
		modulation_decay:
			label: 'Modulation decay'
			default: 1
		modulation_sustain:
			label: 'Modulation sustain'
			default: 1
		modulation_release:
			label: 'Modulation release'
			default: 1

		oscillator_gain:
			label: 'Oscillator gain'
			default: 1
		oscillator_frequency:
			label: 'Oscillator frequency'
			default: 0
		oscillator_octave:
			label: 'Oscillator octave'
			default: 0
		oscillator_detune:
			label: 'Oscillator detune'
			default: 0
		oscillator_attack:
			label: 'Oscillator attack'
			default: .2
		oscillator_decay:
			label: 'Oscillator decay'
			default: .2
		oscillator_sustain:
			label: 'Oscillator sustain'
			default: .2
		oscillator_release:
			label: 'Oscillator release'
			default: 1

	frequency: (note) ->
		cents = (music.note note) \
		      + (music.octaves @params.oscillator_octave.value) \
		      + (@params.oscillator_detune.value)
		return music.hz cents

	noteOn: (note) ->
		unless note of @_notes
			debug.logNote on, this, note
			n = @_notes[note] = {}

			debug.logComponent this, 'Create OSC'
			n.osc = osc = new Oscillator @ctx
			for p in ['gain', 'detune', 'attack', 'decay', 'sustain', 'release']
				@params["oscillator_#{p}"].connect osc.params[p]
			osc.outputs.out.connect @_out.inputs.in

			debug.logComponent this, 'Create MOD'
			n.mod = mod = new Oscillator @ctx
			for p in ['gain', 'frequency', 'attack', 'decay', 'sustain', 'release']
				@params["modulation_#{p}"].connect mod.params[p]
			mod.outputs.out.connect osc.inputs.mod

			mod.trigger on, @params.modulation_frequency.value
			osc.trigger on, @frequency note

	noteOff: (note) ->
		if block = @_notes[note]
			debug.logNote off, this, note
			{osc, mod} = block
			osc.trigger off
			mod.trigger off
			for p in ['gain', 'frequency']
				@params["modulation_#{p}"].disconnect mod.params[p]
			for p in ['gain', 'detune', 'attack', 'decay', 'sustain', 'release']
				@params["oscillator_#{p}"].disconnect osc.params[p]
			# REVIEW: We're probably leaking memory here with either
			#         an osc that remains connected or unreleased params.
			delete @_notes[note]

	trigger: (note, state) ->
		if state is on
			@noteOn note
		else if state is off
			@noteOff note

