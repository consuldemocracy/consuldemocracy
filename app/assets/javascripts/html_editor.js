(function() {
  "use strict";
  App.HTMLEditor = {
    destroy: function() {
      for (var name in CKEDITOR.instances) {
        CKEDITOR.instances[name].destroy();
      }
    },
    initialize: function() {
      $("textarea.html-area").each(function() {
        if ($(this).hasClass("admin")) {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "admin", height: 500 });
        } else {
          CKEDITOR.replace(this.name, { language: $("html").attr("lang") });
        }
      });
    }
  };

  $(document).on("turbolinks:before-cache", App.HTMLEditor.destroy);
}).call(this);
