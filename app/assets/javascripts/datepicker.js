// Based on code by Javan Makhmali
// https://github.com/turbolinks/turbolinks/issues/253#issuecomment-289101048
// The jQuery UI date picker widget appends a shared element to the
// body which it expects will never leave the page, but Turbolinks
// removes that shared element when it rerenders. We satisfy that
// expectation by removing the shared element from the page before
// Turbolinks caches the page, and appending it again before
// Turbolinks swaps the new body in during rendering.
//
// Additionally, returning to the cached version of a page that
// previously had date picker elements would result in those date
// pickers not being initialized again. We fix this issue by finding
// all initialized date picker inputs on the page and calling the
// date picker's destroy method before Turbolinks caches the page.
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
    destroy: function() {
      $.datepicker.dpDiv.remove();

      document.querySelectorAll("input.hasDatepicker").forEach(function(input) {
        $(input).datepicker("hide");
        $(input).datepicker("destroy");
      });
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

  document.addEventListener("turbolinks:before-render", function(event) {
    $.datepicker.dpDiv.appendTo(event.data.newBody);
  });
}).call(this);
