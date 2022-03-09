(function() {
  "use strict";
  App.SDGSyncGoalAndTargetFilters = {
    sync: function(form) {
      var goal_filter = form.find("[name*=goal]");
      var target_filter = form.find("[name*=target]");

      goal_filter.on("change", function() {
        if (this.value) {
          App.SDGSyncGoalAndTargetFilters.enable_goal_options(target_filter, this.value);
        } else {
          target_filter.find("option").prop("disabled", false).prop("hidden", false);
        }
      }).trigger("change");
    },
    enable_goal_options: function(target_filter, goal_code) {
      var base_target_code = goal_code + ".";
      var target_selector = "[value^='" + base_target_code + "'], [value='']";

      target_filter.find("option" + target_selector).prop("disabled", false).prop("hidden", false);
      target_filter.find("option:not(" + target_selector + ")").prop("disabled", true).prop("hidden", true);

      if (!target_filter[0].value.startsWith(base_target_code)) {
        target_filter.val("");
      }
    }
  };
}).call(this);
