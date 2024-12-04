(function() {
  "use strict";
  App.AuthenticityTokenRefresh = {
    initialize: function() {
      $.rails.refreshCSRFTokens();
    }
  };
}).call(this);
