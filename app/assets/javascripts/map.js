(function() {
  "use strict";
  App.Map = {
    maps: [],
    initialize: function() {
      $("*[data-map]:visible").each(function() {
        App.Map.initializeMap(this);
      });
    },
    destroy: function() {
      App.Map.maps.forEach(function(map) {
        map.off();
        map.remove();
      });
      App.Map.maps = [];
    },
    initializeMap: function(element) {
      var createMarker, editable, investmentsMarkers, markerData, map, marker,
        markerIcon, moveOrPlaceMarker, removeMarker, removeMarkerSelector;
      App.Map.cleanInvestmentCoordinates(element);
      removeMarkerSelector = $(element).data("marker-remove-selector");
      investmentsMarkers = $(element).data("marker-investments-coordinates");
      editable = $(element).data("marker-editable");
      marker = null;
      markerIcon = L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40],
        html: '<div class="map-icon"></div>'
      });
      createMarker = function(latitude, longitude) {
        var newMarker, markerLatLng;
        markerLatLng = new L.LatLng(latitude, longitude);
        newMarker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });
        if (editable) {
          newMarker.on("dragend", function() {
            App.Map.updateFormfields(map, newMarker);
          });
        }
        newMarker.addTo(map);
        return newMarker;
      };
      removeMarker = function() {
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        App.Map.clearFormfields(element);
      };
      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        App.Map.updateFormfields(map, marker);
      };

      map = App.Map.leafletMap(element);
      App.Map.maps.push(map);
      App.Map.addAttribution(map);

      markerData = App.Map.markerData(element);
      if (markerData.lat && markerData.long && !investmentsMarkers) {
        marker = createMarker(markerData.lat, markerData.long);
      }
      if (editable) {
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", function() {
          if (marker) {
            App.Map.updateFormfields(map, marker);
          }
        });
        map.on("click", moveOrPlaceMarker);
      }

      App.Map.addInvestmentsMarkers(investmentsMarkers, createMarker);
      App.Map.addGeozones(map);
    },
    leafletMap: function(element) {
      var centerData, mapCenterLatLng, map;

      centerData = App.Map.centerData(element);
      mapCenterLatLng = new L.LatLng(centerData.lat, centerData.long);
      map = L.map(element.id, { scrollWheelZoom: false }).setView(mapCenterLatLng, centerData.zoom);

      map.on("focus", function() {
        map.scrollWheelZoom.enable();
      });
      map.on("blur mouseout", function() {
        map.scrollWheelZoom.disable();
      });

      return map;
    },
    attributionPrefix: function() {
      return '<a href="https://leafletjs.com" title="A JavaScript library for interactive maps">Leaflet</a>';
    },
    markerData: function(element) {
      var dataCoordinates, formCoordinates, inputs, latitude, longitude;
      inputs = App.Map.coordinatesInputs(element);

      dataCoordinates = {
        lat: $(element).data("marker-latitude"),
        long: $(element).data("marker-longitude")
      };
      formCoordinates = {
        lat: inputs.lat.val(),
        long: inputs.long.val(),
        zoom: inputs.zoom.val()
      };
      if (App.Map.validCoordinates(formCoordinates)) {
        latitude = formCoordinates.lat;
        longitude = formCoordinates.long;
      } else if (App.Map.validCoordinates(dataCoordinates)) {
        latitude = dataCoordinates.lat;
        longitude = dataCoordinates.long;
      }

      return {
        lat: latitude,
        long: longitude,
        zoom: formCoordinates.zoom
      };
    },
    centerData: function(element) {
      var markerCoordinates, latitude, longitude, zoom;

      markerCoordinates = App.Map.markerData(element);

      if (App.Map.validCoordinates(markerCoordinates)) {
        latitude = markerCoordinates.lat;
        longitude = markerCoordinates.long;
      } else {
        latitude = $(element).data("map-center-latitude");
        longitude = $(element).data("map-center-longitude");
      }

      if (App.Map.validZoom(markerCoordinates.zoom)) {
        zoom = markerCoordinates.zoom;
      } else {
        zoom = $(element).data("map-zoom");
      }

      return {
        lat: latitude,
        long: longitude,
        zoom: zoom
      };
    },
    coordinatesInputs: function(element) {
      return {
        lat: $($(element).data("latitude-input-selector")),
        long: $($(element).data("longitude-input-selector")),
        zoom: $($(element).data("zoom-input-selector"))
      };
    },
    updateFormfields: function(map, marker) {
      var inputs = App.Map.coordinatesInputs(map._container);

      inputs.lat.val(marker.getLatLng().lat);
      inputs.long.val(marker.getLatLng().lng);
      inputs.zoom.val(map.getZoom());
    },
    clearFormfields: function(element) {
      var inputs = App.Map.coordinatesInputs(element);

      inputs.lat.val("");
      inputs.long.val("");
      inputs.zoom.val("");
    },
    addInvestmentsMarkers: function(markers, createMarker) {
      if (markers) {
        markers.forEach(function(coordinates) {
          var marker;

          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long);
            marker.options.id = coordinates.investment_id;
            marker.bindPopup(App.Map.getPopupContent(coordinates));
          }
        });
      }
    },
    cleanInvestmentCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-investments-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-investments-coordinates", clean_markers);
      }
    },
    addAttribution: function(map) {
      var element, mapAttribution, mapTilesProvider;

      element = map._container;
      mapTilesProvider = $(element).data("map-tiles-provider");
      mapAttribution = $(element).data("map-tiles-provider-attribution");

      map.attributionControl.setPrefix(App.Map.attributionPrefix());
      L.tileLayer(mapTilesProvider, { attribution: mapAttribution }).addTo(map);
    },
    addGeozones: function(map) {
      var geozones = $(map._container).data("geozones");

      if (geozones) {
        geozones.forEach(function(geozone) {
          App.Map.addGeozone(geozone, map);
        });
      }
    },
    addGeozone: function(geozone, map) {
      var polygon = L.polygon(geozone.outline_points, {
        color: geozone.color,
        fillOpacity: 0.3,
        className: "map-polygon"
      });

      if (geozone.headings !== undefined) {
        polygon.bindPopup(geozone.headings.join("<br>"));
      }

      polygon.addTo(map);
    },
    getPopupContent: function(data) {
      return "<a href='" + data.link + "'>" + data.title + "</a>";
    },
    validZoom: function(zoom) {
      return App.Map.isNumeric(zoom);
    },
    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },
    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);
