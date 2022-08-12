(function() {
  "use strict";
  App.InvestmentReportAlert = {
    initialize: function() {
      $("#js-investment-report-alert").on("click", function() {
        if (this.checked && $("#budget_investment_feasibility_unfeasible").is(":checked")) {
          return confirm(this.dataset.alert);
        } else if (this.checked) {
          return confirm(this.dataset.alert);
        }
      });
    }
  };
}).call(this);
