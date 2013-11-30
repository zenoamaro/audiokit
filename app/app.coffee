Master = require 'components/master'
MonoOsc = require 'generators/mono'


@ctx = new (AudioContext ? webkitAudioContext)

@osc = new MonoOsc ctx,
	oscillator:
		envelope:
			sustain: .1
@master = new Master ctx
osc.connect to:master

@note = (note) ->
	osc.trigger note

setTimeout (-> note 'c4'),  0
setTimeout (-> note 'c#4'), 500
setTimeout (-> note 'e4'),  1000
setTimeout (-> note 'f4'),  1500
setTimeout (-> note 'g4'),  2000
setTimeout (-> note 'g#4'),  2500
setTimeout (-> note 'g4'),  3000
setTimeout (-> note 'f4'),  3500
setTimeout (-> note 'e4'),  4000
setTimeout (-> note off),  4500
setTimeout (-> note 'e4'),  5000
setTimeout (-> note off),  5500
