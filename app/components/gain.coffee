Component = require 'core/component'


module.exports = class Gain extends Component

	defaults:
		gain: 1

	initialize: (ctx, options) ->
		@initializeInputs()
		@initializeOutputs()
		@_amp = @ctx.createGain()

	update: ->
		@_amp.gain.value = @options.gain

	initializeInputs: ->
		@inputs.push
			id: 'in'
			node: => @_amp
		@inputs.push
			id: 'gain'
			node: => @_amp.gain

	initializeOutputs: ->
		@outputs.push
			id: 'out'
			node: => @_amp
