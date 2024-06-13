(function() {
  "use strict";
  App.Polls = {
    initialize: function() {
      $(".zoom-link").on("click", function(event) {
        var option;
        option = $(event.target).closest("div.option");

        if ($(option).hasClass("medium-6")) {
          $(option).removeClass("medium-6");
          $(option).addClass("option-divider");
          if (!$(option).hasClass("first")) {
            $(option).insertBefore($(option).prev("div.option"));
          }
        } else {
          $(option).addClass("medium-6");
          $(option).removeClass("option-divider");
          if (!$(option).hasClass("first")) {
            $(option).insertAfter($(option).next("div.option"));
          }
        }
      });
    }
  };
}).call(this);
