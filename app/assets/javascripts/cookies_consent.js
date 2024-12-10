(function() {
  "use strict";
  App.CookiesConsent = {
    hide: function() {
      $("#cookies_consent_banner").hide();
    },
    initialize: function() {
      $(".accept-essential-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "essential", 365);
        App.CookiesConsent.hide();
      });
    }
  };
}).call(this);
