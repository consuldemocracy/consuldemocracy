App.Settings =

  initialize: ->

    $("#settings-tabs").on "change.zf.tabs", ->
      if $("#tab-map-configuration:visible").length
        map_container = L.DomUtil.get "admin-map"
        unless map_container is null
          map_container._leaflet_id = null
        App.Map.initialize()
