App.Map =

  initialize: ->
    maps = $('*[data-map]')

    if maps.length > 0
      $.each maps, (index, map) ->
        App.Map.initializeMap map

  initializeMap: (element) ->
    latitude                  = $(element).data('latitude')
    longitude                 = $(element).data('longitude')
    zoom                      = $(element).data('zoom')
    mapTilesProvider          = $(element).data('tiles-provider')
    mapAttributionSelector    = $(element).data('tiles-attribution-selector')
    latitudeInputSelector     = $(element).data('latitude-input-selector')
    longitudeInputSelector    = $(element).data('longitude-input-selector')
    zoomInputSelector         = $(element).data('zoom-input-selector')

    latLng              = new (L.LatLng)(latitude, longitude)
    map                 = L.map(element.id).setView(latLng, zoom)
    attribution         = $(mapAttributionSelector)
    L.tileLayer(mapTilesProvider, attribution: attribution.html()).addTo map

    marker_icon = L.divIcon(
      iconSize: null
      html: '<div class="map-marker"></div>')
    marker = L.marker(latLng, { icon: marker_icon, draggable: 'true' })
    marker.addTo(map)

    onMapClick = (e) ->
      marker.setLatLng(e.latlng)
      updateFormfields()
      return

    updateFormfields = ->
      $(latitudeInputSelector).val marker.getLatLng().lat
      $(longitudeInputSelector).val marker.getLatLng().lng
      $(zoomInputSelector).val map.getZoom()
      return

    marker.on 'dragend', updateFormfields
    map.on    'zoomend', updateFormfields
    map.on    'click',   onMapClick