(function() {
  "use strict";
  App.Tags = {
    initialize: function() {
      $(".taggable-fields").each(function() {
        App.ListField.mount($(this).find("input[type='text']"), {
          create: true,
          checkboxes: $(this).find(".tags input[type='checkbox']")
        });
      });
    }
  };
}).call(this);
