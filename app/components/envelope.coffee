music = require 'core/music'
Component = require 'core/component'

KILL_TIME = .002
DECAY_SEEK_TIME = .1


module.exports = class Envelope extends Component

	defaults:
		attack: .01
		decay: .01
		sustain: 1
		release: .01

	initialize: ->
		@_connections = []
		@initializeOutputs()

	reset: (param) ->
		unless param
			for param in @_connections
				@reset param
		else
			@cancel param
			param.linearRampToValueAtTime 0, @ctx.currentTime + KILL_TIME

	cancel: (param) ->
		unless param
			for param in @_connections
				@cancel param
		else
			now = @ctx.currentTime
			param.cancelScheduledValues now
			param.setValueAtTime param.value, now

	trigger: (value=on) ->
		now = @ctx.currentTime
		for param in @_connections
			if value is on
				param.linearRampToValueAtTime 1, now + KILL_TIME + @options.attack
				param.setTargetAtTime @options.sustain, now + KILL_TIME + @options.attack, @options.decay * music.EXP_FALL
			else if value is off
				@cancel param
				if param.value > @options.sustain
					decay_seeker = Math.min(@options.decay, DECAY_SEEK_TIME)
				else
					decay_seeker = 0
				param.setTargetAtTime @options.sustain, now, decay_seeker * music.EXP_FALL
				param.setTargetAtTime 0, now + decay_seeker, @options.release * music.EXP_FALL

	initializeOutputs: ->
		@outputs.push
			id: 'out'
			node: => @param

	connect: (param) ->
		@_connections = _.unique @_connections.concat(param)
		@reset param

	disconnect: (param) ->
		@_connections = _.without @_connections, (p) -> p is param