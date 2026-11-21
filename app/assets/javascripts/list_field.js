(function() {
  "use strict";
  App.ListField = {
    mount: function($input, settings) {
      if (typeof TomSelect === "undefined") {
        return;
      }

      var input = $input[0];
      var control;

      input.value = input.value.replace(/\s*,\s*/g, ",");
      control = new TomSelect(input, App.ListField.tom_select_settings($input, settings));

      if (input.hasAttribute("aria-describedby")) {
        control.control_input.setAttribute("aria-describedby", input.getAttribute("aria-describedby"));
      }

      input.setAttribute("aria-hidden", "true");

      control.control_input.addEventListener("input", function(event) {
        var value;

        if (event.isComposing) {
          return;
        }

        if (event.inputType === "insertFromPaste" || event.inputType === "insertFromDrop") {
          return;
        }

        value = control.inputValue();

        if (event.data !== "," || !value.endsWith(",")) {
          return;
        }

        // Leave the typed text for createItem, as Tom Select does on keypress.
        control.setTextboxValue(value.slice(0, -1));
        control.createItem();
      });

      App.ListField.sync_checkboxes(control, settings);

      return control;
    },
    tom_select_settings: function($input, settings) {
      var suggestions = $input.data("suggestions-list");
      var tom_select_settings = {
        addPrecedence: true,
        create: function(text) {
          return App.ListField.find_option(this, text) || (settings.create && { tag: text, value: text });
        },
        createOnBlur: true,
        labelField: "tag",
        onItemAdd: function() {
          this.close();
        },
        openOnFocus: false,
        plugins: {
          remove_button: {
            html: function(options) {
              return $("<button>", {
                type: "button",
                class: options.className,
                "aria-label": options.title,
                text: options.label
              });
            },
            title: $input.data("remove-tag-text")
          }
        },
        render: {
          item: function(data, escape) {
            return "<div>" + escape(data.display_text || data.tag) + "</div>";
          },
          no_results: null,
          option_create: null
        },
        searchField: ["value", "tag"]
      };

      if (settings.create) {
        tom_select_settings.render.option_create = function(data, escape) {
          if (App.ListField.find_option(this, data.input)) {
            return null;
          }

          return '<div class="create">' + escape(data.input) + "</div>";
        };
      }

      if (Array.isArray(suggestions)) {
        if (typeof suggestions[0] === "string") {
          suggestions = suggestions.map(function(name) {
            return { tag: name, value: name };
          });
        }

        // Add suggestions after setup. Assigning options would replace the
        // ones Tom Select builds from the current value and drop unsaved tags.
        tom_select_settings.onInitialize = function() {
          this.addOptions(suggestions);
        };
      }

      return tom_select_settings;
    },
    find_option: function(control, text) {
      var name = text.toLowerCase();
      var value;

      for (value in control.options) {
        if (value.toLowerCase() === name || control.options[value].tag.toLowerCase() === name) {
          return control.options[value];
        }
      }
    },
    sync_checkboxes: function(control, settings) {
      var value_attribute = settings.checkboxValueAttribute || "listValue";
      var list_value = settings.checkboxListValue || function(value) {
        return value;
      };
      var check_selected = function() {
        var selected = control.items.map(list_value);

        settings.checkboxes.each(function() {
          this.checked = selected.indexOf(this.dataset[value_attribute]) !== -1;
        });
      };

      settings.checkboxes.on("change", function() {
        var value = this.dataset[value_attribute];

        if (control.items.indexOf(value) === -1) {
          control.createItem(value);
        } else {
          control.removeItem(value);
        }
      }).on("keydown", function(event) {
        if (event.key === "Enter") {
          $(this).trigger("click");
          event.preventDefault();
        }
      });

      control.on("change", check_selected);
      check_selected();
    },
    destroy: function() {
      $("input.tomselected").each(function() {
        $("label[for='" + this.tomselect.control_input.id + "']").attr("for", this.id);
        this.removeAttribute("aria-hidden");
        this.tomselect.destroy();
      });
    }
  };
}).call(this);
