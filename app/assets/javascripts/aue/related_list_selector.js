(function () {
  "use strict";
  App.AUERelatedListSelector = {
    initialize: function () {
      if ($(".aue-related-list-selector").length) {
        var amsify_suggestags = new AmsifySuggestags(
          $(".aue-related-list-selector .input")
        );

        amsify_suggestags.getItem = function (value) {
          var item_key = this.getItemKey(value);
          return this.settings.suggestions[item_key];
        };

        amsify_suggestags.getTag = function (value) {
          if (this.getItem(value) !== undefined) {
            return $(
              "<div>" + this.getItem(value).display_text + "</div>"
            ).text();
          } else {
            return value;
          }
        };

        amsify_suggestags.setIcon = function () {
          var remove_tag_text = $(".aue-related-list-selector .input").data(
            "remove-tag-text"
          );
          return (
            '<button aria-label="' +
            remove_tag_text +
            '" class="remove-tag ' +
            this.classes.removeTag.substring(1) +
            '">&#10006;</button>'
          );
        };

        amsify_suggestags._settings({
          suggestions: $(".aue-related-list-selector .input").data(
            "suggestions-list"
          ),
          whiteList: true,
          afterRemove: function (value) {
            var keep_goal = $(amsify_suggestags.selector)
              .val()
              .split(",")
              .some(function (selected_value) {
                return (
                  App.AUERelatedListSelector.goal_code(value) ===
                  App.AUERelatedListSelector.goal_code(selected_value)
                );
              });
            App.AUERelatedListSelector.goal_element(value).prop(
              "checked",
              keep_goal
            );
            App.AUERelatedListSelector.manage_remove_help(
              amsify_suggestags,
              value
            );
          },
          afterAdd: function (value) {
            App.AUERelatedListSelector.goal_element(value).prop(
              "checked",
              true
            );
            App.AUERelatedListSelector.manage_add_help(
              amsify_suggestags,
              value
            );
          },
          keepLastOnHoverTag: false,
          checkSimilar: false,
        });
        amsify_suggestags.classes.focus = ".aue-related-list-focus";
        amsify_suggestags.classes.sTagsInput =
          ".aue-related-list-selector-input";
        amsify_suggestags._init();
        App.AUERelatedListSelector.manage_icons(amsify_suggestags);
        App.AUERelatedListSelector.fix_label(amsify_suggestags);
      }
    },
    manage_icons: function (amsify_suggestags) {
      $(".aue-related-list-selector .goals input")
        .on("change", function () {
          var goal_id = this.dataset.code;

          if (amsify_suggestags.isPresent(goal_id)) {
            amsify_suggestags.removeTag(goal_id, false);
          } else {
            amsify_suggestags.addTag(goal_id, false);
          }
        })
        .on("keydown", function (event) {
          if (event.keyCode === 13) {
            $(this).trigger("click");
            event.preventDefault();
            event.stopPropagation();
          }
        });
    },
    goal_element: function (value) {
      return $(
        ".aue-related-list-selector .goals [data-code=" +
          App.AUERelatedListSelector.goal_code(value) +
          "]"
      );
    },
    goal_code: function (value) {
      return value.toString().split(".")[0];
    },
    manage_add_help: function (amsify_suggestags, value) {
      var title = amsify_suggestags.getItem(value).title;
      var html =
        '<li data-id="' +
        value +
        '">' +
        "<strong>" +
        value +
        "</strong> " +
        title +
        "</li>";
      $(".aue-related-list-selector .help-section").removeClass("hide");
      $(".aue-related-list-selector .selected-info").append(html);
    },
    manage_remove_help: function (amsify_suggestags, value) {
      $('[data-id="' + value + '"]').remove();
      if ($(amsify_suggestags.selector).val() === "") {
        $(".aue-related-list-selector .help-section").addClass("hide");
      }
    },
    fix_label: function (amsify_suggestags) {
      var original_input = amsify_suggestags.selector;
      var suggestions_input = amsify_suggestags.selectors.sTagsInput;

      suggestions_input[0].id = original_input[0].id + "_suggestions";

      $("[for='" + original_input[0].id + "']").attr(
        "for",
        suggestions_input[0].id
      );

      suggestions_input.attr(
        "aria-describedby",
        original_input.attr("aria-describedby")
      );

      if ($(original_input).attr("placeholder") === undefined) {
        suggestions_input.removeAttr("placeholder");
      }
    },
  };
}.call(this));
