(function() {
  "use strict";
  App.ModeratorProposalNotifications = {
    add_class_faded: function(id) {
      $("#" + id).addClass("faded");
    },
    hide_moderator_actions: function(id) {
      $("#" + id + " .js-moderator-proposal-notifications-actions:first").hide();
    }
  };
}).call(this);
