Class = require 'core/class'


NOTE_MAP =
	z: 'c5'
	s: 'c#5'
	x: 'd5'
	d: 'd#5'
	c: 'e5'
	v: 'f5'
	g: 'f#5'
	b: 'g5'
	h: 'g#5'
	n: 'a5'
	j: 'a#5'
	m: 'b5'


module.exports = class Keyboard extends Class

	defaults: {}

	initialize: ->
		@_connections = []
		@_notes = {}
		document.body.addEventListener 'keydown', @onKeyDown
		document.body.addEventListener 'keyup', @onKeyUp

	connect: (node) ->
		@_connections = _.unique @_connections.concat(node)

	disconnect: (node) ->
		@_connections = _.without @_connections, (p) -> p is node

	noteFromKey: (keycode) ->
		NOTE_MAP[ (String.fromCharCode event.which).toLowerCase() ]

	onKeyDown: (event) =>
		for conn in @_connections
			note = @noteFromKey event.which
			if note and (note not of @_notes)
				conn.trigger note
				@_notes[note] = conn
		return false

	onKeyUp: (event) =>
		for conn in @_connections
			note = @noteFromKey event.which
			if conn = @_notes[note]
				conn.trigger off
			delete @_notes[note]
		return false
