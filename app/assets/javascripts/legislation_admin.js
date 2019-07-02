(function() {
  "use strict";
  App.LegislationAdmin = {
    initialize: function() {
      $("input[type='checkbox'][data-disable-date]").on({
        change: function() {
          var checkbox, date_selector, parent;
          checkbox = $(this);
          parent = $(this).parents(".row:eq(0)");
          date_selector = $(this).data("disable-date");
          parent.find("input[type='text'][id^='" + date_selector + "']").each(function() {
            if (checkbox.is(":checked")) {
              $(this).removeAttr("disabled");
            } else {
              $(this).val("");
            }
          });
        }
      });
      $("#nested_question_options").on("cocoon:after-insert", function() {
        App.Globalize.refresh_visible_translations();
      });
    }
  };

}).call(this);
