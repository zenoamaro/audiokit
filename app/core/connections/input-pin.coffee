u = require 'utils'
Pin = require 'core/connections/pin'


module.exports = class InputPin extends Pin

	constructor: (options) ->
		@type = 'input'
		super options

	connect: (pin) ->
		throw 'Input pins cannot make connections'

	connectFrom: (pin) ->
		if pin.type isnt 'output'
			throw 'Input pins only accept connections from outputs'
		super
