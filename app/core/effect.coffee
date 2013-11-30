Node = require 'core/node'


module.exports = class Effect extends Node

	connect: (target) ->
		@output.connect target

	create_master_gain: ->
		@master_gain = @ctx.createGain()
		@output = @master_gain

	create_master_mix: ->
		@master_gain = @ctx.createGain()
		@output = @master_gain

	trigger: (note) ->
		@currentNote = note

	note: (note) ->
		if match = NOTATION.exec note
			[match, note, octave] = match
			octave = (parseInt octave, 10) - 4
			note = NOTES[note.toLowerCase()]
			return (100 * note) + @octaves octave
		else
			no
	hz: (cents) -> ROOT * Math.pow (Math.pow 2, 1/OCTAVE), cents
	octaves: (oct) -> OCTAVE * oct
