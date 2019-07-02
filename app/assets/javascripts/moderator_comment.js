(function() {
  "use strict";
  App.ModeratorComments = {
    add_class_faded: function(id) {
      $("#" + id + " .comment-body:first").addClass("faded");
    },
    hide_moderator_actions: function(id) {
      $("#" + id + " .js-moderator-comment-actions").hide();
    }
  };
}).call(this);
