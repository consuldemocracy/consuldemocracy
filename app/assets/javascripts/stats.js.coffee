# Helper for generate C3.js graphs
#----------------------------------------------------------------------

buildGraph = (el) ->
  url = $(el).data 'graph'
  conf = bindto: el,  data: {x: 'x', url: url, mimeType: 'json'},  axis: { x: {type: 'timeseries',tick: { format: '%Y-%m-%d' } }}
  graph = c3.generate conf

App.Stats =
  initialize: ->
    buildGraph(g) for g in $("[data-graph]")
