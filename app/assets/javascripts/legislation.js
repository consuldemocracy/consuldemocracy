(function() {
  "use strict";
  App.Legislation = {
    initialize: function() {
      $("form#new_legislation_answer input.button, form[id^='edit_legislation_answer'] input.button").hide();
      $("form#new_legislation_answer input[type=radio], form[id^='edit_legislation_answer'] input[type=radio]").on({
        click: function() {
          $("form#new_legislation_answer, form[id^='edit_legislation_answer']").submit();
        }
      });
      $("form#draft_version_go_to_version input.button").hide();
      $("form#draft_version_go_to_version select").on({
        change: function() {
          $("form#draft_version_go_to_version").submit();
        }
      });
    }
  };
}).call(this);
