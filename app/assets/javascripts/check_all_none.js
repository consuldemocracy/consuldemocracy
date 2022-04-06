(function() {
  "use strict";
  App.CheckAllNone = {
    initialize: function() {
      $("[data-check-all]").on("click", function(e) {
        var target_name;
        e.preventDefault();
        e.stopPropagation();
        target_name = $(this).data("check-all");
        $("[name='" + target_name + "']").prop("checked", true);
      });
      $("[data-check-none]").on("click", function(e) {
        var target_name;
        e.preventDefault();
        e.stopPropagation();
        target_name = $(this).data("check-none");
        $("[name='" + target_name + "']").prop("checked", false);
      });
    }
  };
}).call(this);
