module.exports = class AudioParam

	constructor: (param) ->
		@param = param

	cancelScheduledValues: (value, startTime) ->
		@param.cancelScheduledValues arguments...

	setValueAtTime: (value, startTime) ->
		@param.setValueAtTime arguments...
	setValueCurveAtTime: (values, startTime, duration) ->
		@param.setValueCurveAtTime arguments...

	linearRampToValueAtTime: (value, endTime) ->
		@param.linearRampToValueAtTime arguments...
	exponentialRampToValueAtTime: (value, endTime) ->
		@param.exponentialRampToValueAtTime arguments...

	setTargetAtTime: (value, startTime, timeConstant) ->
		@param.setTargetAtTime arguments...
