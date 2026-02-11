(function() {
  "use strict";
  App.Moderator = {
    add_class_faded: function(id) {
      var is_comment = id.startsWith("comment_");
      var is_proposal_notification = id.startsWith("proposal_notification_");

      if (is_comment) {
        $("#" + id + " .comment-body:first").addClass("faded");
      } else {
        $("#" + id).addClass("faded");

        if (!is_proposal_notification) {
          $("#comments").addClass("faded");
        }
      }
    },
  };
}).call(this);
