(function() {
  "use strict";
  App.IeAlert = {
    set_cookie_and_hide: function(event) {
      event.preventDefault();
      $.cookie("ie_alert_closed", "true", {
        path: "/",
        expires: 365
      });
      $(".ie-callout").remove();
    },
    initialize: function() {
      $(".ie-callout-close-js").on("click", function(event) {
        App.IeAlert.set_cookie_and_hide(event);
      });
    }
  };
}).call(this);
