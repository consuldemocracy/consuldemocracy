(function() {
  "use strict";
  App.Forms = {
    disableEnter: function() {
      $("form.js-enter-disabled").on("keyup keypress", function(event) {
        if (event.which === 13) {
          event.preventDefault();
        }
      });
    },
    submitOnChange: function() {
      $("body").on("change", ".js-submit-on-change", function() {
        $(this).closest("form").submit();
        return false;
      });
    },
    toggleLink: function() {
      $("body").on("click", ".js-toggle-link", function() {
        var toggle_txt;
        $($(this).data("toggle-selector")).toggle("down");
        if ($(this).data("toggle-text") !== undefined) {
          toggle_txt = $(this).text();
          $(this).text($(this).data("toggle-text"));
          $(this).data("toggle-text", toggle_txt);
        }
        return false;
      });
    },
    synchronizeInputs: function() {
      var banners, inputs, processes, progress_bar;
      progress_bar = "[name='progress_bar[percentage]']";
      processes = "[name='legislation_process[background_color]'], [name='legislation_process[font_color]']";
      banners = "[name='banner[background_color]'], [name='banner[font_color]']";
      inputs = $(progress_bar + ", " + processes + ", " + banners);
      inputs.on({
        input: function() {
          $("[name='" + this.name + "']").val($(this).val());
        }
      });
      inputs.trigger("input");
    },
    hideOrShowFieldsAfterSelection: function() {
      $("[name='progress_bar[kind]']").on({
        change: function() {
          var locale, title_field;
          locale = App.Globalize.selected_language();
          title_field = $(".translatable-fields[data-locale=" + locale + "]");
          if (this.value === "primary") {
            title_field.hide();
            $(".globalize-languages").hide();
          } else {
            title_field.show();
            $(".globalize-languages").show();
          }
        }
      });
      $("[name='progress_bar[kind]']").trigger("change");
    },
    initialize: function() {
      App.Forms.disableEnter();
      App.Forms.submitOnChange();
      App.Forms.toggleLink();
      App.Forms.synchronizeInputs();
      App.Forms.hideOrShowFieldsAfterSelection();
    }
  };
}).call(this);
