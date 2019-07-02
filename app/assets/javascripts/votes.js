(function() {
  "use strict";
  App.Votes = {
    hoverize: function(votes) {
      $(document).on({
        "mouseenter focus": function() {
          $("div.participation-not-allowed", this).show();
          $("div.participation-allowed", this).hide();
        },
        mouseleave: function() {
          $("div.participation-not-allowed", this).hide();
          $("div.participation-allowed", this).show();
        }
      }, votes);
    },
    initialize: function() {
      App.Votes.hoverize("div.votes");
      App.Votes.hoverize("div.supports");
      App.Votes.hoverize("div.debate-questions");
      App.Votes.hoverize("div.comment-footer");
    }
  };
}).call(this);
