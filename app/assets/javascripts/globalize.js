(function() {
  "use strict";
  App.Globalize = {
    selected_language: function() {
      return $("#select_language").val();
    },
    display_locale: function(locale) {
      App.Globalize.enable_locale(locale);
      App.Globalize.add_language(locale);
      $(".js-add-language option:selected").prop("selected", false);
    },
    display_translations: function(locale) {
      $(".js-select-language option[value=" + locale + "]").prop("selected", true);
      $(".js-globalize-attribute").each(function() {
        if ($(this).data("locale") === locale) {
          $(this).show();
        } else {
          $(this).hide();
        }
        $(".js-delete-language").hide();
        $(".js-delete-" + locale).show();
      });
    },
    add_language: function(locale) {
      var language_option, option;
      language_option = $(".js-add-language [value=" + locale + "]");
      if ($(".js-select-language option[value=" + locale + "]").length === 0) {
        option = new Option(language_option.text(), language_option.val());
        $(".js-select-language").append(option);
      }
      $(".js-select-language option[value=" + locale + "]").prop("selected", true);
    },
    remove_language: function(locale) {
      var next;
      $(".js-globalize-attribute[data-locale=" + locale + "]").each(function() {
        $(this).val("").hide();
        App.Globalize.resetEditor(this);
      });
      $(".js-select-language option[value=" + locale + "]").remove();
      next = $(".js-select-language option:not([value=''])").first();
      App.Globalize.display_translations(next.val());
      App.Globalize.disable_locale(locale);
      App.Globalize.update_description();
      if ($(".js-select-language option").length === 1) {
        $(".js-select-language option").prop("selected", true);
      }
    },
    resetEditor: function(element) {
      if (CKEDITOR.instances[$(element).attr("id")]) {
        CKEDITOR.instances[$(element).attr("id")].setData("");
      }
    },
    enable_locale: function(locale) {
      App.Globalize.destroy_locale_field(locale).val(false);
      App.Globalize.site_customization_enable_locale_field(locale).val(1);
    },
    disable_locale: function(locale) {
      App.Globalize.destroy_locale_field(locale).val(true);
      App.Globalize.site_customization_enable_locale_field(locale).val(0);
    },
    enabled_locales: function() {
      return $.map($(".js-select-language:first option:not([value=''])"), function(element) {
        return $(element).val();
      });
    },
    destroy_locale_field: function(locale) {
      return $("input[id$=_destroy][data-locale=" + locale + "]");
    },
    site_customization_enable_locale_field: function(locale) {
      return $("#enabled_translations_" + locale);
    },
    refresh_visible_translations: function() {
      var locale;
      locale = $(".js-select-language").val();
      App.Globalize.display_translations(locale);
    },
    update_description: function() {
      var count;
      count = App.Globalize.enabled_locales().length;
      App.I18n.set_pluralize($(".js-languages-description"), count);
    },
    initialize: function() {
      $(".js-add-language").on("change", function() {
        var locale;
        locale = $(this).val();
        App.Globalize.display_translations(locale);
        App.Globalize.display_locale(locale);
        App.Globalize.update_description();
      });
      $(".js-select-language").on("change", function() {
        App.Globalize.display_translations($(this).val());
      });
      $(".js-delete-language").on("click", function(e) {
        e.preventDefault();
        App.Globalize.remove_language($(this).data("locale"));
        $(this).hide();
      });
      $(".js-add-fields-container").on("cocoon:after-insert", function() {
        App.Globalize.enabled_locales().forEach(function(locale) {
          App.Globalize.enable_locale(locale);
        });
      });
    }
  };
}).call(this);
