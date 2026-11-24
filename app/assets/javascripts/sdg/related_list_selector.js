(function() {
  "use strict";
  App.SDGRelatedListSelector = {
    initialize: function() {
      var $root = $(".sdg-related-list-selector");
      var input;

      if (!$root.length) {
        return;
      }

      input = App.ListField.mount($root.find(".input"), {
        checkboxes: $root.find(".goals input"),
        checkboxValueAttribute: "code",
        checkboxListValue: App.SDGRelatedListSelector.goal_code
      });

      if (!input) {
        return;
      }

      input.on("change", function() {
        App.SDGRelatedListSelector.manage_help($root, input);
      });
      App.SDGRelatedListSelector.manage_help($root, input);
    },
    goal_code: function(value) {
      return value.toString().split(".")[0];
    },
    manage_help: function($root, input) {
      var items = input.items.map(function(value) {
        return $("<li>").text(" " + input.options[value].title).prepend($("<strong>").text(value));
      });

      $root.find(".selected-info").empty().append(items);
      $root.find(".help-section").toggleClass("hide", items.length === 0);
    }
  };
}).call(this);
