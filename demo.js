;(function(){

	var Master = require('components/master');
	var MonoOsc = require('generators/mono');
	var Keyboard = require('input/keyboard');

	window.ctx = new (AudioContext || webkitAudioContext || mozAudioContext || msAudioContext);
	window.master = new Master(ctx);

	window.osc = new MonoOsc(ctx, {
		oscillator: {
			shape: 'triangle',
			octave: -2,
			envelope: {
				attack: .001,
				decay: .1,
				sustain: .2,
				release: .05,
			},
		},
		modulation: {
			gain: 40,
			frequency: 6,
			envelope: {
				attack: 2,
				decay: 0,
				sustain: 1,
				release: 1,
			},
		},
	});
	osc.connect({ to:master });


	window.keyboard = new Keyboard();
	keyboard.connect(osc);

})();