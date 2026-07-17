(function() {
  "use strict";
  App.PollsForm = {
    syncOpenText: function(input) {
      var $input = $(input);
      var $textarea = $(".open-text[data-selects='" + $input.attr("id") + "']");

      if ($textarea.length) {
        $textarea.prop("disabled", !$input.prop("checked") || $input.prop("disabled"));
      }
    },
    updateMultipleChoiceStatus: function(fieldset) {
      var max_votes = $(fieldset).attr("data-max-votes");
      var checked_boxes = $(fieldset).find(":checkbox:checked");
      var unchecked_boxes = $(fieldset).find(":checkbox:not(:checked)");

      if (checked_boxes.length >= max_votes) {
        $(unchecked_boxes).prop("disabled", true);
      } else {
        $(fieldset).find(":checkbox").prop("disabled", false);
      }

      $(fieldset).find(":checkbox").each(function() {
        App.PollsForm.syncOpenText(this);
      });
    },
    updateRadioChoiceStatus: function(fieldset) {
      $(fieldset).find(":radio").each(function() {
        App.PollsForm.syncOpenText(this);
      });
    },

    initialize: function() {
      $(".poll-form .multiple-choice").each(function() {
        App.PollsForm.updateMultipleChoiceStatus(this);
      });

      $(".poll-form .multiple-choice").off("change.pollsform").on("change.pollsform", ":checkbox", function() {
        App.PollsForm.updateMultipleChoiceStatus($(this).closest("fieldset")[0]);
      });

      $(".poll-form .single-choice").each(function() {
        App.PollsForm.updateRadioChoiceStatus(this);
      });

      $(".poll-form .single-choice").off("change.pollsform").on("change.pollsform", ":radio", function() {
        App.PollsForm.updateRadioChoiceStatus($(this).closest("fieldset")[0]);
      });
    }
  };
}).call(this);
