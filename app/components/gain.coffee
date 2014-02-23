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

	params:
		gain:
			label: 'Gain'
			default: 1
			source: -> @_amp.gain

	initialize: (ctx, options) ->
		@_amp = @ctx.createGain()
