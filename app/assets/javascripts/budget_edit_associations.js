(function() {
  "use strict";
  App.BudgetEditAssociations = {
    initialize: function() {
      $(".js-budget-users-list [type='checkbox']").on({
        change: function() {
          var admin_count, valuator_count;

          admin_count = $("#administrators_list :checked").length;
          valuator_count = $("#valuators_list :checked").length;

          App.I18n.set_pluralize($(".js-budget-show-administrators-list"), admin_count);
          App.I18n.set_pluralize($(".js-budget-show-valuators-list"), valuator_count);
        }
      });
      $(".js-budget-show-users-list").on({
        click: function(e) {
          var div_id;

          e.preventDefault();
          div_id = $(this).data().toggle;
          $(".js-budget-users-list").each(function() {
            if (this.id !== div_id && !$(this).hasClass("is-hidden")) {
              $(this).addClass("is-hidden");
            }
          });
        }
      });
    }
  };
}).call(this);
