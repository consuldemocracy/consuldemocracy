(function() {
  "use strict";
  App.CheckboxToggle = {
    initialize: function() {
      $("[data-checkbox-toggle]").on("change", function() {
        var $target;
        $target = $($(this).data("checkbox-toggle"));

        if ($(this).is(":checked")) {
          $target.show();
        } else {
          $target.hide();
        }
      });
    }
  };
}).call(this);
