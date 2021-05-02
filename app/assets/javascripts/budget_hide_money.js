(function() {
  "use strict";
  App.BudgetHideMoney = {
    initialize: function() {
      $("#budget_voting_style").on({
        change: function() {
          if ($(this).val() === "approval") {
            $("#hide_money").removeClass("hide");
          } else {
            $("#hide_money_checkbox").prop("checked", false);
            $("#hide_money").addClass("hide");
          }
        }
      });
    }
  };
}).call(this);
