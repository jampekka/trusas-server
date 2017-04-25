child_process = require 'child_process'
fs = require 'fs'

module.exports = (args...) ->
	starter = child_process.fork __filename,
		stdio: ['inherit', 'inherit', 'inherit', 'ipc']
		disown: true
	starter.send(args)
	pid = await new Promise (a) -> starter.once 'message', a
	await new Promise (a) -> starter.once 'exit', a

	return pid

start = ->
	[cmd, {stdout, stderr}] = await new Promise (a) -> process.once 'message', a
	out = await fs.openSync stdout, 'a'
	err = await fs.openSync stderr, 'a'
	child = child_process.spawn cmd[0],
		args: cmd[1...]
		stdio: ['ignore', out, err]
		disown: true
	process.send child.pid
	child.unref()
	
	

if require.main == module
	start()
