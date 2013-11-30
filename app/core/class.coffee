module.exports = class Class

	defaults: {}

	constructor: (options) ->
		@initialize?()
		@set options

	set: (options) ->
		@options = $.extend yes, {}, @defaults, @options, options
