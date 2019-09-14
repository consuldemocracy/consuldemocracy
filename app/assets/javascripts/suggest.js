(function() {
  "use strict";
  App.Suggest = {
    initialize: function() {
      $("[data-js-suggest-result]").each(function() {
        var $this, callback, timer;
        $this = $(this);
        callback = function() {
          $.ajax({
            url: $this.data("js-url"),
            data: {
              search: $this.val()
            },
            type: "GET",
            dataType: "html",
            success: function(stHtml) {
              var js_suggest_selector, locale;
              js_suggest_selector = $this.data("js-suggest");

              if (js_suggest_selector.startsWith(".")) {
                locale = $this.closest(".translatable-fields").data("locale");
                js_suggest_selector += "[data-locale=" + locale + "]";
              }
              $(js_suggest_selector).html(stHtml);
            }
          });
        };
        timer = null;
        $this.on("keyup", function() {
          window.clearTimeout(timer);
          timer = window.setTimeout(callback, 1000);
        });
        $this.on("change", callback);
      });
    }
  };
}).call(this);
