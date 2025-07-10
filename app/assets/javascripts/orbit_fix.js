(function() {
  "use strict";
  App.OrbitFix = {
    initialize: function() {
      $(".orbit").each(function() {
        App.OrbitFix.updateHeight(this);
      });

      $(".orbit").on("slidechange.zf.orbit", function(e) {
        App.OrbitFix.updateHeight(this);
      });
    },
    updateHeight: function(orbit_container) {
      var new_height = $(orbit_container).find(".orbit-slide.is-active").height();
      $(orbit_container).css("height", new_height + "px");
    }
  };
}).call(this);
