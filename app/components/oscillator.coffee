u = require 'utils'
debug = require 'utils/debug'
Component = require 'core/component'
Envelope = require 'components/envelope'
Param = require 'core/connections/param'

KILL_TIME = .002
MIN_RELEASE_TIME = 2 # FIXME: this should really not be hardcoded


module.exports = class Oscillator extends Component

	inputs:
		mod:
			label: 'Modulation'
			source: -> @_mod

	outputs:
		out:
			label: 'Output'
			source: -> @_out

	params:
		envelope:
			internal: yes
			source: -> @_amp.gain
		gain:
			label: 'Gain'
			default: 1
			source: -> @_out.gain
		frequency:
			label: 'Frequency'
			default: 0
		detune:
			label: 'Detune'
			default: 0

		attack:
			label: 'Attack'
			default: .1
			source: -> @_env.params.attack
		decay:
			label: 'Decay'
			default: .2
			source: -> @_env.params.decay
		sustain:
			label: 'Sustain'
			default: .2
			source: -> @_env.params.sustain
		release:
			label: 'Release'
			default: 1
			source: -> @_env.params.release

	initialize: ->
		@_out = @ctx.createGain()
		@_amp = @ctx.createGain()
		@_mod = @ctx.createGain()
		@_env = new Envelope @ctx
		@_amp.gain.value = 0

	prepareConnections: ->
		@_env.outputs.target.connect @params.envelope
		@_amp.connect @_out

	startOscillator: ->
		if @_osc
			clearTimeout @_oscStopTimer
		unless @_osc
			debug.logComponent this, 'Start voice'
			@_osc = @ctx.createOscillator()
			@_osc.connect @_amp
			@_mod.connect @_osc.detune
			@_osc.start 0
			for p in ['frequency', 'detune'] then do (p) =>
				param = @["_osc_#{p}"] = new Param
					id: "_osc_#{p}"
					parent: this
					internal: yes
					source: => @_osc[p]
				@params[p].connect param
		@_env.reset()

	stopOscillator: (release) ->
		unless @_osc
			return
		@_osc.onended = =>
			debug.logComponent this, 'Stop voice'
			for p in ['frequency', 'detune']
				@["_osc_#{p}"].disconnect()
			@_mod.disconnect()
			@_osc.disconnect()
			@_osc = no
		@_osc.stop @ctx.currentTime + 1 + Math.max MIN_RELEASE_TIME, release

	trigger: (state, freq) ->
		debug.debugArguments arguments
		debug.logNote state, this, freq
		if state is on
			@startOscillator()
			@_osc.type = 'sine'
			@params.frequency.value = freq
			@_env.trigger on
		else if state is off
			@_env.trigger off
			@stopOscillator @params.release.value
