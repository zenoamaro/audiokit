debug = {
#	contract:      on
#	error:         on
#	warn:          on
#	info:          on
#	log:           on
#	debug:         on
#	component:     on
#	connection:    on
#	disconnection: on
#	automation:    on
#	propagation:   on
#	noteOn:        on
#	noteOff:       on
}

module.exports = d =

	logStyles:
		log:           (sign:' ',  style: '')
		info:          (sign:' ',  style:'color:#808080')
		debug:         (sign:' ',  style:'color:#A0A0A0')
		warn:          (sign:'★', style:'color:#F8B200; font-weight:bold')
		error:         (sign:'★', style:'color:#E00000; font-weight:bold')
		contract:      (sign:'◪',  style:'color:#E00000; font-weight:bold')
		component:     (sign:' ',  style:'color:#808080')
		connection:    (sign:'→',  style:'color:#7EBA3B')
		disconnection: (sign:'→',  style:'color:#A00000')
		automation:    (sign:'∿',  style:'color:#4040FF')
		propagation:   (sign:' ',  style:'color:#7FE5E9')
		noteOn:        (sign:'♫', style:'color:#FD8FC9')
		noteOff:       (sign:'♫', style:'color:#7E0B80')

	cname: (obj) ->
		obj?.constructor?.name ? '-'

	debugArguments: (args) ->
		for a in _.toArray args
			if not a? or _.isNaN a
				debugger

	# CUR: just worked up this untested assertion impl
	assert: (conditions...) ->
		unless (_.every conditions, (verified) -> verified is yes)
			if debug?.assertion then debugger
			throw new AssertionError 'Assertion was not respected'

	# CUR: just worked up this untested contract impl
	contract: (conditions...) ->
		unless (_.every conditions, (verified) -> verified is yes)
			if debug?.contract then debugger
			throw new ContactError 'Contract was not respected'

	log: (style='log', message) ->
		return unless debug[style] or debug is true
		{style, sign} = d.logStyles[style] ? d.logStyles.log
		console.log "%c%s %s", style, sign, message

	debug: (message) -> d.log 'debug', message
	info:  (message) -> d.log 'info', message
	warn:  (message) -> d.log 'warn', message
	error: (message) -> d.log 'error', message

	describeComponent: (component) ->
		"#{d.cname component}"

	describePin: (pin) ->
		emulated = if pin.emulated then '~' else ''
		"#{emulated}#{d.cname pin.parent}:#{pin.id ? '-'}(#{d.cname pin.source})"

	logComponent: (component, message) ->
		d.log 'component', "#{d.describeComponent component}: #{message}"

	logPinConnection: (state, from, to) ->
		style = if state then 'connection' else 'disconnection'
		d.log style, "#{d.describePin from} #{if state then '→' else '⤬'} #{d.describePin to}"

	logParamAutomation: (param, method, args...) ->
		args = _.map args, (a) -> a ? '✖︎'
		d.log 'automation', "#{d.describePin param}·#{method}(#{args.join ', '})"

	logParamPropagation: (param, method) ->
		pins = [d.cname param.source].concat _.map param.outbound, (p) -> d.describePin p
		d.log 'propagation', "    propagate #{method} → #{pins.join ', '}"

	logNote: (state, component, note) ->
		state = if state is on then 'noteOn' else 'noteOff'
		d.log state, "#{d.describeComponent component}·#{state} #{note or ''}"


unless (_.compact debug).length
	for k, fn of d when _.isFunction fn
		d[k] = ->