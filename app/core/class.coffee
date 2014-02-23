module.exports = class Class

	constructor: (options) ->
		@defaults ?= {}
		@options ?= {}
		@initialize?()

	set: (options) ->
		@options = $.extend yes, {}, @defaults, @options, options
