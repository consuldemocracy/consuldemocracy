(function() {
  "use strict";
  App.ModeratorComments = {
    add_class_faded: function(id) {
      $("#" + id + " .comment-body:first").addClass("faded");
    },
    hide_moderator_actions: function(id) {
      $("#" + id + " .js-moderator-comment-actions").hide();
    },
    hide_comment: function(id) {
      $("#" + id + " .comment-body:first").fadeOut("slow");
    },
    hide_childrens: function(comments_without_children) {
      comments_without_children.split(",").forEach(function(id) {
        $("#" + id + "_children").addClass("hide");
      });
    }
  };
}).call(this);
