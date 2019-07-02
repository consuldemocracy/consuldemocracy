(function() {
  "use strict";
  App.AllowParticipation = {
    initialize: function() {
      $(document).on({
        "mouseenter focus": function() {
          $(this).find(".js-participation-not-allowed").show();
          $(this).find(".js-participation-allowed").hide();
        },
        mouseleave: function() {
          $(this).find(".js-participation-not-allowed").hide();
          $(this).find(".js-participation-allowed").show();
        }
      }, ".js-participation");
    }
  };

}).call(this);
