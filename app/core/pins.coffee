class Pin

	constructor: (options) ->
		@id = options.id
		@label = options.label or options.id
		@type = options.type
		@source = options.source
		@parent = options.parent
		@connections = []

	isConnectedTo: (pin) ->
		_.contains @connections, pin

	connect: (pin) ->
		unless @isConnectedTo pin
			@_connectSource? pin
			@connections.push pin
			pin.connect this

	disconnect: (pin='all') =>
		if pin is 'all'
			_.invoke @connections, @disconnect
		else if @isConnectedTo pin
			@_disconnectSource? pin
			@connections = _.without @connections, pin
			pin.disconnect this

	getSource: ->
		@source.call @parent


class OutputPin extends Pin
	costructor: (options) ->
		options.type = 'output'
		super options
	connect: (pin) ->
		if pin.type is 'output'
			throw 'Cannot connect to other outputs'
		else
			super
	_connectSource: (pin) ->
		@getSource().connect pin.getSource()
	_disconnectSource: (pin) ->
		@getSource().disconnect pin.getSource()


class InputPin extends Pin
	costructor: (options) ->
		options.type = 'input'
		super options
	connect: (pin) ->
		if pin.type is 'input'
			throw 'Cannot connect to other inputs'
		else
			super


class Param extends Pin
	costructor: (options) ->
		options.type = 'param'
		super options


module.exports =
	Pin:       Pin
	InputPin:  InputPin
	OutputPin: OutputPin
	Param:     Param