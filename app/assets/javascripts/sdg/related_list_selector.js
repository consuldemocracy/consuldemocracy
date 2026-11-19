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

      App.AmsifyListField.mount($input, {
        suggestions: $input.data("suggestions-list"),
        whiteList: true,
        classes: {
          sTagsInput: ".sdg-related-list-selector-input"
        },
        checkboxes: $root.find(".goals input"),
        checkboxValueAttribute: "code",
        checkboxListValue: App.SDGRelatedListSelector.goal_code,
        keepCheckboxChecked: function(value, selected_values) {
          return selected_values.some(function(selected_value) {
            return App.SDGRelatedListSelector.goal_code(value) ===
              App.SDGRelatedListSelector.goal_code(selected_value);
          });
        },
        afterAdd: function(amsify) {
          App.SDGRelatedListSelector.manage_help($root, amsify);
        },
        afterRemove: function(amsify) {
          App.SDGRelatedListSelector.manage_help($root, amsify);
        }
      });
    },
    goal_code: function(value) {
      return value.toString().split(".")[0];
    },
    manage_help: function($root, amsify) {
      var items = $(amsify.selector).val().split(",").filter(Boolean).map(function(value) {
        return $("<li>").text(" " + amsify.getItem(value).title).prepend($("<strong>").text(value));
      });

      $root.find(".selected-info").empty().append(items);
      $root.find(".help-section").toggleClass("hide", items.length === 0);
    }
  };
}).call(this);
