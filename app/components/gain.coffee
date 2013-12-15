Component = require 'core/component'


module.exports = class Gain extends Component

	inputs:
		in:
			label: 'Input'
			source: -> @_amp

	outputs:
		out:
			label: 'Output'
			source: -> @_amp

	defaults:
		gain: 1

	initialize: (ctx, options) ->
		@_amp = @ctx.createGain()

	update: ->
		@_amp.gain.value = @options.gain
