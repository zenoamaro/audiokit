Node = require 'core/node'
Gain = require 'components/gain'


module.exports = class Generator extends Node

	defaults:
		out: {}

	initialize: ->
		@_notes = {}
		@initializeOutputs()
		@_out = new Gain @ctx

	initializeOutputs: ->
		@outputs.push
			id:   'out'
			node: => @_out.output().node()

	update: ->
		@_out.set @options.out

	trigger: (note) ->
