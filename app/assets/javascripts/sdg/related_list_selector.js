(function() {
  "use strict";
  App.SDGRelatedListSelector = {
    initialize: function() {
      var $root = $(".sdg-related-list-selector");
      var $input;

      if (!$root.length) {
        return;
      }

      $input = $root.find(".input");

      App.ListField.mount($input, {
        suggestions: $input.data("suggestions-list"),
        whiteList: true,
        inputClass: "sdg-related-list-selector-input",
        checkboxes: $root.find(".goals input"),
        checkboxValueAttribute: "code",
        checkboxListValue: App.SDGRelatedListSelector.goal_code,
        keepCheckboxChecked: function(value, selected_values) {
          return selected_values.some(function(selected_value) {
            return App.SDGRelatedListSelector.goal_code(value) ===
              App.SDGRelatedListSelector.goal_code(selected_value);
          });
        },
        afterAdd: function(control, value) {
          App.SDGRelatedListSelector.manage_add_help(control, value);
        },
        afterRemove: function(control, value) {
          App.SDGRelatedListSelector.manage_remove_help(control, value);
        }
      });
    },
    goal_code: function(value) {
      return value.toString().split(".")[0];
    },
    manage_add_help: function(control, value) {
      var title = control.options[value].title;
      var html = '<li data-id="' + value + '">' + "<strong>" + value + "</strong> " + title + "</li>";
      $(".sdg-related-list-selector .help-section").removeClass("hide");
      $(".sdg-related-list-selector .selected-info").append(html);
    },
    manage_remove_help: function(control, value) {
      $('[data-id="' + value + '"]').remove();
      if ($(control.input).val() === "") {
        $(".sdg-related-list-selector .help-section").addClass("hide");
      }
    }
  };
}).call(this);
