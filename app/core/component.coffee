Class = require 'core/class'


module.exports = class Component extends Class

	constructor: (ctx, options) ->
		@ctx = ctx
		@inputs = []
		@outputs = []
		super options

	input: (id='in') ->
		_.find @inputs, (input) -> input.id is id

	output: (id='out') ->
		_.find @outputs, (output) -> output.id is id

	connect: (options) ->
		dest = options.to
		fromPin = @output options.fromPin
		toPin = dest.input options.toPin
		fromPin.node().connect toPin.node()

	disconnect: (options) ->
		dest = options.to
		fromPin = @output options.fromPin
		toPin = dest.input options.toPin
		fromPin.node().disconnect toPin.node()

	set: (options) ->
		super
		@update()

	update: ->
