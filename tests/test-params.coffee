Param = require 'core/connections/param'
EmulatedAudioParam = require 'core/connections/emulated-audio-param'
ctx = new (window.AudioContext ? window.webkitAudioContext)


describe 'Parameters', ->

	describe 'should encapsulate', ->

		it 'a native AudioParam when provided', ->
			gain = ctx.createGain()
			param = new Param
				ctx: ctx
				source: -> gain.gain
			(not param.isEmulated).should.be.true
			(param.source instanceof AudioParam).should.be.true
			param.source.should.equal gain.gain

		it 'an emulated AudioParam as fallback', ->
			param = new Param
				ctx: ctx
			param.isEmulated.should.be.true
			(param.source instanceof EmulatedAudioParam).should.be.true

	describe 'value', ->

		it 'can be read', ->
			gain = ctx.createGain()
			param = new Param
				ctx: ctx
				clickFree: no
				source: -> gain.gain
			param.value.should.equal param.source.value

		it 'should be synced to the source parameter', ->
			gain = ctx.createGain()
			param = new Param
				ctx: ctx
				clickFree: no
				source: -> gain.gain
			param.source.value = 5
			param.value.should.equal 5
			param.value.should.equal param.source.value

		it 'can be preset using a default', ->
			gain = ctx.createGain()
			below = new Param
				ctx: ctx
				clickFree: no
				default: -15
				source: -> gain.gain
			below.value.should.equal -15

			gain = ctx.createGain()
			above = new Param
				ctx: ctx
				clickFree: no
				default: 15
				source: -> gain.gain
			above.value.should.equal 15

		describe 'should respect set min and max values', ->

			it 'when set manually', ->
				gain = ctx.createGain()
				param = new Param
					ctx: ctx
					clickFree: no
					min: 0
					max: 10
					source: -> gain.gain
				param.value = -1; param.value.should.equal 0
				param.value = 20; param.value.should.equal 10

			it 'when defaulting', ->
				gain = ctx.createGain()
				below = new Param
					ctx: ctx
					clickFree: no
					default: 0
					min: 3, max: 7
					source: -> gain.gain
				below.value.should.equal 3

				gain = ctx.createGain()
				above = new Param
					ctx: ctx
					clickFree: no
					default: 10
					min: 3, max: 7
					source: -> gain.gain
				above.value.should.equal 7

		describe 'can be wrote to', ->

			it 'syncing with the source', ->
				gain = ctx.createGain()
				param = new Param
					ctx: ctx
					clickFree: no
					source: -> gain.gain
				param.value = 5
				param.source.value.should.equal 5

			it 'propagating to connected params', ->
				mainGain = ctx.createGain()
				dependentGain = ctx.createGain()
				main = new Param
					ctx: ctx
					clickFree: no
					source: -> mainGain.gain
				dependent = new Param
					ctx: ctx
					clickFree: no
					source: -> dependentGain.gain
				main.connect dependent
				main.value = 5
				dependent.value.should.equal 5
				mainGain.gain.value.should.equal dependentGain.gain.value

			it 'ramping to prevent clicks', (done) ->
				# Note that native events will occur only when a fully
				# connected configuration is running.
				osc = ctx.createOscillator()
				gain = ctx.createGain()
				osc.connect gain
				gain.connect ctx.destination
				osc.start()
				param = new Param
					ctx: ctx
					source: -> gain.gain
				param.value = 0
				param.value.should.equal 1
				# Note that we can't be *that* precise in measuring
				# using timeouts.
				setTimeout (-> param.value.should.equal 0; done()), 100


