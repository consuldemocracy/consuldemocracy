(function() {
  "use strict";

  App.ParticipationNotAllowed = {
    not_allowed: function(votes_selector) {
      var buttons_selector = votes_selector + " [type='submit']";

      $("body").on("click", buttons_selector, function(event) {
        var votes = $(event.target).closest(votes_selector);
        var not_allowed = $("div.participation-not-allowed", votes);

        if (not_allowed.length > 0) {
          event.preventDefault();
          not_allowed.show().focus();

          if (votes_selector === "div.votes") {
            $("button", votes).prop("disabled", true);
          } else {
            $(event.target).closest("form").remove();
          }
        }
      });
    },
    initialize: function() {
      App.ParticipationNotAllowed.not_allowed("div.votes");
      App.ParticipationNotAllowed.not_allowed("div.supports");
    }
  };
}).call(this);
