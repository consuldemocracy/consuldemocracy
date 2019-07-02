(function() {
  "use strict";
  App.PreventDoubleSubmission = {
    disable_buttons: function(buttons) {
      setTimeout(function() {
        buttons.each(function() {
          var button, loading, ref;
          button = $(this);
          if (!button.hasClass("disabled")) {
            loading = (ref = button.data("loading")) != null ? ref : "...";
            button.addClass("disabled").attr("disabled", "disabled");
            button.data("text", button.val());
            button.val(loading);
          }
        });
      }, 1);
    },
    reset_buttons: function(buttons) {
      buttons.each(function() {
        var button, button_text;
        button = $(this);
        if (button.hasClass("disabled")) {
          button_text = button.data("text");
          button.removeClass("disabled").attr("disabled", null);
          if (button_text) {
            button.val(button_text);
            button.data("text", null);
          }
        }
      });
    },
    initialize: function() {
      $("form").on("submit", function(event) {
        var buttons;
        if (!(event.target.id === "new_officing_voter" || event.target.id === "admin_download_emails")) {
          buttons = $(this).find(":button, :submit");
          App.PreventDoubleSubmission.disable_buttons(buttons);
        }
      }).on("ajax:success", function(event) {
        var buttons;
        if (!(event.target.id === "new_officing_voter" || event.target.id === "admin_download_emails")) {
          buttons = $(this).find(":button, :submit");
          App.PreventDoubleSubmission.reset_buttons(buttons);
        }
      });
    }
  };

}).call(this);
