(function() {
  "use strict";
  App.ModeratorLegislationProposals = {
    add_class_faded: function(id) {
      $("#" + id).addClass("faded");
      $("#comments").addClass("faded");
    },
    hide_moderator_actions: function(id) {
      $("#" + id + " .js-moderator-proposals-actions:first").hide();
    }
  };
}).call(this);
