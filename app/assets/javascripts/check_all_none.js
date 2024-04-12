(function() {
  "use strict";
  App.CheckAllNone = {
    initialize: function() {
      $("[data-check-all]").on("click", function() {
        App.CheckAllNone.associated_fields($(this), "check-all").prop("checked", true);
      });
      $("[data-check-none]").on("click", function() {
        App.CheckAllNone.associated_fields($(this), "check-none").prop("checked", false);
      });
    },
    associated_fields: function(element, data_attribute) {
      return $("[name='" + element.data(data_attribute) + "']");
    }
  };
}).call(this);
