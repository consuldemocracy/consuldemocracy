(function() {
  "use strict";
  App.Polls = {
    initialize: function() {
      $(".zoom-link").on("click", function(event) {
        var answer;
        answer = $(event.target).closest("div.answer");

        if ($(answer).hasClass("medium-6")) {
          $(answer).removeClass("medium-6");
          $(answer).addClass("answer-divider");
          if (!$(answer).hasClass("first")) {
            $(answer).insertBefore($(answer).prev("div.answer"));
          }
        } else {
          $(answer).addClass("medium-6");
          $(answer).removeClass("answer-divider");
          if (!$(answer).hasClass("first")) {
            $(answer).insertAfter($(answer).next("div.answer"));
          }
        }
      });
    }
  };
}).call(this);
