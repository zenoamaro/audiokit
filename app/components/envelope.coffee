u = require 'utils'
debug = require 'utils/debug'
music = require 'core/music'
Component = require 'core/component'

DECAY_SEEK_TIME = .1


module.exports = class Envelope extends Component

	outputs:
		target:
			type: 'param'
			internal: yes

	params:
		attack:
			label: 'Attack'
			default: .1
		decay:
			label: 'Decay'
			default: .2
		sustain:
			label: 'Sustain'
			default: .2
		release:
			label: 'Release'
			default: 1

	prepareConnections: ->
		@target = @outputs.target

	reset: -> @target.reset arguments...
	cancel: -> @target.reset arguments...

	trigger: (value=on) ->
		{attack, decay, sustain, release} = @params
		if value is on
			debug.logComponent this, "Start envelope, a=#{attack.value}, d=#{decay.value}, s=#{sustain.value}, r=#{release.value}"
			@target.ramp 1, attack.value
			@target.approach sustain.value, decay.value * music.EXP_FALL, attack.value
		else if value is off
			debug.logComponent this, "Stop envelope, r=#{release.value}"
			@target.cancel()
			if @target.value > sustain.value
				decay_seeker = Math.min(decay.value, DECAY_SEEK_TIME)
			else
				decay_seeker = 0
			decay_seeker = Math.min(decay.value, DECAY_SEEK_TIME)
			@target.approach sustain.value, decay_seeker * music.EXP_FALL, 0
			@target.approach 0, release.value * music.EXP_FALL, decay_seeker * music.EXP_FALL
