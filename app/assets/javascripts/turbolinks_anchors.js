(function() {
  "use strict";

  // Code by Dom Christie:
  // https://github.com/turbolinks/turbolinks/issues/75#issuecomment-443256173
  document.addEventListener("turbolinks:click", function(event) {
    if (event.target.getAttribute("href").charAt(0) === "#") {
      Turbolinks.controller.pushHistoryWithLocationAndRestorationIdentifier(
        event.data.url,
        Turbolinks.uuid()
      );
      event.preventDefault();
    }
  });
}).call(this);
