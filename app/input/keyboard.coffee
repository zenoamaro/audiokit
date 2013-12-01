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
		document.body.addEventListener 'keydown', @onKeyDown
		document.body.addEventListener 'keyup', @onKeyUp

	connect: (node) ->
		@_connections = _.unique @_connections.concat(node)

	disconnect: (node) ->
		@_connections = _.without @_connections, (p) -> p is node

	noteFromKeycode: (keycode) ->
		asc = (String.fromCharCode event.which).toLowerCase()
		NOTE_MAP[asc] or NOTE_MAP[keycode]

	trigger: (note, state) ->
		for conn in @_connections
			conn.trigger note, state

	onKeyDown: (event) =>
		note = @noteFromKeycode event.which
		if note then @trigger note, on
		return false

	onKeyUp: (event) =>
		note = @noteFromKeycode event.which
		if note then @trigger note, off
		return false
