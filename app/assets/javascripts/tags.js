(function() {
  "use strict";
  App.Tags = {
    initialize: function() {
      $(".taggable-fields").each(function() {
        var $input = $(this).find("input.js-tag-list");

        App.ListField.mount($input, {
          create: true,
          checkboxes: $(this).find("input.js-tag-category")
        });
      });
    }
  };
}).call(this);
