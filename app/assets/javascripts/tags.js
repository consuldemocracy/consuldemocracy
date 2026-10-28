(function() {
  "use strict";
  App.Tags = {
    initialize: function() {
      $(".js-taggable-fields").each(function() {
        var $root = $(this);
        var $input = $root.find("input.js-tag-list");
        var options;
        var suggestions_url;

        if (!$input.length) {
          return;
        }

        options = {
          whiteList: false,
          checkboxes: $root.find("input.js-tag-category"),
          classes: {
            sTagsInput: ".js-tag-list-input"
          }
        };

        suggestions_url = $input.data("suggestions-url");
        if (suggestions_url) {
          options.suggestionsUrl = suggestions_url;
        }

        App.AmsifyListField.mount($input, options);
      });
    }
  };
}).call(this);
