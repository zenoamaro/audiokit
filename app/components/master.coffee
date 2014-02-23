Gain = require 'components/gain'


module.exports = class Master extends Gain

	prepareConnections: ->
		@_amp.connect @ctx.destination
