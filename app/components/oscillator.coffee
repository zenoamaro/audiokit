Component = require 'core/component'
Envelope = require 'components/envelope'


module.exports = class Oscillator extends Component

	defaults:
		shape: 'sine'
		gain: 1
		envelope:
			attack: .01
			decay: .1
			sustain: .1
			release: .01

	initialize: ->
		@initializeInputs()
		@initializeOutputs()
		@_out = @ctx.createGain()
		@_amp = @ctx.createGain()
		@_mod = @ctx.createGain()
		@_env = new Envelope @ctx
		@_amp.connect @_out

	initializeOscillator: ->
		unless @_osc
			@_osc = @ctx.createOscillator()
			@_osc.connect @_amp
			@_env.connect @_amp.gain
			@_mod.connect @_osc.frequency
			@_osc.start()
			@_env.reset()
	disposeOscillator: (release) ->
		if @_osc
			# Note: We don't disconnect outputs
			# as they will die, eventually
			@_mod.disconnect @_osc.frequency
			@_env.disconnect()
			@_osc.stop @ctx.currentTime + release
			@_osc = no

	trigger: (state, freq) ->
		if state is on
			@initializeOscillator(); @update()
			@_osc.frequency.setValueAtTime freq, @ctx.currentTime
			@_env.trigger on
		else if state is off
			@_env.trigger off
			@disposeOscillator @_env.options.release

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
