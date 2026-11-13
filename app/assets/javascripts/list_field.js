(function() {
  "use strict";
  App.ListField = {
    mount: function($input, settings) {
      var input = $input[0];
      var control;

      // Tom Select doesn't trim the values in lists like "1, 1.1"
      input.value = input.value.replace(/\s*,\s*/g, ",");
      control = new TomSelect(input, App.ListField.tom_select_settings($input, settings));

      if (input.hasAttribute("aria-describedby")) {
        control.control_input.setAttribute("aria-describedby", input.getAttribute("aria-describedby"));
      }

      // Tom Select only hides the original input visually, so screen readers
      // would find two fields
      input.setAttribute("aria-hidden", "true");

      App.ListField.sync_checkboxes(control, settings);

      return control;
    },
    tom_select_settings: function($input, settings) {
      var suggestions = $input.data("suggestions-list");
      var suggestions_url = $input.data("suggestions-url");
      var tom_select_settings = {
        // Pressing Enter adds the typed text instead of the first suggestion
        addPrecedence: true,
        // Reusing an existing option avoids duplicates that only differ in case
        // and allows selecting SDGs by typing their code and title
        create: function(text) {
          return App.ListField.find_option(this, text) || (settings.create && { tag: text, value: text });
        },
        createOnBlur: true,
        labelField: "tag",
        // Closing also clears the text; otherwise the dropdown would list every
        // remaining option and pressing Enter would add the first one
        onItemAdd: function() {
          this.close();
        },
        openOnFocus: false,
        plugins: {
          remove_button: {
            html: function(data) {
              return $("<button>", {
                type: "button",
                class: data.className,
                "aria-label": data.title,
                text: data.label
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
          option_create: settings.create ? function(data, escape) {
            // The matching option is already listed. create() still handles
            // blur and the comma.
            if (App.ListField.find_option(this, data.input)) {
              return null;
            }

            return '<div class="create">' + escape(data.input) + "</div>";
          } : null
        },
        // Searching values ranks an exact SDG code first
        searchField: ["value", "tag"]
      };

      if (suggestions) {
        tom_select_settings.options = suggestions;
      }

      if (suggestions_url) {
        tom_select_settings.load = function(query, callback) {
          $.getJSON(suggestions_url, { term: query }).done(function(data) {
            callback(data.suggestions.map(function(name) {
              return { tag: name, value: name };
            }));
          }).fail(function() {
            callback();
          });
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
        if (event.keyCode === 13) {
          $(this).trigger("click");
          event.preventDefault();
          event.stopPropagation();
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
