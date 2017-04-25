#!/usr/bin/env coffee

yargs = require 'yargs'
express = require 'express'
lodash = require 'lodash'
L = require 'lazyremote'
Service = require './service.coffee'
Promise = require 'bluebird'
NpmRun = require 'npm-run'

util = require 'util'

@serve = (opts={}) ->
	app = express()
	app.use express.static 'ui'
	require('express-ws')(app)
	spec = opts.spec
	
	api = ->
		lodash: lodash
		sessions: new Service.SessionServer spec, opts.directory
	
	app.ws '/api/v1', (socket) ->
		L socket, expose: api()
		#zone = Zone.current.fork({})
		#task = zone.run ->
		#	L socket, expose: api()
		#socket.onclose = ->
		#	zone.cancelTask task
	
	return new Promise (accept, reject) ->
		server = app.listen 3000, "localhost", (err) ->
			reject(err) if err
			accept server



@run_electron = (opts) ->
	server = await @serve opts
	a = server.address()
	url = "http://#{a.address}:#{a.port}/"
	console.info "Running trusas at #{url}"
	electron = NpmRun.spawn "electron", [url],
		stdio: ['inherit', 'inherit', 'inherit']
	electron.on "exit", ->
		server.close ->
			process.exit 0

if module == require.main
	opts = yargs
		.option 'directory', alias: 'd', describe: 'base directory for sessions'
		.option 'spec', alias: 's', describe: 'service specification'
		.demandOption(['directory', 'spec'])
		.help()
		.argv
	opts.spec = require opts.spec
	#@run_electron opts
	@serve opts
