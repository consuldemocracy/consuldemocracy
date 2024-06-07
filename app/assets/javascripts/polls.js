(function() {
  "use strict";
  App.Polls = {
    initialize: function() {
      $(".zoom-link").on("click", function(event) {
        var option;
        option = $(event.target).closest("div.answer");

        if ($(option).hasClass("medium-6")) {
          $(option).removeClass("medium-6");
          $(option).addClass("answer-divider");
          if (!$(option).hasClass("first")) {
            $(option).insertBefore($(option).prev("div.answer"));
          }
        } else {
          $(option).addClass("medium-6");
          $(option).removeClass("answer-divider");
          if (!$(option).hasClass("first")) {
            $(option).insertAfter($(option).next("div.answer"));
          }
        }
      });
    }
  };
}).call(this);
