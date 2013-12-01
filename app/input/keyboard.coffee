Class = require 'core/class'


NOTE_MAP =
	27: 'stop'
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
		asc = (String.fromCharCode event.which).toLowerCase()
		NOTE_MAP[asc] or NOTE_MAP[keycode]

	kill: ->
		for conn in @_connections
			conn.trigger off

	trigger: (state, note) ->
		for conn in @_connections
			if state
				if note not of @_notes
					conn.trigger note
					@_notes[note] = yes
			else
				conn.trigger off, note
				delete @_notes[note]

	onKeyDown: (event) =>
		note = @noteFromKey event.which
		if note then @trigger on, note
		return false

	onKeyUp: (event) =>
		if note = @noteFromKey event.which
			if note is 'stop'
				@trigger off
			else if note of @_notes
				@trigger off, note
		return false
