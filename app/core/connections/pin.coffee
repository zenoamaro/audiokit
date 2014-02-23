u = require 'utils'
debug = require 'utils/debug'


module.exports = class Pin

	type: 'pin'
	emulated: no

	constructor: (options) ->
		Object.defineProperty this, 'source',
			get: @_getSource
			set: @_setSource
		@parent   = options.parent
		@ctx      = options.ctx ? @parent.ctx
		@id       = options.id
		@label    = options.label ? options.id
		@type     = options.type ? @type
		@internal = options.internal
		@_source  = options.source
		@inbound  = []
		@outbound = []
		debugger unless @type

	_getSource: =>
		source = @_source.call @parent
		source?.source ? source
	_setSource: (source) =>
		@_source = source

	isConnectedTo: (pin) ->
		_.contains @outbound, pin
	connect: (pin) ->
		unless @isConnectedTo pin
			debug.logPinConnection on, this, pin
			@outbound.push pin
			pin.connectFrom this
			@_connectSource? pin
	disconnect: (pin='all') ->
		if pin is 'all'
			_.each @outbound, (pin) => @disconnect pin
		else if @isConnectedTo pin
			debug.logPinConnection off, this, pin
			@_disconnectSource? pin
			@outbound = _.without @outbound, pin
			pin.disconnectFrom this

	isConnectedFrom: (pin) ->
		_.contains @inbound, pin
	connectFrom: (pin) ->
		unless @isConnectedFrom pin
			@inbound.push pin
			pin.connect this
	disconnectFrom: (pin='all') =>
		if pin is 'all'
			_.invoke @inbound, @disconnect
		else if @isConnectedFrom pin
			@inbound = _.without @inbound, pin
			pin.disconnect this
