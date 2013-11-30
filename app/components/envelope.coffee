Component = require 'core/component'


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
			param.value = 0
			param.setValueAtTime 0, @ctx.currentTime

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
			@cancel param
			if value is on
				param.linearRampToValueAtTime 1, now + @options.attack
				param.linearRampToValueAtTime @options.sustain, now + @options.attack + @options.decay
			else if value is off
				param.setValueAtTime @options.sustain, now
				param.linearRampToValueAtTime 0, now + @options.release

	initializeOutputs: ->
		@outputs.push
			id: 'out'
			node: => @param

	connect: (param) ->
		@_connections = _.unique @_connections.concat(param)
		@reset param

	disconnect: (param) ->
		@_connections = _.without @_connections, (p) -> p is param