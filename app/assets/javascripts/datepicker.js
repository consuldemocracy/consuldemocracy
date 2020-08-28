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
      locale = $("#js-locale").data("current-locale");
      $(".js-calendar").datepicker({
        maxDate: "+0d"
      });
      $(".js-calendar-full").datepicker();

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
      var datefield;

      datefield = document.createElement("input");
      datefield.setAttribute("type", "date");
      return datefield.type === "date";
    }
  };

  document.addEventListener("turbolinks:before-render", function(event) {
    $.datepicker.dpDiv.appendTo(event.data.newBody);
  });
}).call(this);
