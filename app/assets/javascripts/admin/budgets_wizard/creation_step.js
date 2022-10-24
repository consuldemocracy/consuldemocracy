(function() {
  "use strict";
  App.AdminBudgetsWizardCreationStep = {
    initialize: function() {
      var element, add_button, cancel_button;

      element = $(".admin .budget-creation-step");
      add_button = element.find(".add");
      cancel_button = element.find(".delete");

      add_button.click(function() {
        $(this).attr("aria-expanded", true).parent().find(":input:visible:first").focus();
      });

      cancel_button.click(function() {
        add_button.attr("aria-expanded", false).focus();
      });
    }
  };
}).call(this);
