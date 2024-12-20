(function() {
  "use strict";
  App.AdminVotationTypesFields = {
    adjustForm: function() {
      if ($(this).val() === "multiple") {
        $(".max-votes").show();
        $(".description-unique").hide();
          $(".description-essay").hide();
        $(".description-multiple").show();
        $(".votation-type-max-votes").prop("disabled", false);
      } else {
        $(".max-votes").hide();
        $(".description-multiple").hide();
        $(".votation-type-max-votes").prop("disabled", true);
        if ($(this).val() === "unique") {
          $(".description-unique").show();
          $(".description-essay").hide();
        } else {
          $(".description-unique").hide();
          $(".description-essay").show();
        }
      }
    },
    initialize: function() {
      $(".votation-type-vote-type").on("change", App.AdminVotationTypesFields.adjustForm).trigger("change");
    }
  };
}).call(this);
