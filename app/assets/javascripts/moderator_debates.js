(function() {
  "use strict";
  App.ModeratorDebates = {
    add_class_faded: function(id) {
      $("#" + id).addClass("faded");
      $("#comments").addClass("faded");
    },
    hide_moderator_actions: function(id) {
      $("#" + id + " .js-moderator-debate-actions:first").hide();
    }
  };
}).call(this);
