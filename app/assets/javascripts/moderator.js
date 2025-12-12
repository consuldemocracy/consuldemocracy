(function() {
  "use strict";
  App.Moderator = {
    add_class_faded: function(id) {
      var isComment = id.indexOf("comment_") === 0;
      var isProposalNotification = id.indexOf("proposal_notification_") === 0;

      if (isComment) {
        $("#" + id + " .comment-body:first").addClass("faded");
      } else {
        var $element = $("#" + id);
        $element.addClass("faded");

        if (!isProposalNotification) {
          $("#comments").addClass("faded");
        }
      }
    },

    hide_moderator_actions: function(id) {
      $("#" + id + " .moderation-actions").hide();
    }
  };
}).call(this);
