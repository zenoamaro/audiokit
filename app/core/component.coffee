u = require 'utils'
Class = require 'core/class'
{Pin, InputPin, OutputPin, Param} = require 'core/connections'


module.exports = class Component extends Class

	inputs: {}
	outputs: {}
	params: {}

	constructor: (ctx, options) ->
		@ctx = ctx
		super options
		@preparePins()
		@prepareConnections?()
		@set options

	preparePins: ->
		pinTypes =
			input: InputPin
			output: OutputPin
			param: Param

		for type in _.keys pinTypes
			pins = {}
			property = "#{type}s"

			for id, pin of @[property]
				pins[id] = new pinTypes[pin.type or type]
					id: id
					label: pin.label
					parent: this
					source: pin.source
					default: pin.default
			@[property] = pins

	set: (options={}) ->
		for p, v of options
			@params[p].value = v
