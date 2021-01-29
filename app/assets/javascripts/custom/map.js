(function() {
  "use strict";
  App.Map = {
    initialize: function() {
      $("*[data-map]").each(function() {
        App.Map.initializeMap(this);
      });
      $(".js-toggle-map").on({
        click: function() {
          App.Map.toggleMap();
        }
      });
    },
    initializeMap: function(element) {
      var addMarker, clearFormfields, createMarker, editable, getPopupContent, latitudeInputSelector, longitudeInputSelector, map, mapAttribution, mapCenterLatLng, mapCenterLatitude, mapCenterLongitude, mapTilesProvider, marker, markerIcon, markerLatitude, markerLongitude, moveOrPlaceMarker, openMarkerPopup, removeMarker, removeMarkerSelector, updateFormfields, zoom, zoomInputSelector, process;
      process = $(element).data("parent-class");
      App.Map.cleanCoordinates(element);
      mapCenterLatitude = $(element).data("map-center-latitude");
      mapCenterLongitude = $(element).data("map-center-longitude");
      markerLatitude = $(element).data("marker-latitude");
      markerLongitude = $(element).data("marker-longitude");
      zoom = $(element).data("map-zoom");
      mapTilesProvider = $(element).data("map-tiles-provider");
      mapAttribution = $(element).data("map-tiles-provider-attribution");
      latitudeInputSelector = $(element).data("latitude-input-selector");
      longitudeInputSelector = $(element).data("longitude-input-selector");
      zoomInputSelector = $(element).data("zoom-input-selector");
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarker = $(element).data("marker-process-coordinates");
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
        $(latitudeInputSelector).val(marker.getLatLng().lat);
        $(longitudeInputSelector).val(marker.getLatLng().lng);
        $(zoomInputSelector).val(map.getZoom());
      };
      clearFormfields = function() {
        $(latitudeInputSelector).val("");
        $(longitudeInputSelector).val("");
        $(zoomInputSelector).val("");
      };
      openMarkerPopup = function(e) {
		var route = (process == "proposals" ? "/proposals/" + marker.options.id + "/json_data" : "/investments/" + marker.options.id + "/json_data");     
		marker = e.target;
	      $.ajax(route, {
		  type: "GET",
		  dataType: "json",
		  success: function(data) {
		    e.target.bindPopup(getPopupContent(data)).openPopup();
		  }
		});
      };
      getPopupContent = function(data) {
	      if(process == "proposals") {
		return "<a href='/proposals/" + data.proposal_id + "'>" + data.proposal_title + "</a>";
	      } else {
		return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
	      }
      };
      mapCenterLatLng = new L.LatLng(mapCenterLatitude, mapCenterLongitude);
      map = L.map(element.id).setView(mapCenterLatLng, zoom);
      L.tileLayer(mapTilesProvider, {
        attribution: mapAttribution
      }).addTo(map);
      if (markerLatitude && markerLongitude && !addMarker) {
        marker = createMarker(markerLatitude, markerLongitude);
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
      if (addMarker) {
        addMarker.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long);
            marker.options.id = (process == "proposals" ? coordinates.proposal_id : coordinates.investment_id);
            marker.on("click", openMarkerPopup);
          }
        });
      }
    },
    toggleMap: function() {
      $(".map").toggle();
      $(".js-location-map-remove-marker").toggle();
    },
    cleanCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-process-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-process-coordinates", clean_markers);
      }
    },
    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },
    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);