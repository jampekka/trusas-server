import Vue from 'vue'

import Vuetify from 'vuetify'
require 'vuetify/dist/vuetify.min.css'
Vue.use Vuetify

import VueRouter from 'vue-router'
Vue.use(VueRouter)

R = require 'lazyremote'



app = ->
	trusas = (await R '/api/v1/').root
	socket = R.internals(trusas).opts.remote.socket
	
	redirect =
		mounted: ->
			session_id = await R.resolve @$router.trusas.sessions.activeSessionId()
			if session_id
				@$router.replace "/session/#{session_id}"
			else
				@$router.replace '/startup/'
		template: "<h1>Redirecting...</h1>"
	router = new VueRouter
		routes: [
			(path: '/', component: redirect),
			(path: '/startup', component: require './startup.vue'),
			(path: '/session/:id', component: require './session.vue')
		]
	
	app =
		created: ->
			@$router.trusas = trusas
			setsock = =>
				@socketStatus = socket.readyState
			socket.addEventListener 'open', setsock
			socket.addEventListener 'close', setsock
			socket.addEventListener 'error', setsock

		components: {}
		data: ->
			socketStatus: socket.readyState
		router: router
		render: require('./main.vue').render
	return app
	#app.$mount("#container")

app.Vue = Vue
module.exports = app

