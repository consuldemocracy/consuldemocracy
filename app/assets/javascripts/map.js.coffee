App.Map =

  initialize: ->
    maps = $('*[data-map]')

    if maps.length > 0
      $.each maps, (index, map) ->
        App.Map.initializeMap map

    $('.js-toggle-map').on
        click: ->
          App.Map.toogleMap()

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
    addMarkerInvestemts      = $(element).data('marker-investments-coordenates')
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

    contentPopup = (title,investment,budget) ->
      content = "<a href='/budgets/#{budget}/investments/#{investment}'>#{title}</a>"
      return  content

    mapCenterLatLng  = new (L.LatLng)(mapCenterLatitude, mapCenterLongitude)
    map              = L.map(element.id).setView(mapCenterLatLng, zoom)
    L.tileLayer(mapTilesProvider, attribution: mapAttribution).addTo map

    if markerLatitude && markerLongitude && !addMarkerInvestemts
      marker  = createMarker(markerLatitude, markerLongitude)

    if editable
      $(removeMarkerSelector).on 'click', removeMarker
      map.on    'zoomend', updateFormfields
      map.on    'click',   moveOrPlaceMarker

    if addMarkerInvestemts
      for i in addMarkerInvestemts
        add_marker=createMarker(i.lat , i.long)
        add_marker.bindPopup(contentPopup(i.investment_title, i.investment_id, i.budget_id))

  toogleMap: ->
      $('.map').toggle()
      $('.js-location-map-remove-marker').toggle()
