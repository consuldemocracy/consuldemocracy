(function() {
  "use strict";
  App.AdminVotationTypesFields = {
    adjustForm: function() {
      var select_field = $(this);

      $("[data-vote-type]").hide(0, function() {
        $("[data-vote-type=" + select_field.val() + "]").show();
      });

      if (select_field.val() === "multiple") {
        $(".max-votes").show();
        $(".votation-type-max-votes").prop("disabled", false);
      } else {
        $(".max-votes").hide();
        $(".votation-type-max-votes").prop("disabled", true);
      }
    },
    initialize: function() {
      $(".votation-type-vote-type").on("change", App.AdminVotationTypesFields.adjustForm).trigger("change");
    }
  };
}).call(this);
