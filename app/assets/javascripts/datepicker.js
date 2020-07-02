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
    destroy: function() {
      $.datepicker.dpDiv.remove();

      document.querySelectorAll("input.hasDatepicker").forEach(function(input) {
        $(input).datepicker("hide");
        $(input).datepicker("destroy");
      });
    }
  };

  document.addEventListener("turbolinks:before-render", function(event) {
    $.datepicker.dpDiv.appendTo(event.data.newBody);
  });
}).call(this);
