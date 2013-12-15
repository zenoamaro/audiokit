Class = require 'core/class'
{InputPin, OutputPin} = require 'core/pins'


module.exports = class Component extends Class

	inputs: {}
	outputs: {}

	constructor: (ctx, options) ->
		@ctx = ctx
		@preparePins()
		super options

	preparePins: ->
		for type in ['input', 'output']
			property = "#{type}s"
			pins = {}
			for id, pin of @[property]
				PinType = if type is 'input' then InputPin else OutputPin
				pins[id] = new PinType
					id: id
					type: type
					label: pin.label
					source: pin.source
					parent: this
			@[property] = pins

	set: (options) ->
		super
		@update()

	update: ->
