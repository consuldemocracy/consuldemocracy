(function() {
  "use strict";
  App.LocationChanger = {
    initialize: function() {
      $(".js-location-changer").on("change", function() {
        window.location.assign($(this).val());
      });
    }
  };
}).call(this);
