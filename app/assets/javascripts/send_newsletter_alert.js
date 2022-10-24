(function() {
  "use strict";
  App.SendNewsletterAlert = {
    initialize: function() {
      $("#js-send-newsletter-alert").on("click", function() {
        return confirm(this.dataset.alert);
      });
    }
  };
}).call(this);
