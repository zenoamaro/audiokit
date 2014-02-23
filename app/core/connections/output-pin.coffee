u = require 'utils'
Pin = require 'core/connections/pin'


module.exports = class OutputPin extends Pin

	constructor: (options) ->
		@type = 'output'
		super options

	connect: (pin) ->
		if pin.type not in ['input', 'param']
			throw 'Output pins can only be connect to params or inputs'
		super

	connectFrom: (pin) ->
		throw 'Output pins do not accept connections'

	_connectSource: (pin) ->
		@source.connect pin.source

	_disconnectSource: (pin) ->
		@source.disconnect pin.source


