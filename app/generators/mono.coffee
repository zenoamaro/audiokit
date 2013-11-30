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
		@_osc = new Oscillator @ctx
		@_mod = new Oscillator @ctx
		@_osc.connect to:@_out
		@_mod.connect to:@_osc, toPin:'mod'

	update: ->
		super
		@_osc.set @options.oscillator
		@_mod.set @options.modulation

	trigger: (note) ->
		if note isnt off
			if _.isString note
				note = music.hz music.note note
			freq = note \
				 + (music.octaves @options.oscillator.octave) \
				 + (@options.oscillator.tune)
			@_osc.trigger on, freq
			@_mod.trigger on, @options.modulation.frequency
		else
			@_osc.trigger off
			@_mod.trigger off

