(function() {
  "use strict";
  App.PollsForm = {
    updateMultipleChoiceStatus: function(fieldset) {
      var max_votes = $(fieldset).attr("data-max-votes");
      var checked_boxes = $(fieldset).find(":checkbox:checked");
      var unchecked_boxes = $(fieldset).find(":checkbox:not(:checked)");

      if (checked_boxes.length >= max_votes) {
        $(unchecked_boxes).prop("disabled", true);
      } else {
        $(fieldset).find(":checkbox").prop("disabled", false);
      }
    },
    initialize: function() {
      $(".poll-form .multiple-choice").each(function() {
        App.PollsForm.updateMultipleChoiceStatus(this);
      });

      $(".poll-form .multiple-choice :checkbox").on("change", function() {
        var fieldset = $(this).closest("fieldset");

        App.PollsForm.updateMultipleChoiceStatus(fieldset);
      });
    }
  };
}).call(this);
