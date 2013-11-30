Node = require 'core/node'
Gain = require 'components/gain'


module.exports = class Effect extends Node

	defaults:
		level: 1
		gain: 1
		wet: 1

	initialize: ->
		@initializeInputs()
		@initializeOutputs()
		@_in = new Gain @ctx
		@_out = new Gain @ctx

	initializeInputs: ->
		@outputs.push
			id:   'in'
			node: => @_in.input().node()

	initializeOutputs: ->
		@outputs.push
			id:   'out'
			node: => @_out.output().node()

	update: ->
		@_in.set  gain:@options.level
		@_out.set gain:@options.gain
