(function() {
  "use strict";
  App.SDGRelatedListSelector = {
    initialize: function() {
      var $root = $(".sdg-related-list-selector");
      var control;

      if (!$root.length) {
        return;
      }

      control = App.ListField.mount($root.find(".input"), {
        checkboxes: $root.find(".goals input"),
        checkboxValueAttribute: "code",
        checkboxListValue: App.SDGRelatedListSelector.goal_code
      });

      if (!control) {
        return;
      }

      control.on("change", function() {
        App.SDGRelatedListSelector.manage_help($root, control);
      });
      App.SDGRelatedListSelector.manage_help($root, control);
    },
    goal_code: function(code) {
      return code.split(".")[0];
    },
    manage_help: function($root, control) {
      var items = control.items.map(function(code) {
        return $("<li>").text(" " + control.options[code].title).prepend($("<strong>").text(code));
      });

      $root.find(".selected-info").empty().append(items);
      $root.find(".help-section").toggleClass("hide", items.length === 0);
    }
  };
}).call(this);
