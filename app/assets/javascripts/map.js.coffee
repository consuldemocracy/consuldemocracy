###*
 * Leaflet Map Object
###
App.Map =
  ###*
   * @constructor
  ###
  initialize: ->
    maps = $("*[data-map]")

    if maps.length > 0
      $.each maps, (index, map) ->
        App.Map.initializeMap map

    $(".js-toggle-map").on
      click: ->
        App.Map.toggleMap()

  ###*
   * Initialize a map based upon the data attributes given
  ###
  initializeMap: (element) ->
    App.Map.cleanInvestmentCoordinates(element)
    options = {
      zoomControl: if $(element).data('map-allow-zoom') == false then false else true,
      scrollWheelZoom: if $(element).data('map-allow-scroll') == false then false else true,
      keyboard: if $(element).data('map-allow-keyboard') == false then false else true,
      dragging: if $(element).data('map-allow-dragging') == false then false else true
    }
    mapCenterLatitude = $(element).data('map-center-latitude')
    mapCenterLongitude = $(element).data('map-center-longitude')
    markerLatitude = $(element).data('marker-latitude')
    markerLongitude = $(element).data('marker-longitude')
    zoom = $(element).data('map-zoom')
    mapTilesProvider = $(element).data('map-tiles-provider')
    mapAttribution = $(element).data('map-tiles-provider-attribution')
    latitudeInputSelector = $(element).data('latitude-input-selector')
    longitudeInputSelector = $(element).data('longitude-input-selector')
    zoomInputSelector = $(element).data('zoom-input-selector')
    removeMarkerSelector = $(element).data('marker-remove-selector')
    addMarkerInvestments = $(element).data('marker-investments-coordinates')
    editable = $(element).data('marker-editable')
    marker = null
    markerIcon = L.divIcon(
      className: 'map-marker'
      iconSize: [30, 30]
      iconAnchor: [15, 40]
      html: '<div class="map-icon"></div>')

    ###*
     * Create a marker
     * @param {number} latitude - The latitude for the marker
     * @param {number} longitude - The longitude for the marker
     * @returns {L.Marker} marker - Leaflet marker
    ###
    createMarker = (latitude, longitude) ->
      markerLatLng  = new (L.LatLng)(latitude, longitude)
      marker  = L.marker(markerLatLng, { icon: markerIcon, draggable: editable })
      if editable
        marker.on "dragend", updateFormfields
      marker.addTo(map)
      return marker

    ###*
     * Remove a marker from the map
     * @param {event} e - The global event object
     * @void
    ###
    removeMarker = (e) ->
      e.preventDefault()
      if marker
        map.removeLayer(marker)
        marker = null
      clearFormfields()
      return

    ###*
     * Place or move a marker on the map
     * @param {event} e - The global event object
     * @void
    ###
    moveOrPlaceMarker = (e) ->
      if marker
        marker.setLatLng(e.latlng)
      else
        marker = createMarker(e.latlng.lat, e.latlng.lng)

      updateFormfields()
      return

    ###*
     * Enter values from the marker variable into input fields in a form
     * @void
    ###
    updateFormfields = ->
      $(latitudeInputSelector).val marker.getLatLng().lat
      $(longitudeInputSelector).val marker.getLatLng().lng
      $(zoomInputSelector).val map.getZoom()
      return
    ###*
     * Clear form values
     * @void
    ###
    clearFormfields = ->
      $(latitudeInputSelector).val ""
      $(longitudeInputSelector).val ""
      $(zoomInputSelector).val ""
      return
    ###*
     * Open a marker popup when a user clicks a marker
     * @void
    ###
    openMarkerPopup = (e) ->
      marker = e.target

      $.ajax "/investments/#{marker.options["id"]}/json_data",
        type: "GET"
        dataType: "json"
        success: (data) ->
          e.target.bindPopup(getPopupContent(data)).openPopup()

    ###*
     * Construct the content for a popup to show a user when they click a marker
     * @void
    ###
    getPopupContent = (data) ->
      content = "<a href='/budgets/#{data["budget_id"]}/investments/#{data["investment_id"]}'>#{data["investment_title"]}</a>"
      return content

    ###*
     * @constructor - continued
    ###
    mapCenterLatLng  = new (L.LatLng)(mapCenterLatitude, mapCenterLongitude)
    map = L.map(element.id, options)
    L.tileLayer(mapTilesProvider, attribution: mapAttribution).addTo map

    if !addMarkerInvestments
      map.setView(mapCenterLatLng, zoom)
      
    if markerLatitude && markerLongitude && !addMarkerInvestments
      marker  = createMarker(markerLatitude, markerLongitude)

    if editable
      $(removeMarkerSelector).on "click", removeMarker
      map.on    "zoomend", updateFormfields
      map.on    "click",   moveOrPlaceMarker

    if addMarkerInvestments
      markers = []
      for i in addMarkerInvestments
        if App.Map.validCoordinates(i)
          marker = createMarker(i.lat, i.long)
          marker.options["id"] = i.investment_id

          marker.on 'click', openMarkerPopup
          markers.push(marker)
      markergroup = new L.featureGroup(markers).addTo(map)
      map.fitBounds(markergroup.getBounds())
  
  ###*
   * Toggle a map
   * @void
  ###
  toggleMap: ->
    $('.map').toggle()
    $('.js-location-map-remove-marker').toggle()

  ###*
   * Remove markers that are not valid from the data array
   * @param {HTMLElement} element - HTML element that contains a data object for markers
   * @returns array of valid coordinate pairs
  ###
  cleanInvestmentCoordinates: (element) ->
    markers = $(element).attr("data-marker-investments-coordinates")
    if markers?
      clean_markers = markers.replace(/-?(\*+)/g, null)
      $(element).attr("data-marker-investments-coordinates", clean_markers)

  ###*
   * Check a coordinate datastructure to see if it is valid
   * @param {coordinates} coordinates - a pair of coordinates
   * @returns boolean
  ###
  validCoordinates: (coordinates) ->
    App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long)

  ###*
   * @function to check if a value is numeric
   * @param {any} n - value to check for being numeric
   * @returns boolean
  ###
  isNumeric: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)
