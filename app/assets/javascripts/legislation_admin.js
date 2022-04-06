(function() {
  "use strict";
  App.LegislationAdmin = {
    initialize: function() {
      $(".legislation-process-form").find("[name$='enabled]'],[name$='[published]']").on({
        change: function() {
          var checkbox;
          checkbox = $(this);

          checkbox.closest("fieldset").find("input[type='date']").each(function() {
            $(this).prop("disabled", !checkbox.is(":checked"));
          });
        }
      }).trigger("change");

      $("#nested_question_options").on("cocoon:after-insert", function() {
        App.Globalize.refresh_visible_translations();
      });
    }
  };
}).call(this);
