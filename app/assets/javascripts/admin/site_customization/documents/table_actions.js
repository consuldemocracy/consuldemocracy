(function() {
  "use strict";
  App.AdminSiteCustomizationDocumentsTableActions = {
    initialize: function() {
      $(".admin .site-customization-documents-table-actions .copy-link").on("click", function() {
        var url = $(this).siblings(".download-link").prop("href");

        App.AdminSiteCustomizationDocumentsTableActions.copy_to_clipboard($(this), url);
      });
    },
    copy_to_clipboard: function(button, url) {
      var show_copied_feedback = function() {
        if (!button.data("original-text")) {
          button.data("original-text", button.text());
          button.data("original-aria-label", button.attr("aria-label"));
        }

        if (button.data("revert-timer")) {
          clearTimeout(button.data("revert-timer"));
        }

        button.text(button.data("copied-text"));
        button.attr("aria-label", button.data("copied-text"));
        button.addClass("copied");

        button.data("revert-timer", setTimeout(function() {
          button.text(button.data("original-text"));
          button.attr("aria-label", button.data("original-aria-label"));
          button.removeClass("copied");
        }, 2000));
      };

      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(url).then(show_copied_feedback);
      } else {
        var textarea = document.createElement("textarea");

        textarea.value = url;
        textarea.style.position = "fixed";
        textarea.style.opacity = "0";

        document.body.appendChild(textarea);
        textarea.select();
        var successful = document.execCommand("copy");
        document.body.removeChild(textarea);

        if (successful) {
          show_copied_feedback();
        }
      }
    }
  };
}).call(this);
