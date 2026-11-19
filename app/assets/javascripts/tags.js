(function() {
  "use strict";
  App.Tags = {
    initialize: function() {
      $(".taggable-fields").each(function() {
        var $input = $(this).find("input.js-tag-list");

        App.AmsifyListField.mount($input, {
          whiteList: false,
          checkboxes: $(this).find("input.js-tag-category"),
          classes: {
            sTagsInput: ".js-tag-list-input"
          },
          suggestionsUrl: $input.data("suggestions-url")
        });
      });
    }
  };
}).call(this);
