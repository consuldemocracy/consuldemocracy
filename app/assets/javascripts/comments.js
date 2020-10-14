(function() {
  "use strict";
  App.Comments = {
    add_comment: function(parent_selector, response_html) {
      $(parent_selector + " .comment-list:first").prepend($(response_html)).show("slow");
      $(parent_selector + " .responses-count:first").removeClass("collapsed");
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
    update_responses_count: function(comment_id, responses_count_html) {
      $(comment_id + "_reply .responses-count").html(responses_count_html);
    },
    display_error: function(field_with_errors, error_html) {
      $(error_html).insertAfter($("" + field_with_errors));
    },
    reset_form: function(parent_selector) {
      var form_container;

      form_container = $(parent_selector + " .comment-form:first");
      form_container.find("textarea").val("");

      if (parent_selector !== "") {
        form_container.hide();
      }
    },
    toggle_form: function(id) {
      $("#js-comment-form-" + id).toggle();
    },
    initialize: function() {
      $("body").on("click", ".js-add-comment-link", function() {
        App.Comments.toggle_form($(this).data().id);
        return false;
      });

      $("body").on("click", ".js-toggle-children", function() {
        $(this).closest(".comment").find(".comment-list:first").toggle("slow");
        $(this).closest(".responses-count").toggleClass("collapsed");
        return false;
      });
    }
  };
}).call(this);
