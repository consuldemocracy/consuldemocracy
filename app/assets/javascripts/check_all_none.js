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
      if (element.data("field-name")) {
        return $("[name='" + element.data("field-name") + "']");
      } else {
        return $("[type='checkbox']", element.closest("fieldset"));
      }
    }
  };
}).call(this);
