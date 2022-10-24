(function() {
  "use strict";
  App.Settings = {
    initialize: function() {
      $("#settings-tabs").on("change.zf.tabs", function() {
        if ($("#tab-map-configuration:visible").length) {
          App.Map.destroy();
          App.Map.initialize();
        }
      });
    }
  };
}).call(this);
