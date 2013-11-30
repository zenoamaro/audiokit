Gain = require 'components/gain'


module.exports = class Master extends Gain

	initialize: ->
		super
		@_amp.connect @ctx.destination
