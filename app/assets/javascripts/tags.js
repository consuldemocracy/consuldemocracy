(function() {
  "use strict";
  App.Tags = {
    initialize: function() {
      $(".taggable-fields").each(function() {
        App.ListField.mount($(this).find("input.js-tag-list"), {
          create: true,
          checkboxes: $(this).find("input.js-tag-category")
        });
      });
    }
  };
}).call(this);
