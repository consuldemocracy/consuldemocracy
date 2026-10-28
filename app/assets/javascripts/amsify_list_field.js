(function() {
  "use strict";
  App.AmsifyListField = {
    mount: function($input, options) {
      var settings = options || {};
      var amsify = new AmsifySuggestags($input);
      var checkbox_value_attribute = settings.checkboxValueAttribute || "listValue";
      var checkbox_list_value = settings.checkboxListValue || function(value) {
        return value.toString();
      };
      var keep_checkbox_checked = settings.keepCheckboxChecked || function() {
        return false;
      };

      amsify.getItem = function(value) {
        var item_key = this.getItemKey(value);
        return this.settings.suggestions[item_key];
      };

      amsify.getTag = function(value) {
        if (this.getItem(value) !== undefined) {
          return $("<div>" + this.getItem(value).display_text + "</div>").text();
        } else {
          return value;
        }
      };

      amsify.setIcon = function() {
        var remove_tag_text = $input.data("remove-tag-text");
        return '<button aria-label="' + remove_tag_text + '" class="remove-tag ' +
          this.classes.removeTag.substring(1) + '">&#10006;</button>';
      };

      amsify._settings({
        suggestions: settings.suggestions,
        whiteList: settings.whiteList,
        keepLastOnHoverTag: settings.keepLastOnHoverTag !== undefined ?
          settings.keepLastOnHoverTag : false,
        checkSimilar: settings.checkSimilar !== undefined ? settings.checkSimilar : false,
        afterAdd: function(value) {
          if (settings.checkboxes) {
            App.AmsifyListField.checkbox_element(
              settings.checkboxes,
              checkbox_list_value(value),
              checkbox_value_attribute
            ).prop("checked", true);
          }
          if (typeof settings.afterAdd === "function") {
            settings.afterAdd(amsify, value);
          }
        },
        afterRemove: function(value) {
          if (settings.checkboxes) {
            var selected_values = $(amsify.selector).val().split(",");
            App.AmsifyListField.checkbox_element(
              settings.checkboxes,
              checkbox_list_value(value),
              checkbox_value_attribute
            ).prop("checked", keep_checkbox_checked(value, selected_values));
          }
          if (typeof settings.afterRemove === "function") {
            settings.afterRemove(amsify, value);
          }
        }
      });

      if (settings.classes) {
        if (settings.classes.focus) {
          amsify.classes.focus = settings.classes.focus;
        }
        if (settings.classes.sTagsInput) {
          amsify.classes.sTagsInput = settings.classes.sTagsInput;
        }
      }

      amsify._init();
      App.AmsifyListField.fix_label(amsify);

      if (settings.checkboxes) {
        App.AmsifyListField.sync_checkboxes(
          amsify,
          settings.checkboxes,
          checkbox_value_attribute
        );
      }

      return amsify;
    },
    data_attribute_name: function(camel_case) {
      return camel_case.replace(/[A-Z]/g, function(letter) {
        return "-" + letter.toLowerCase();
      });
    },
    checkbox_element: function($checkboxes, token, attribute) {
      var data_attribute = App.AmsifyListField.data_attribute_name(
        attribute || "listValue"
      );

      return $checkboxes.filter("[data-" + data_attribute + "=" + token + "]");
    },
    sync_checkboxes: function(amsify, $checkboxes, attribute) {
      var value_attribute = attribute || "listValue";

      $checkboxes.on("change", function() {
        var token = this.dataset[value_attribute];

        if (amsify.isPresent(token)) {
          amsify.removeTag(token, false);
        } else {
          amsify.addTag(token, false);
        }
      }).on("keydown", function(event) {
        if (event.keyCode === 13) {
          $(this).trigger("click");
          event.preventDefault();
          event.stopPropagation();
        }
      });
    },
    fix_label: function(amsify) {
      var original_input = amsify.selector;
      var suggestions_input = amsify.selectors.sTagsInput;

      suggestions_input[0].id = original_input[0].id + "_suggestions";

      $("[for='" + original_input[0].id + "']").attr("for", suggestions_input[0].id);

      suggestions_input.attr("aria-describedby", original_input.attr("aria-describedby"));

      if ($(original_input).attr("placeholder") === undefined) {
        suggestions_input.removeAttr("placeholder");
      }
    }
  };
}).call(this);
