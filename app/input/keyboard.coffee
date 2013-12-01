Class = require 'core/class'


# FIXME: This is probably only valid for an italian keymap.
#        Problem is, there's no way to accurately distinguish
#        some keycodes from others in certain keymaps.

NOTE_MAP =
	# Lower
	'U+003C': 'b4'
	'U+005A': 'c5'
	'U+0053': 'c#5'
	'U+0058': 'd5'
	'U+0044': 'd#5'
	'U+0043': 'e5'
	'U+0056': 'f5'
	'U+0047': 'f#5'
	'U+0042': 'g5'
	'U+0048': 'g#5'
	'U+004E': 'a5'
	'U+004A': 'a#5'
	'U+004D': 'b5'
	'U+002C': 'c6'
	'U+004C': 'c#6'
	'U+002E': 'd6'
	'U+00F2': 'd#6'
	'U+002D': 'e6'
	# Upper
	'U+0051': 'c6'
	'U+0032': 'c#6'
	'U+0057': 'd6'
	'U+0033': 'd#6'
	'U+0045': 'e6'
	'U+0052': 'f6'
	'U+0035': 'f#6'
	'U+0054': 'g6'
	'U+0036': 'g#6'
	'U+0059': 'a6'
	'U+0037': 'a#6'
	'U+0055': 'b6'
	'U+0049': 'c7'
	'U+0039': 'c#7'
	'U+004F': 'd7'
	'U+0030': 'd#7'
	'U+0050': 'e7'
	'U+00E8': 'f7'
	'U+00EC': 'f#7'
	'U+002B': 'g7'

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
		NOTE_MAP[keycode]

	trigger: (note, state) ->
		for conn in @_connections
			conn.trigger note, state

	onKeyDown: (event) =>
		note = @noteFromKeycode event.keyIdentifier
		if note then @trigger note, on
		return false

	onKeyUp: (event) =>
		note = @noteFromKeycode event.keyIdentifier
		if note then @trigger note, off
		return false
