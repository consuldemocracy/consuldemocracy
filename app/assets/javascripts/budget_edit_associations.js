(function() {
  "use strict";
  App.BudgetEditAssociations = {
    initialize: function() {
      $(".js-budget-list-checkbox-user").on({
        click: function() {
          var admin_count, tracker_count, valuator_count;

          admin_count = $(".js-budget-list-checkbox-administrators:checkbox:checked").length;
          valuator_count = $(".js-budget-list-checkbox-valuators:checkbox:checked").length;
          tracker_count = $(".js-budget-list-checkbox-trackers:checkbox:checked").length;

          App.I18n.set_pluralize($(".js-budget-show-administrators-list"), admin_count);
          App.I18n.set_pluralize($(".js-budget-show-valuators-list"), valuator_count);
          App.I18n.set_pluralize($(".js-budget-show-trackers-list"), tracker_count);
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
