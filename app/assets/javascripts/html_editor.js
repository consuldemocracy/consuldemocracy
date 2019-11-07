(function() {
  "use strict";
  App.HTMLEditor = {
    initialize: function() {
      $("textarea.html-area").each(function() {
        if ($(this).hasClass("admin")) {
          CKEDITOR.inline(this.name, { language: $("html").attr("lang"), toolbar: "admin" });
        } else {
          CKEDITOR.inline(this.name, { language: $("html").attr("lang") });
        }
      });
    }
  };
}).call(this);
