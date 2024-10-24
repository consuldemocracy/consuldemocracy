(function() {
  "use strict";
  App.BudgetHideMoney = {
    initialize: function() {
      $("#budget_voting_style").on({
        change: function() {
          if ($(this).val() === "approval") {
            $("#hide_money").removeClass("hide");
          } else {
            $("#budget_hide_money").prop("checked", false);
            $("#hide_money").addClass("hide");
          }
        }
      });
    }
  };
}).call(this);
