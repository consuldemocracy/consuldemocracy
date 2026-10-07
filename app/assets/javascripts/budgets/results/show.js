(function() {
  "use strict";
  App.BudgetsResultsShow = {
    initialize: function() {
      $("body").on("click", ".budget-result-show .js-toggle-link", function() {
        var toggle_txt;
        $(".js-discarded").toggle("down");
        if ($(this).data("toggle-text") !== undefined) {
          toggle_txt = $(this).text();
          $(this).text($(this).data("toggle-text"));
          $(this).data("toggle-text", toggle_txt);
        }
        return false;
      });
    },
  };
}).call(this);
