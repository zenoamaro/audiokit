u = require 'utils'
debug = require 'utils/debug'
music = require 'core/music'


module.exports = class EmulatedAudioParam

	constructor: (@ctx, options) ->
		Object.defineProperty this, 'value',
			get: @_read
			set: @_write
		@events = [ (time:@currentTime(), type:'value', value:0) ]

	currentTime: ->
		@ctx.currentTime

	_read: =>
		{time, value, extra} = @lastScheduledValue()
		next = @nextScheduledValue()
		if next?.type is 'ramp'
			totalTime = nextTime - time
			elapsedTime = @currentTime() - time
			value + ((nextValue - value) * (1 / (totalTime * elapsedTime)))
		else
			value

	_write: (value) =>
		@setValueAtTime value, @currentTime()

	lastScheduledValue: ->
		now = @currentTime()
		_.find @events, (k) -> k.time <= now

	nextScheduledValue: ->
		prevK = null
		now = @currentTime()
		for k in @events
			if k.time <= now
				return prevK
			prevK = k

	currentValues: ->
		now = @currentTime()
		idx = _.indexOf @events, lastEvent
		@events[0..idx]

	scheduleValue: (time, type, value, extra) ->
		debug.debugArguments (_.toArray arguments)[0...-1]
		event =
			time: time
			type: time
			value: value
			extra: extra
		debug.log 'debug', "#{debug.cname this} schedule #{type}(#{value}) at #{time}"
		@events.unshift event
		unless @events.length then debugger

	cancelExpiredValues: ->
		@events = @currentValues()
		unless @events.length then debugger

	cancelScheduledValues: (value, startTime) ->
		if lastEvent = @lastScheduledValue()
			now = @currentTime()
			idx = _.indexOf @events, lastEvent
			@events = @events[idx..]
		unless @events.length then debugger

	setValueAtTime: (value, startTime) ->
		@scheduleValue startTime, 'value', value ? @value

	setValueCurveAtTime: (values, startTime, duration) ->
		debug.warn 'setValueCurveAtTime has not been implemented yet'

	linearRampToValueAtTime: (value, endTime) ->
		@scheduleValue endTime, 'ramp', value

	exponentialRampToValueAtTime: (value, endTime) ->
		debug.warn 'exponentialRampToValueAtTime has not been fully implemented yet'
		@scheduleValue endTime, 'ramp', value

	setTargetAtTime: (value, startTime, timeConstant) ->
		debug.warn 'setTargetAtTime has not been fully implemented yet'
		@setValueAtTime null, startTime
		@linearRampToValueAtTime value, timeConstant * (1/music.EXP_FALL)
