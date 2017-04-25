path = require 'path'

module.exports =
	label: "Test session"
	services:
		test:
			command: require.resolve('trusas0-pycore/timestamper.py')
			label: 'Current time'
	
