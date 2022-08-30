(function() {
  "use strict";
  App.AdminVotationTypesFields = {
    adjustForm: function() {
      if ($(this).val() === "unique") {
        $(".max-votes").hide();
        $(".description-unique").show();
        $(".description-multiple").hide();
        $(".votation-type-max-votes").prop("disabled", true);
      } else {
        $(".max-votes").show();
        $(".description-unique").hide();
        $(".description-multiple").show();
        $(".votation-type-max-votes").prop("disabled", false);
      }
    },
    initialize: function() {
      $(".votation-type-vote-type").on("change", App.AdminVotationTypesFields.adjustForm).trigger("change");
    }
  };
}).call(this);
