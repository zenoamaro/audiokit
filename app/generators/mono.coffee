music = require 'core/music'
Gain = require 'components/gain'
Oscillator = require 'components/oscillator'
Envelope = require 'components/envelope'
Generator = require 'core/generator'


module.exports = class MonoOsc extends Generator

	defaults:
		out: {}
		modulation:
			shape: 'triangle'
			gain: 0
			frequency: 10
		oscillator:
			shape: 'triangle'
			octave: 0
			tune: 0

	initialize: ->
		super

	update: ->
		super
		for note, nodes of @_notes
			nodes.osc.set @options.oscillator
			nodes.mod.set @options.modulation

	frequency: (note) ->
		cents = (music.note note) \
		      + (music.octaves @options.oscillator.octave) \
		      + (@options.oscillator.tune)
		return music.hz cents

	noteOn: (note) ->
		unless note of @_notes
			@_notes[note] =
				osc: osc = new Oscillator @ctx
				mod: mod = new Oscillator @ctx
			@update()
			mod.trigger on, @options.modulation.frequency
			osc.trigger on, @frequency note
			mod.outputs.out.connect osc.inputs.mod
			osc.outputs.out.connect @_out.inputs.in

	noteOff: (note) ->
		if block = @_notes[note]
			{osc, mod} = block
			osc.trigger off
			mod.trigger off
			delete @_notes[note]

	trigger: (note, state) ->
		if state is on
			@noteOn note
		else if state is off
			@noteOff note

