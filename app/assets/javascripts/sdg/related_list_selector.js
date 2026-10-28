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
          focus: ".sdg-related-list-focus",
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
        afterAdd: function(amsify, value) {
          App.SDGRelatedListSelector.manage_add_help(amsify, value);
        },
        afterRemove: function(amsify, value) {
          App.SDGRelatedListSelector.manage_remove_help(amsify, value);
        }
      });
    },
    goal_code: function(value) {
      return value.toString().split(".")[0];
    },
    manage_add_help: function(amsify_suggestags, value) {
      var title = amsify_suggestags.getItem(value).title;
      var html = '<li data-id="' + value + '">' + "<strong>" + value + "</strong> " + title + "</li>";
      $(".sdg-related-list-selector .help-section").removeClass("hide");
      $(".sdg-related-list-selector .selected-info").append(html);
    },
    manage_remove_help: function(amsify_suggestags, value) {
      $('[data-id="' + value + '"]').remove();
      if ($(amsify_suggestags.selector).val() === "") {
        $(".sdg-related-list-selector .help-section").addClass("hide");
      }
    }
  };
}).call(this);
