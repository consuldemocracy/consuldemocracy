App.Map =

  initialize: ->
    maps = $('*[data-map]')

    if maps.length > 0
      $.each maps, (index, map) ->
        App.Map.initializeMap map

  initializeMap: (element) ->

    mapCenterLatitude        = $(element).data('map-center-latitude')
    mapCenterLongitude       = $(element).data('map-center-longitude')
    markerLatitude           = $(element).data('marker-latitude')
    markerLongitude          = $(element).data('marker-longitude')
    zoom                     = $(element).data('map-zoom')
    mapTilesProvider         = $(element).data('map-tiles-provider')
    mapAttribution           = $(element).data('map-tiles-provider-attribution')
    latitudeInputSelector    = $(element).data('latitude-input-selector')
    longitudeInputSelector   = $(element).data('longitude-input-selector')
    zoomInputSelector        = $(element).data('zoom-input-selector')
    removeMarkerSelector     = $(element).data('marker-remove-selector')
    editable                 = $(element).data('marker-editable')
    marker                   = null;
    markerIcon               = L.divIcon(
                                  className: 'map-marker'
                                  iconSize:     [30, 30]
                                  iconAnchor:   [15, 40]
                                  html: '<div class="map-icon"></div>')

    createMarker = (latitude, longitude) ->
      markerLatLng  = new (L.LatLng)(latitude, longitude)
      marker  = L.marker(markerLatLng, { icon: markerIcon, draggable: editable })
      if editable
        marker.on 'dragend', updateFormfields
      marker.addTo(map)
      return marker

    removeMarker = (e) ->
      e.preventDefault()
      if marker
        map.removeLayer(marker)
        marker = null;
      clearFormfields()
      return

    moveOrPlaceMarker = (e) ->
      if marker
        marker.setLatLng(e.latlng)
      else
        marker = createMarker(e.latlng.lat, e.latlng.lng)

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

    mapCenterLatLng  = new (L.LatLng)(mapCenterLatitude, mapCenterLongitude)
    map              = L.map(element.id).setView(mapCenterLatLng, zoom)
    L.tileLayer(mapTilesProvider, attribution: mapAttribution).addTo map

    if markerLatitude && markerLongitude
      marker  = createMarker(markerLatitude, markerLongitude)

    if editable
      $(removeMarkerSelector).on 'click', removeMarker
      map.on    'zoomend', updateFormfields
      map.on    'click',   moveOrPlaceMarker
