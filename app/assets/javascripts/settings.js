(function() {
  "use strict";
  App.Settings = {
    initialize: function() {
      $("#settings-tabs").on("change.zf.tabs", function() {
        var map_container;
        if ($("#tab-map-configuration:visible").length) {
          map_container = L.DomUtil.get("admin-map");
          if (map_container !== null) {
            map_container._leaflet_id = null;
          }
          App.Map.initialize();
        }
      });
    }
  };

}).call(this);
