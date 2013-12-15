Node = require 'core/node'
Gain = require 'components/gain'


module.exports = class Generator extends Node

	outputs:
		out:
			label: 'Output'
			source: -> @_out.outputs.out.getSource()

	defaults:
		out: {}

	initialize: ->
		@_notes = {}
		@_out = new Gain @ctx

	update: ->
		@_out.set @options.out

	trigger: (note) ->
