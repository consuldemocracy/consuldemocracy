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
    removeMarkerSelector       = $(element).data('remove-marker-selector')
    attribution               = $(mapAttributionSelector)
    marker_icon               = L.divIcon(
                                  iconSize: null
                                  html: '<div class="map-marker"></div>')

    placeMarker = (e) ->
      marker.setLatLng(e.latlng)
      marker.addTo(map)
      updateFormfields()
      return

    updateFormfields = ->
      $(latitudeInputSelector).val marker.getLatLng().lat
      $(longitudeInputSelector).val marker.getLatLng().lng
      $(zoomInputSelector).val map.getZoom()
      return

    clearFormfields = ->
      $(latitudeInputSelector).val ''
      $(longitudeInputSelector).val ''
      $(zoomInputSelector).val ''
      return

    removeMarker = (e) ->
      e.preventDefault()
      map.removeLayer(marker)
      clearFormfields()
      return

    latLng  = new (L.LatLng)(latitude, longitude)
    map     = L.map(element.id).setView(latLng, zoom)
    marker  = L.marker(latLng, { icon: marker_icon, draggable: 'true' })
    L.tileLayer(mapTilesProvider, attribution: attribution.html()).addTo map
    marker.addTo(map)

    $(removeMarkerSelector).on 'click', removeMarker
    marker.on 'dragend', updateFormfields
    map.on    'zoomend', updateFormfields
    map.on    'click',   placeMarker