(function() {
  "use strict";
  App.SDGRelatedListSelector = {
    initialize: function() {
      var $root = $(".sdg-related-list-selector");
      var $input;

      if (!$root.length) {
        return;
      }

      $input = $root.find("input.input");

      App.ListField.mount($input, {
        afterAdd: App.SDGRelatedListSelector.manage_add_help,
        afterRemove: App.SDGRelatedListSelector.manage_remove_help,
        checkboxListValue: App.SDGRelatedListSelector.goal_code,
        checkboxValueAttribute: "code",
        checkboxes: $root.find(".goals input"),
        inputClass: "sdg-related-list-selector-input",
        keepCheckboxChecked: function(value, selected_values) {
          return selected_values.some(function(selected_value) {
            return App.SDGRelatedListSelector.goal_code(value) ===
              App.SDGRelatedListSelector.goal_code(selected_value);
          });
        },
        suggestions: $input.data("suggestions-list"),
        whiteList: true
      });
    },
    goal_code: function(value) {
      return value.toString().split(".")[0];
    },
    manage_add_help: function(control, value) {
      var title = control.options[value].title;
      var html = "<li data-id=\"" + value + "\"><strong>" + value + "</strong> " + title + "</li>";

      $(".sdg-related-list-selector .help-section").removeClass("hide");
      $(".sdg-related-list-selector .selected-info").append(html);
    },
    manage_remove_help: function(control, value) {
      $("[data-id=\"" + value + "\"]").remove();

      if (control.items.length === 0) {
        $(".sdg-related-list-selector .help-section").addClass("hide");
      }
    }
  };
}).call(this);
