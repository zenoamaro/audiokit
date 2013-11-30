Node = require 'core/generator'


module.exports = class MonoOsc extends Generator

	defaults:
		modulation:
			shape: 'sine'
			frequency: 5
			amplitude: 0
		oscillator:
			shape: 'sine'
			gain: 1
			octave: 0
			tune: 0
			attack: .1
			release: .5

	start: (options) ->
		@startModulator()
		@startOscillator()
		@initialize options
		@osc_amp.connect @out
	stop: ->
		stopModulator()
		stopOscillator()
	initialize: (options) ->
		super
		@initializeModulator  @options.modulation
		@initializeOscillator @options.oscillator
		@note @currentNote

	startOscillator: ->
		@osc = @ctx.createOscillator()
		@osc_env = @ctx.createGain()
		@osc_amp = @ctx.createGain()
		@osc.connect @osc_env
		@osc_env.connect @osc_amp
		@osc.start()
		@trigger off
	stopOscillator: ->
		@osc.stop()
	initializeOscillator: (options) ->
		@osc.type = options.shape
		@osc_amp.gain.value = options.gain
		@mod_amp.connect @osc.frequency
	envelope: ->
		now = @ctx.currentTime
		@osc_env.gain.cancelScheduledValues now
		@osc_env.gain.setValueAtTime 0, now
		@osc_env.gain.linearRampToValueAtTime 1, now + @options.oscillator.attack
		@osc_env.gain.linearRampToValueAtTime 0, now + @options.oscillator.attack + @options.oscillator.release

	startModulator: ->
		@mod = @ctx.createOscillator()
		@mod_amp = @ctx.createGain()
		@mod.connect @mod_amp
		@mod.start()
	stopModulator: ->
		@mod.stop()
	initializeModulator: (options) ->
		@mod.type = options.shape
		@mod.frequency.value = options.frequency
		@mod_amp.gain.value = options.amplitude

	connect: (target) ->
		@osc_amp.connect target

	trigger: (note) ->
		super
		if note isnt off
			@osc.frequency.value = @hz note + (@octaves @options.oscillator.octave) + @options.oscillator.tune
			@envelope()
		else
			@osc_env.gain.value = 0

