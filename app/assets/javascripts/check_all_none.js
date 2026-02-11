(function() {
  "use strict";
  App.CheckAllNone = {
    initialize: function() {
      $(".check-all-none button").on("click", function() {
        var fields = App.CheckAllNone.associated_fields($(this));

        if ($(this).data("check-all")) {
          fields.prop("checked", true);
        } else if ($(this).data("check-none")) {
          fields.prop("checked", false);
        }
      });
    },
    associated_fields: function(element) {
      if (element.closest("fieldset").length) {
        return $("[type='checkbox']", element.closest("fieldset"));
      } else {
        return $("[type='checkbox']", element.closest("form"));
      }
    }
  };
}).call(this);
