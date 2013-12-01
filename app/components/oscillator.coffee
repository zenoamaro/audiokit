Component = require 'core/component'
Envelope = require 'components/envelope'

KILL_TIME = .002
MIN_RELEASE_TIME = 2 # FIXME: this should really not be hardcoded


module.exports = class Oscillator extends Component

	defaults:
		shape: 'sine'
		gain: 1
		envelope:
			attack: .001
			decay: .1
			sustain: .2
			release: .001

	initialize: ->
		@initializeInputs()
		@initializeOutputs()
		@_out = @ctx.createGain()
		@_amp = @ctx.createGain()
		@_mod = @ctx.createGain()
		@_env = new Envelope @ctx
		@_amp.gain.value = 0
		@_env.connect @_amp.gain
		@_amp.connect @_out


	startOscillator: ->
		if @_osc
			clearTimeout @_oscStopTimer
		unless @_osc
			@_osc = @ctx.createOscillator()
			@_osc.connect @_amp
			@_mod.connect @_osc.detune
			@_osc.start 0
		@_env.reset()

	stopOscillator: (release) ->
		unless @_osc
			return
		stop = =>
			@_mod.disconnect @_osc.detune
			@_osc.disconnect @_amp
			@_osc.stop 0
			@_osc = no
		clearTimeout @_oscStopTimer
		@_oscStopTimer = setTimeout stop, (Math.max MIN_RELEASE_TIME, release) * 1000

	trigger: (state, freq) ->
		if state is on
			@startOscillator(); @update()
			@_osc.frequency.setValueAtTime freq, @ctx.currentTime + KILL_TIME
			@_env.trigger on
		else if state is off
			@_env.trigger off
			@stopOscillator @_env.options.release

	update: ->
		@_osc?.type = @options.shape
		@_env.set @options.envelope
		@_out.gain.setValueAtTime @options.gain, @ctx.currentTime

	initializeInputs: ->
		@inputs.push
			id: 'gain'
			node: => @_amp.gain
		@inputs.push
			id: 'mod'
			node: => @_mod

	initializeOutputs: ->
		@outputs.push
			id: 'out'
			node: => @_out
