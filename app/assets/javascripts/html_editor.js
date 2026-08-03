(function() {
  "use strict";
  App.HTMLEditor = {
    initialize: function() {
      $("textarea.html-area").each(function() {
        var $el = $(this);
        var opts = { language: $("html").attr("lang") };

        if ($el.hasClass("admin")) {
          opts.toolbar = "admin";
          opts.height = 500;
        } else if ($el.data("speechToTextEnabled") === true) {
          opts.toolbar = "mini_speech";
          opts.extraPlugins = "speechtotext";
        }

        CKEDITOR.replace(this.name, opts);
      });
    },
    destroy: function() {
      for (var name in CKEDITOR.instances) {
        CKEDITOR.instances[name].destroy();
      }
    }
  };
}).call(this);
