(function() {
  "use strict";
  App.PollsForm = {
    updateMultipleChoiceStatus: function(fieldset) {
      var max_votes = $(fieldset).attr("data-max-votes");
      var checked_boxes = $(fieldset).find(":checkbox:checked");
      var unchecked_boxes = $(fieldset).find(":checkbox:not(:checked)");

      if (checked_boxes.length >= max_votes) {
        $(unchecked_boxes).prop("disabled", true).each(function() {
          $(".open-text[data-selects='" + this.id + "']").prop("disabled", true);
        });
      } else {
        $(fieldset).find(":checkbox").prop("disabled", false).each(function() {
          $(".open-text[data-selects='" + this.id + "']").prop("disabled", false);
        });
      }
    },
    updateRadioChoiceStatus: function(fieldset) {
      var $radios = $(fieldset).find(":radio");
      var $selected = $radios.filter(":checked");

      if ($selected.length === 0) {
        $radios.each(function() {
          $(".open-text[data-selects='" + this.id + "']").prop("disabled", false);
        });
      } else {
        var selectedId = $selected.attr("id");
        $radios.each(function() {
          $(".open-text[data-selects='" + this.id + "']").prop("disabled", this.id !== selectedId);
        });
      }
    },
    markAssociatedInput: function(element) {
      var targetId = $(element).data("selects");
      var $input = $("#" + targetId);

      if ($input.length && !$input.prop("disabled")) {
        var type = ($input.attr("type") || "").toLowerCase();
        if ((type === "radio" || type === "checkbox") && !$input.prop("checked")) {
          $input.prop("checked", true).trigger("change");
        }
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

      $(".poll-form fieldset").each(function() {
        App.PollsForm.updateRadioChoiceStatus(this);
      });

      $(".poll-form :radio").on("change", function() {
        var fieldset = $(this).closest("fieldset");

        App.PollsForm.updateRadioChoiceStatus(fieldset);
      });

      $(".poll-form .open-text").on("focus", function() {
        App.PollsForm.markAssociatedInput(this);
      });
    }
  };
}).call(this);
