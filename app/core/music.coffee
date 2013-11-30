ROOT     = 261.63
OCTAVE   = 1200
K        = OCTAVE / (Math.log 2 / Math.LN10)
NOTATION = /(\w#?)(\d+)/
NOTES    = 'c':0, 'c#':1, 'd':2, 'd#':3, 'e':4, 'f':5, 'f#':6, 'g':7, 'g#':8, 'a':9, 'a#':10, 'b':11

module.exports = music =

	note: (note) ->
		if match = NOTATION.exec note
			[match, note, octave] = match
			octave = (parseInt octave, 10) - 4
			note = NOTES[note.toLowerCase()]
			return (100 * note) + music.octaves octave
		else
			no

	hz: (cents) ->
		ROOT * Math.pow (Math.pow 2, 1/OCTAVE), cents

	octaves: (oct) ->
		OCTAVE * oct
