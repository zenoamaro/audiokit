Node = require 'core/node'
Gain = require 'components/gain'


module.exports = class Generator extends Node

	outputs:
		out: => @_out.outputs.out

	initialize: ->
		@_notes = {}
		@_out = new Gain @ctx

	trigger: (note) ->
