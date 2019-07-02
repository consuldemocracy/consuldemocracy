(function() {
  "use strict";
  App.Comments = {
    add_comment: function(parent_id, response_html) {
      $(response_html).insertAfter($("#js-comment-form-" + parent_id));
      this.update_comments_count();
    },
    add_reply: function(parent_id, response_html) {
      if ($("#" + parent_id + " .comment-children").length === 0) {
        $("#" + parent_id).append("<li><ul id='" + parent_id + "_children' class='no-bullet comment-children'></ul></li>");
      }
      $("#" + parent_id + " .comment-children:first").prepend($(response_html));
      this.update_comments_count();
    },
    update_comments_count: function() {
      $(".js-comments-count").each(function() {
        var new_val;
        new_val = $(this).text().trim().replace(/\d+/, function(match) {
          return parseInt(match, 10) + 1;
        });
        $(this).text(new_val);
      });
    },
    display_error: function(field_with_errors, error_html) {
      $(error_html).insertAfter($("" + field_with_errors));
    },
    reset_and_hide_form: function(id) {
      var form_container, input;
      form_container = $("#js-comment-form-" + id);
      input = form_container.find("form textarea");
      input.val("");
      form_container.hide();
    },
    reset_form: function(id) {
      var input;
      input = $("#js-comment-form-" + id + " form textarea");
      input.val("");
    },
    toggle_form: function(id) {
      $("#js-comment-form-" + id).toggle();
    },
    toggle_arrow: function(id) {
      var arrow;
      arrow = "span#" + id + "_arrow";
      if ($(arrow).hasClass("icon-arrow-right")) {
        $(arrow).removeClass("icon-arrow-right").addClass("icon-arrow-down");
      } else {
        $(arrow).removeClass("icon-arrow-down").addClass("icon-arrow-right");
      }
    },
    initialize: function() {
      $("body .js-add-comment-link").each(function() {
        if ($(this).data("initialized") !== "yes") {
          $(this).on("click", function() {
            App.Comments.toggle_form($(this).data().id);
            return false;
          }).data("initialized", "yes");
        }
      });
      $("body .js-toggle-children").each(function() {
        $(this).on("click", function() {
          var children_container_id;
          children_container_id = ($(this).data().id) + "_children";
          $("#" + children_container_id).toggle("slow");
          App.Comments.toggle_arrow(children_container_id);
          $(this).children(".js-child-toggle").toggle();
          return false;
        });
      });
    }
  };

}).call(this);
