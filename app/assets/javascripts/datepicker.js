(function() {
  "use strict";
  App.Datepicker = {
    initialize: function() {
      var locale;
      locale = document.documentElement.lang;
      $(".js-calendar").datepicker({
        maxDate: "+0d"
      });
      $(".js-calendar-full").datepicker();

      if (!App.Datepicker.browser_supports_datetime_local_field()) {
        if (App.Datepicker.browser_supports_date_field()) {
          $("input[type='datetime-local']").prop("type", "text")
            .val(App.Datepicker.datetime_to_date)
            .prop("type", "date");
        } else {
          $("input[type='datetime-local']").val(App.Datepicker.datetime_to_date).datepicker();
        }
      }

      if (!App.Datepicker.browser_supports_date_field()) {
        $("input[type='date']").datepicker();
      }

      $.datepicker.setDefaults($.datepicker.regional[locale]);
      $.datepicker.setDefaults({ dateFormat: "dd/mm/yy" });
    },
    browser_supports_date_field: function() {
      return App.Datepicker.browser_supports_field_with_type("date");
    },
    browser_supports_datetime_local_field: function() {
      return App.Datepicker.browser_supports_field_with_type("datetime-local");
    },
    browser_supports_field_with_type: function(field_type) {
      var field;

      field = document.createElement("input");
      field.setAttribute("type", field_type);
      return field.type === field_type;
    },
    datetime_to_date: function(index, value) {
      return value.split("T")[0];
    }
  };
}).call(this);
