Component = require 'core/component'
Envelope = require 'components/envelope'


module.exports = class Oscillator extends Component

	defaults:
		shape: 'sine'
		gain: 1
		envelope:
			attack: .01
			decay: .1
			sustain: .2
			release: .01

	initialize: ->
		@initializeInputs()
		@initializeOutputs()
		@_out = @ctx.createGain()
		@_amp = @ctx.createGain()
		@_mod = @ctx.createGain()
		@_env = new Envelope @ctx
		@_env.reset()
		@_env.connect @_amp.gain
		@_amp.connect @_out


	initializeOscillator: ->
		if @_osc_status is 'release'
			@killOscillator()
		unless @_osc
			@_mod.disconnect(); clearTimeout @_mod_stop_timer
			@_env.disconnect(); clearTimeout @_env_stop_timer
			@_osc = @ctx.createOscillator()
			@_osc.connect @_amp
			@_mod.connect @_osc.detune
			@_osc.start()
		@_env.reset()

	disposeOscillator: (release) ->
		if @_osc
			# REVIEW: Is this a good way to disconnect the mod?
			#         We need to dispose of all the stuff connected to the osc
			@_osc_stop_timer = setTimeout (=> @killOscillator()), (release * 1000)
			# @_mod_stop_timer = setTimeout (=> ((pin) => @_mod.disconnect pin))(@_osc.detune), (release * 1000)
			# @_env_stop_timer = setTimeout (=> ((pin) => @_env.disconnect osc))(@_amp.gain), (release * 1000)
			# NOTE: We don't disconnect outputs
			#       as they will die by themselves, eventually
			try
				@_osc.stop @ctx.currentTime + release
			catch ex
				no
			@_osc_status = 'release'

	killOscillator: ->
		@_env.reset()
		@_mod.disconnect @_amp.gain; clearTimeout @_mod_stop_timer
		if @_osc
			@_env.disconnect @_osc.detune; clearTimeout @_env_stop_timer
			@_osc.disconnect @_amp; clearTimeout @_osc_stop_timer
			try
				@_osc?.stop()
			catch ex
				no
		@_osc = null
		@_osc_status = null


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
