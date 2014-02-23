module.exports = u =

	clamp: (min, value, max) ->
		Math.max min, Math.min value, max
