u = require 'utils'
debug = require 'utils/debug'
Pin = require 'core/connections/pin'
EmulatedAudioParam = require 'core/connections/emulated-audio-param'


module.exports = class Param extends Pin

	clickFree:   yes
	default:     0
	min:         -Infinity
	max:         Infinity
	minRampTime: .004

	constructor: (options) ->
		Object.defineProperty this, 'value',
			get: @_read
			set: @_write
		options.type = 'param'
		@clickFree   = options.clickFree ? @clickFree
		@default     = options.default ? @default
		@min         = options.min ? @min
		@max         = options.max ? @max
		@minRampTime = options.minRampTime ? @minRampTime
		# Emulated AudioParam
		unless options.source
			@isEmulated = yes
			source = new EmulatedAudioParam options.ctx ? options.parent.ctx
			options.source = => source
		super options
		@reset()

	clamp: (value) ->
		u.clamp @min, value, @max

	currentTime: ->
		@ctx.currentTime

	connect: (pin) ->
		if pin.type isnt 'param'
			throw 'Params can only connect to other params'
		super

	_connectSource: (pin) ->
		debug.logParamPropagation this, 'on connect'
		@propagate '_write', [@value]

	propagate: (method, args) ->
		debug.logParamPropagation this, method
		for conn in @outbound
			conn[method] args...

	_read: =>
		v = @source.source?.value ? @source.value
		debug.logParamAutomation this, '_read', "-> #{v}"
		return v

	_write: (value=@value, time=0, options={}) =>
		# FIXME: Note that most nodes won't be affected by `setValueAtTime`s
		#        until connected on both sides. Try to fix that.
		debug.debugArguments arguments
		debug.logParamAutomation this, '_write', "v=#{value}", "t=#{time}"
		value = @clamp value
		if @clickFree
			@source.setValueAtTime @value, @currentTime() + time
			@ramp value, 0, silent:yes
		else
			if time is 0 then @source.value = value
			@source.setValueAtTime value, @currentTime()+time
		@propagate '_write', [value, time] unless options.silent

	ramp: (value, duration=0, options={}) ->
		debug.debugArguments arguments
		debug.logParamAutomation this, 'ramp', "v=#{value}", "d=#{duration}"
		value = @clamp value
		@source.linearRampToValueAtTime value, @currentTime()+(Math.max @minRampTime, duration)
		@propagate 'ramp', [value, duration] unless options.silent
	expo: (value, duration=0, options={}) ->
		debug.debugArguments arguments
		debug.logParamAutomation this, 'expo', "v=#{value}", "d=#{duration}"
		value = @clamp value
		@source.exponentialRampToValueAtTime value, @currentTime()+(Math.max @minRampTime, duration)
		@propagate 'expo', [value, duration] unless options.silent

	curve: (values, duration, startTime=0, options={}) ->
		debug.debugArguments arguments
		debug.logParamAutomation this, 'curve', "v=#{values}", "d=#{duration}", "st=#{startTime}"
		@source.setValueCurveAtTime value, (@currentTime()+startTime), (@currentTime()+startTime+duration)
		@propagate 'curve', [values, duration, startTime] unless options.silent
	approach: (value, duration, startTime=0, options={}) ->
		debug.debugArguments arguments
		debug.logParamAutomation this, 'approach', "v=#{value}", "d=#{duration}", "st=#{startTime}"
		value = @clamp value
		@source.setTargetAtTime value, (@currentTime()+startTime), duration
		@propagate 'approach', [value, duration, startTime] unless options.silent

	cancel: (time=0, options={}) ->
		debug.debugArguments arguments
		debug.logParamAutomation this, 'cancel', time
		@source.cancelScheduledValues @currentTime() + time
		@source.setValueAtTime @value, @currentTime() + time
		@propagate 'cancel', [time] unless options.silent
	reset: ->
		debug.logParamAutomation this, 'reset'
		@cancel()
		@value = @default
