(function() {
  "use strict";
  App.Votations = {
    adjustForm: function() {
      if ($("#votation_type_enum_type").val() === "0") {
        $(".js-max-votes").hide();
        $(".js-description-unique").show();
        $(".js-description-multiple").hide();
        $(".js-description-prioritized").hide();
        $("#max_votes").attr({ disabled: true });
      } else if ($("#votation_type_enum_type").val() === "1") {
        $(".js-max-votes").show();
        $(".js-description-unique").hide();
        $(".js-description-multiple").show();
        $(".js-description-prioritized").hide();
        $("#max_votes").attr({ disabled: false });
      } else {
        $(".js-max-votes").show();
        $(".js-description-unique").hide();
        $(".js-description-multiple").hide();
        $(".js-description-prioritized").show();
        $("#max_votes").attr({ disabled: false });
      }
    },
    initialize: function() {
      $("#votation_type_enum_type").on({
        change: function() {
          App.Votations.adjustForm();
        }
      });
    }
  };
}).call(this);
