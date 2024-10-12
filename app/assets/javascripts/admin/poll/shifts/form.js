(function() {
  "use strict";
  App.AdminPollShiftsForm = {
    initialize: function() {
      $("select[class='js-poll-shifts']").on({
        change: function() {
          switch ($(this).val()) {
          case "vote_collection":
            $(".js-shift-vote-collection-dates").show();
            $(".js-shift-recount-scrutiny-dates").hide();
            break;
          case "recount_scrutiny":
            $(".js-shift-recount-scrutiny-dates").show();
            $(".js-shift-vote-collection-dates").hide();
          }
        }
      });
    }
  };
}).call(this);
