(function() {
  "use strict";

  // Same rules as ActsAsTaggableOn::DefaultParser
  var parse_tag_list = function(value) {
    var tags = [];
    var quoted_tags = [/(^|,)\s*"(.*?)"\s*(?=,|$)/g, /(^|,)\s*'(.*?)'\s*(?=,|$)/g];
    var unquoted = quoted_tags.reduce(function(string, pattern) {
      return string.replace(pattern, function(match, delimiter, tag) {
        tags.push(tag);
        return "";
      });
    }, value);

    return tags.concat(unquoted.split(",")).map(function(tag) {
      return tag.trim();
    }).filter(Boolean);
  };

  var serialize_tag_list = function(names) {
    return names.map(function(name) {
      return name.indexOf(",") === -1 ? name : "\"" + name + "\"";
    }).join(", ");
  };

  var tag_option = function(name) {
    return { display_text: name, tag: name, value: name };
  };

  var find_option = function(control, text) {
    var needle = text.toLowerCase();
    var value;

    for (value in control.options) {
      if (value.toLowerCase() === needle || control.options[value].tag.toLowerCase() === needle) {
        return control.options[value];
      }
    }
  };

  App.ListField = {
    mount: function($input, settings) {
      var input = $input[0];
      var items = parse_tag_list(input.value);
      var checkboxes = settings.checkboxes;
      var checkbox_attribute = settings.checkboxValueAttribute || "listValue";
      var checkbox_list_value = settings.checkboxListValue || String;
      var keep_checkbox_checked = settings.keepCheckboxChecked || function() {
        return false;
      };
      var control;

      var check = function(value, checked) {
        checkboxes.filter(function() {
          return this.dataset[checkbox_attribute] === checkbox_list_value(value);
        }).prop("checked", checked);
      };

      var after_add = function(value) {
        check(value, true);

        if (settings.afterAdd) {
          settings.afterAdd(control, value);
        }
      };

      if (input.tomselect) {
        return;
      }

      control = new TomSelect(input, {
        clearAfterSelect: true,
        controlInput: "<input type=\"text\" autocomplete=\"off\" size=\"1\" class=\"" +
          settings.inputClass + "\">",
        create: function(text) {
          var option = find_option(this, text);

          if (!option && !settings.whiteList) {
            return tag_option(text);
          }

          if (option) {
            this.addItem(option.value);
          }
          this.setTextboxValue("");
          return false;
        },
        items: items,
        labelField: "display_text",
        load: settings.suggestionsUrl && function(query, callback) {
          $.getJSON(settings.suggestionsUrl, { term: query }).done(function(data) {
            callback(data.suggestions.map(tag_option));
          }).fail(function() {
            callback();
          });
        },
        maxOptions: null,
        onChange: function() {
          input.value = serialize_tag_list(this.items);
        },
        onItemAdd: after_add,
        onItemRemove: function(value) {
          check(value, keep_checkbox_checked(value, this.items));

          if (settings.afterRemove) {
            settings.afterRemove(this, value);
          }
        },
        openOnFocus: false,
        options: settings.suggestions || items.map(tag_option),
        plugins: {
          remove_button: {
            html: function(data) {
              return "<button type=\"button\" class=\"remove\" aria-label=\"" + data.title + "\">" +
                data.label + "</button>";
            },
            title: $input.data("remove-tag-text")
          }
        },
        render: {
          no_results: null,
          option: function(data, escape) {
            return "<div>" + escape(data.tag) + "</div>";
          },
          option_create: null
        },
        searchField: ["tag"],
        shouldLoad: function(query) {
          return query.length >= 2;
        }
      });

      if (input.hasAttribute("aria-describedby")) {
        control.control_input.setAttribute("aria-describedby", input.getAttribute("aria-describedby"));
      }

      // Tom Select only clips this input. The combobox is the control assistive technology should use.
      input.setAttribute("aria-hidden", "true");

      input.value = serialize_tag_list(control.items);
      control.items.forEach(after_add);

      checkboxes.on("change", function() {
        var value = this.dataset[checkbox_attribute];

        if (control.items.indexOf(value) === -1) {
          if (!control.options[value]) {
            control.addOption(tag_option(value));
          }
          control.addItem(value);
        } else {
          control.removeItem(value);
        }
      }).on("keydown", function(event) {
        if (event.keyCode === 13) {
          $(this).trigger("click");
          event.preventDefault();
          event.stopPropagation();
        }
      });
    },
    destroy: function() {
      $("input.tomselected").each(function() {
        var label = document.querySelector("label[for='" + this.tomselect.control_input.id + "']");

        if (label) {
          label.htmlFor = this.id;
        }

        this.removeAttribute("aria-hidden");
        this.tomselect.destroy();
      });
    }
  };
}).call(this);
