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
      var addMarkerInvestments, centerData, clearFormfields, createMarker,
        editable, getPopupContent, markerData, map, mapCenterLatLng, marker,
        markerIcon, moveOrPlaceMarker, openMarkerPopup, removeMarker,
        removeMarkerSelector, updateFormfields;
      App.Map.cleanInvestmentCoordinates(element);
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarkerInvestments = $(element).data("marker-investments-coordinates");
      editable = $(element).data("marker-editable");
      marker = null;
      markerIcon = L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40],
        html: '<div class="map-icon"></div>'
      });
      createMarker = function(latitude, longitude) {
        var markerLatLng;
        markerLatLng = new L.LatLng(latitude, longitude);
        marker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });
        if (editable) {
          marker.on("dragend", updateFormfields);
        }
        marker.addTo(map);
        return marker;
      };
      removeMarker = function(e) {
        e.preventDefault();
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        clearFormfields();
      };
      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        updateFormfields();
      };
      updateFormfields = function() {
        var inputs = App.Map.coordinatesInputs(element);

        inputs.lat.val(marker.getLatLng().lat);
        inputs.long.val(marker.getLatLng().lng);
        inputs.zoom.val(map.getZoom());
      };
      clearFormfields = function() {
        var inputs = App.Map.coordinatesInputs(element);

        inputs.lat.val("");
        inputs.long.val("");
        inputs.zoom.val("");
      };
      openMarkerPopup = function(e) {
        marker = e.target;
        $.ajax("/investments/" + marker.options.id + "/json_data", {
          type: "GET",
          dataType: "json",
          success: function(data) {
            e.target.bindPopup(getPopupContent(data)).openPopup();
          }
        });
      };
      getPopupContent = function(data) {
        return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
      };

      centerData = App.Map.centerData(element);
      mapCenterLatLng = new L.LatLng(centerData.lat, centerData.long);
      map = L.map(element.id, { scrollWheelZoom: false }).setView(mapCenterLatLng, centerData.zoom);
      App.Map.maps.push(map);
      App.Map.addAttribution(map);

      markerData = App.Map.markerData(element);
      if (markerData.lat && markerData.long && !addMarkerInvestments) {
        marker = createMarker(markerData.lat, markerData.long);
      }
      if (editable) {
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", function() {
          if (marker) {
            updateFormfields();
          }
        });
        map.on("click", moveOrPlaceMarker);
      }
      if (addMarkerInvestments) {
        addMarkerInvestments.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long);
            marker.options.id = coordinates.investment_id;
            marker.on("click", openMarkerPopup);
          }
        });
      }
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
