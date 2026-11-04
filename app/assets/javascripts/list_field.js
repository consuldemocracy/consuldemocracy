(function() {
  "use strict";

  // Quotes wrap a name only when they enclose the whole name, as in ActsAsTaggableOn.
  var parse_tag_list = function(value) {
    var string = String(value || "");
    var tags = [];
    var current = "";
    var quote = "";
    var i;
    var character;

    var push_current = function() {
      var tag = current.replace(/^\s+|\s+$/g, "");

      if (tag) {
        tags.push(tag);
      }

      current = "";
    };

    for (i = 0; i < string.length; i++) {
      character = string.charAt(i);

      if (quote) {
        if (character === quote) {
          quote = "";
        } else {
          current += character;
        }
      } else if ((character === "\"" || character === "'") && current.trim() === "") {
        quote = character;
        current = "";
      } else if (character === ",") {
        push_current();
      } else {
        current += character;
      }
    }

    push_current();

    return tags;
  };

  var serialize_tag_list = function(names) {
    return names.map(function(name) {
      var label = String(name);

      return label.indexOf(",") === -1 ? label : "\"" + label + "\"";
    }).join(", ");
  };

  var option_for = function(item) {
    var value;
    var text;

    if (item !== null && typeof item === "object") {
      value = String(item.value);
      text = String(item.display_text || item.tag || value);

      return {
        tag: String(item.tag || text),
        text: text,
        title: item.title || "",
        value: value
      };
    }

    value = String(item);

    return { tag: value, text: value, value: value };
  };

  var matching_option = function(control, label) {
    var needle = label.toLowerCase();
    var key;
    var option;

    if (!needle) {
      return null;
    }

    for (key in control.options) {
      if (Object.prototype.hasOwnProperty.call(control.options, key)) {
        option = control.options[key];
        if (String(option.tag || option.value).toLowerCase() === needle ||
            String(option.value).toLowerCase() === needle) {
          return option;
        }
      }
    }

    return null;
  };

  var sync_value = function(control) {
    control.input.value = serialize_tag_list(control.items);
  };

  var restore_label = function(input, control) {
    var label;

    if (!control.focus_node || !control.focus_node.id || !input.id) {
      return;
    }

    label = document.querySelector("label[for='" + control.focus_node.id + "']");
    if (label) {
      label.setAttribute("for", input.id);
    }
  };

  var checkbox_for = function($checkboxes, attribute, token) {
    return $checkboxes.filter(function() {
      return this.dataset[attribute] === String(token);
    });
  };

  App.ListField = {
    mount: function($input, options) {
      var settings = options || {};
      var input = $input[0];
      var selected = input ? parse_tag_list(input.value) : [];
      var source = settings.suggestions || [];
      var known = {};
      var choices = [];
      var checkboxes = settings.checkboxes;
      var checkbox_attribute = settings.checkboxValueAttribute || "listValue";
      var checkbox_value = settings.checkboxListValue || function(value) {
        return String(value);
      };
      var keep_checked = settings.keepCheckboxChecked || function() {
        return false;
      };
      var i;
      var choice;
      var on_add;
      var on_remove;
      var config;
      var control;

      if (!input || input.tomselect) {
        return;
      }

      for (i = 0; i < source.length; i++) {
        choice = option_for(source[i]);
        known[choice.value] = true;
        choices.push(choice);
      }

      for (i = 0; i < selected.length; i++) {
        if (!known[selected[i]]) {
          choices.push(option_for(selected[i]));
        }
      }

      on_add = function(select, value) {
        if (checkboxes && checkboxes.length) {
          checkbox_for(checkboxes, checkbox_attribute, checkbox_value(value)).prop("checked", true);
        }

        if (typeof settings.afterAdd === "function") {
          settings.afterAdd(select, value);
        }
      };

      on_remove = function(select, value) {
        var checked = keep_checked(value, select.items);

        if (checkboxes && checkboxes.length) {
          checkbox_for(checkboxes, checkbox_attribute, checkbox_value(value)).prop("checked", checked);
        }

        if (typeof settings.afterRemove === "function") {
          settings.afterRemove(select, value);
        }
      };

      config = {
        clearAfterSelect: true,
        controlInput: "<input type=\"text\" autocomplete=\"off\" size=\"1\" class=\"" +
          settings.inputClass + "\">",
        create: function(typed) {
          var name = typed.trim();
          var match = matching_option(this, name);

          if (match) {
            this.setTextboxValue("");
            this.addItem(match.value);
            return false;
          }

          if (name && !settings.whiteList) {
            return option_for(name);
          }

          this.setTextboxValue("");
          return false;
        },
        items: selected,
        maxOptions: settings.suggestions ? null : 50,
        onChange: function() {
          sync_value(this);
        },
        onInitialize: function() {
          var index;

          sync_value(this);

          for (index = 0; index < this.items.length; index++) {
            on_add(this, this.items[index]);
          }
        },
        onItemAdd: function(value) {
          on_add(this, value);
        },
        onItemRemove: function(value) {
          on_remove(this, value);
        },
        openOnFocus: false,
        options: choices,
        plugins: {
          remove_button: {
            className: "remove",
            html: function(data) {
              var button = document.createElement("button");

              button.type = "button";
              button.className = data.className;
              button.title = data.title;
              button.setAttribute("aria-label", data.title);
              button.textContent = data.label;

              return button;
            },
            label: "\u00d7",
            title: $input.data("remove-tag-text") || "Remove"
          }
        },
        render: {
          no_results: function() {
            return null;
          },
          option: function(data, escape) {
            return "<div>" + escape(data.tag || data.text) + "</div>";
          },
          option_create: function(data, escape) {
            if (settings.whiteList) {
              return null;
            }

            return "<div>" + escape(data.input) + "</div>";
          }
        },
        searchField: ["text", "tag", "value"]
      };

      if (settings.suggestionsUrl) {
        config.load = function(query, callback) {
          $.getJSON(settings.suggestionsUrl, { term: query }).done(function(data) {
            var names = (data && data.suggestions) || [];

            callback(names.map(option_for));
          }).fail(function() {
            callback();
          });
        };
        config.shouldLoad = function(query) {
          return query.length >= 2;
        };
      }

      control = new TomSelect(input, config);

      if (input.getAttribute("aria-describedby")) {
        control.control_input.setAttribute("aria-describedby", input.getAttribute("aria-describedby"));
      }

      if (!checkboxes || !checkboxes.length) {
        return;
      }

      checkboxes.on("change", function() {
        var token = this.dataset[checkbox_attribute];

        if (!token) {
          return;
        }

        if (control.items.indexOf(token) === -1) {
          if (!control.options[token] && !settings.whiteList) {
            control.addOption(option_for(token));
          }
          control.addItem(token);
        } else {
          control.removeItem(token);
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
        var control = this.tomselect;

        if (!control) {
          return;
        }

        sync_value(control);
        restore_label(this, control);
        control.destroy();
      });
    }
  };
}).call(this);
