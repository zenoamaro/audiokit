Pin = require 'core/connections/pin'
InputPin = require 'core/connections/input-pin'
OutputPin = require 'core/connections/output-pin'
ctx = new (window.AudioContext ? window.webkitAudioContext)


describe 'Pins', ->

	it 'should encapsulate a native pin', ->
		gain = ctx.createGain()
		pin = new Pin
			ctx: ctx
			source: -> gain
		(pin.source instanceof AudioNode).should.be.true
		pin.source.should.equal gain

	describe 'can be connected to other pins', ->
		pIn = pOut = null

		beforeEach ->
			pIn = new Pin
				ctx: ctx
				source: -> ctx.createGain()
			pOut = new Pin
				ctx: ctx
				source: -> ctx.createGain()

		it 'once', ->
			pOut.connect pIn
			(pOut.isConnectedTo pIn).should.be.true
			(pIn.isConnectedFrom pOut).should.be.true
			pIn.inbound.length.should.equal 1
			pOut.outbound.length.should.equal 1

		it 'only once', ->
			pOut.connect pIn
			pOut.connect pIn
			pIn.inbound.length.should.equal 1
			pOut.outbound.length.should.equal 1

		it 'from both sides', ->
			pOut.connect pIn
			(pOut.isConnectedTo pIn).should.be.true
			(pIn.isConnectedFrom pOut).should.be.true
			pIn.inbound.length.should.equal 1
			pOut.outbound.length.should.equal 1

		it 'and disconnected', ->
			pOut.connect pIn
			pOut.disconnect pIn
			(pOut.isConnectedTo pIn).should.be.false
			(pIn.isConnectedFrom pOut).should.be.false
			pIn.inbound.length.should.equal 0
			pOut.outbound.length.should.equal 0

		it 'and disconnected in batch', ->
			pOut.connect pIn
			pOut.disconnect 'all'
			(pOut.isConnectedTo pIn).should.be.false
			(pIn.isConnectedFrom pOut).should.be.false
			pIn.inbound.length.should.equal 0
			pOut.outbound.length.should.equal 0

		it 'and disconnected from both sides', ->
			pOut.connect pIn
			pIn.disconnectFrom pOut
			(pOut.isConnectedTo pIn).should.be.false
			(pIn.isConnectedFrom pOut).should.be.false
			pIn.inbound.length.should.equal 0
			pOut.outbound.length.should.equal 0

