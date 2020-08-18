(function() {
  "use strict";
  App.AllowParticipation = {
    initialize: function() {
      $(document).on({
        "mouseenter focus": function() {
          $(this).find(".js-participation-not-allowed").show();
        },
        mouseleave: function() {
          $(this).find(".js-participation-not-allowed").hide();
        }
      }, ".js-participation");
    }
  };
}).call(this);
