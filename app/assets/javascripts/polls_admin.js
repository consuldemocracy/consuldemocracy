(function() {
  "use strict";
  App.PollsAdmin = {
    initialize: function() {
      $("select[class='js-poll-shifts']").on({
        change: function() {
          switch ($(this).val()) {
          case "vote_collection":
            $("select[class='js-shift-vote-collection-dates']").show();
            $("select[class='js-shift-recount-scrutiny-dates']").hide();
            break;
          case "recount_scrutiny":
            $("select[class='js-shift-recount-scrutiny-dates']").show();
            $("select[class='js-shift-vote-collection-dates']").hide();
          }
        }
      });
    }
  };
}).call(this);
