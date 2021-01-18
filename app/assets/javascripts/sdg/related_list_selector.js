(function() {
  "use strict";
  App.SDGRelatedListSelector = {
    initialize: function() {
      if ($(".sdg-related-list-selector").length) {
        var amsify_suggestags = new AmsifySuggestags($(".sdg-related-list-selector .input"));

        amsify_suggestags._settings({
          suggestions: $(".sdg-related-list-selector .input").data("suggestions-list"),
          whiteList: true,
          afterRemove: function(value) {
            var keep_goal = $(amsify_suggestags.selector).val().split(",").some(function(selected_value) {
              return App.SDGRelatedListSelector.goal_code(value) === App.SDGRelatedListSelector.goal_code(selected_value);
            });
            App.SDGRelatedListSelector.goal_element(value).attr("aria-checked", keep_goal);
          },
          afterAdd: function(value) {
            App.SDGRelatedListSelector.goal_element(value).attr("aria-checked", true);
          },
          keepLastOnHoverTag: false,
          checkSimilar: false
        });
        amsify_suggestags.classes.focus = ".sdg-related-list-focus";
        amsify_suggestags.classes.sTagsInput = ".sdg-related-list-selector-input";
        amsify_suggestags._init();
        App.SDGRelatedListSelector.manage_icons(amsify_suggestags);
      }
    },
    manage_icons: function(amsify_suggestags) {
      $("[role='checkbox']").on("click keydown", function(event) {
        var goal_id = this.dataset.code;

        if (event.type === "click" || (event.type === "keydown" && [13, 32].indexOf(event.keyCode) >= 0)) {
          if (amsify_suggestags.isPresent(goal_id)) {
            amsify_suggestags.removeTag(goal_id, false);
          } else {
            amsify_suggestags.addTag(goal_id, false);
          }

          event.preventDefault();
          event.stopPropagation();
        }
      });
    },
    goal_element: function(value) {
      return $("li[data-code=" + App.SDGRelatedListSelector.goal_code(value) + "]");
    },
    goal_code: function(value) {
      return value.toString().split(".")[0];
    }
  };
}).call(this);
