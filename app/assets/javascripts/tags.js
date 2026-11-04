(function() {
  "use strict";
  App.Tags = {
    initialize: function() {
      $(".js-taggable-fields").each(function() {
        var $root = $(this);
        var $input = $root.find("input.js-tag-list");
        var options = {
          checkboxes: $root.find("input.js-tag-category"),
          inputClass: "js-tag-list-input"
        };
        var suggestions_url;

        if (!$input.length) {
          return;
        }

        suggestions_url = $input.data("suggestions-url");
        if (suggestions_url) {
          options.suggestionsUrl = suggestions_url;
        }

        App.ListField.mount($input, options);
      });
    }
  };
}).call(this);
