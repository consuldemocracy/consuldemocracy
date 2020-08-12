(function() {
  "use strict";
  App.MarkdownEditor = {
    refresh_preview: function(element, md) {
      var result, textarea_content;
      textarea_content = App.MarkdownEditor.find_textarea(element).val();
      result = md.render(textarea_content);
      element.find(".markdown-preview").html(result);
    },
    // Multi-locale (translatable) form fields work by hiding inputs of locales
    // which are not "active".
    find_textarea: function(editor) {
      return editor.find("textarea");
    },
    initialize: function() {
      $(".markdown-editor").each(function() {
        var editor, md;
        md = window.markdownit({
          html: true,
          breaks: true,
          typographer: true
        });
        editor = $(this);
        editor.on("input", function() {
          var textarea, warning;

          textarea = editor.find("textarea")[0];
          warning = $(this).closest(".translatable-fields").find(".warning");

          App.MarkdownEditor.refresh_preview($(this), md);

          if (textarea.value === textarea.defaultValue) {
            warning.hide();
          } else {
            warning.show();
          }
        });
        editor.find("textarea").on("scroll", function() {
          editor.find(".markdown-preview").scrollTop($(this).scrollTop());
        });
        editor.find(".fullscreen-toggle").on("click", function(e) {
          var span;
          e.preventDefault();
          e.stopPropagation();
          editor.toggleClass("fullscreen");
          $(".fullscreen-container").toggleClass("medium-8", "medium-12");
          span = $(this).find("span");
          if (span.text() === span.data("open-text")) {
            span.text(span.data("closed-text"));
          } else {
            span.text(span.data("open-text"));
          }
          if (editor.hasClass("fullscreen")) {
            App.MarkdownEditor.find_textarea(editor).height($(window).height() - 100);
            App.MarkdownEditor.refresh_preview(editor, md);
          } else {
            App.MarkdownEditor.find_textarea(editor).height("10em");
          }
        });
      });
    }
  };
}).call(this);
