<style scoped>
.logo {
	text-align: center;
	padding: 10px;
	padding-top: 30px;
	color: white;
}
.viz-grid {
	display: grid;
	grid-auto-flow: dense;
	grid-template-columns: repeat(12, 1fr);
	grid-auto-rows: 1fr;
	grid-gap: 10px;
}

.viz-grid > * {
	grid-column-start: span 3;
	grid-row-start: span 3;
}

.viz-grid > .double-width {
	grid-column-start: span 6;
}

.viz-grid > .double-height {
	grid-column-start: span 6;
}

.viz-grid > .double {
	grid-column-start: span 6;
	grid-row-start: span 6;
}

.viz-grid > .filler {
	padding-top: 64%;
	grid-column-start: span 1;
	grid-row-start: span 1;
}

.padder > * {
	position: absolute !important;
	left: 0; right: 0; top: 0; bottom: 0;
}
</style>
<template lang="pug">

v-app(left-fixed-sidebar,v-if="loaded")
	v-toolbar(class="hidden-lg-and-up")
		v-toolbar-side-icon(class="hidden-lg-and-up" @click.native.stop="sidebar = !sidebar")
	main
		v-sidebar(v-model="sidebar",fixed)
			.logo
				img(src="logo.svg")
				.title trusas
			v-list(dense,v-if="session.services")
				v-divider(light)
				v-subheader Services
				v-list-item(v-for="(info, name) of session.services")
					v-list-tile(:title="info.state",avatar)
						v-list-tile-avatar
							v-icon(v-if="info.state == 'running'",success,title='Running').success--text lens
							v-icon(v-else-if="info.state == 'terminated'",success,title='Finished').primary--text check_box
							v-icon(v-else-if="info.state == 'dead'",error,title='Dead').error--text error
							v-progress-circular(v-else,indeterminate,title='Unknown').primary--text

						v-list-tile-content(@click.stop="showStatus(info)")
							v-list-tile-title {{info.service.label || name}}
							
						v-list-tile-action(v-if="info.warnings && info.warnings.length")
							v-icon(warning).warning--text warning

				v-divider(light)
				v-btn(large,warning,block,raised,@click.native="confirmTerminate = true") Terminate

		v-content
			v-alert(v-bind:value="isTerminated",info,icon="check_box")
				div This session is finished. You can look around, but nothing intresting's gonna happen.
					v-btn(primary,@click.native="$router.replace('/')") Start a new one
			v-container(fluid)
				.viz-grid
					.tile.double
						trusas-timeseries(v-if="getRemote()",:service="getRemote().services.test",:api="getApi()")
					.tile Stuff
					.tile Stuff
					.tile Stuff
					.tile Stuff
					.tile Stuff
					.filler
							
		v-modal(v-for="(info, name) of session.services" v-model="info.display_status")
			v-card
				v-card-title {{ info.service.label || name }}
				v-subheader Warning log
				v-card-text(v-if="info.warnings.length > 0")
					v-list
						v-list-item(v-for="w in info.warnings") {{w}}
				v-card-text(v-else) No warnings


		v-modal(persistent,v-model="confirmTerminate")
			v-card
					v-card-row
						v-card-title Terminate Current Session?
					v-card-text Terminate the session only after the experiment is over.
					v-card-row(actions)
						v-btn(flat,@click.native="confirmTerminate = false") Cancel
						v-btn(flat,warning,@click.native="terminate(); confirmTerminate = false") Terminate
					

</template>

<script lang="coffee">
R = require('lazyremote')
Vue = require 'vue'
Vue.component 'trusas-timeseries', require './timeseries.vue'
module.exports =
	created: ->
		@private = {}
		@private.api = @$router.trusas
		@private.remote = @private.api.sessions.getSession @$route.params.id
	
		@private.asyncInit = =>
			session = await R.resolve @private.remote
			for name of session.services then do (name) =>
				service = session.services[name]
				service.warnings = []
				service.status = 'unknown'
				service.display_status = false
				s = @private.remote.services[name]
				
				R.resolve s.state.forEach (state) =>
					service.state = state

				R.resolve @private.remote.services[name].errorStream().forEach (error) =>
					service.warnings.push (error)
			@$set @, "session", session
			@loaded = true
	
	mounted: ->
		@private.asyncInit()

	data: ->
		session: {}
		confirmTerminate: false
		sidebar: true
		states: {}
		loaded: false
	
	computed:
		isTerminated: ->
			for name, service of @session.services
				if service.state != 'terminated'
					return false
			return true

	methods:
		getRemote: -> @private.remote
		getApi: -> @api
		terminate: ->
			await R.resolve @private.remote.terminate()
		showStatus: (info) ->
			Vue.set info, "display_status", true
</script>
