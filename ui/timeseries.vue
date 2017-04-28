
<script lang="coffee">
require './bokeh-0.12.0.js'
require './bokeh-0.12.0.css'
plt = Bokeh.Plotting

R = require 'lazyremote'
module.exports =
	name: "trusas-timeseries"
	props:
		stream: required: true
		labels: default: {}
		span: type: Number, default: 30
		maxSamples: type: Number, default: 10000
		bufferDuration: type: Number, default: 0.1
	
	mounted: ->
		#plot = plt.figure
		#	tools: false
		#	x_axis_type: 'datetime'
		xrng = new Bokeh.Range1d()
		yrng = new Bokeh.DataRange1d()
		console.log xrng
		plot = plt.figure
			x_range: xrng
			y_range: yrng
			sizing_mode: "stretch_both"
			tools: []
		plot.toolbar.logo = null
		plot.toolbar_location = null
		

		lines = {}
		add_line = (field) ->
			source = new Bokeh.ColumnDataSource data: x: [], y: []
			line = new Bokeh.Line
				x: field: 'x'
				y: field: 'y'
			plot.add_glyph line, source
			lines[field] =
				source: source
				line: line
		###
		source = new Bokeh.ColumnDataSource
			data:
				x: []
				y: []
		line = new Bokeh.Line
			x: field: 'x'
			y: field: 'y'
		###
		plt.show plot, @$el
		update = (d) =>
			[hdr, d] = d
			for field, value of d
				unless field of lines
					lines[field] = add_line(field)
				lines[field].source.stream
					x: [hdr.ts]
					y: [value]
			s = hdr.ts
			xrng.start = s - @span
			xrng.end = s
			return
		R.resolve @stream.forEach update
	data: -> {}
</script>

<style scoped>
.trusas-plot {
	width: 100%;
	height: 100%;
	position: relative;
	z-index: 0;
}
</style>

<template lang="pug">
<div class="trusas-plot"></div>
</template>
