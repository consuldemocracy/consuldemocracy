(function() {
  "use strict";
  App.CookiesConsent = {
    hide: function() {
      $("#cookies_consent_banner").hide();
      $("#cookies_consent_management").foundation("close");
    },
    setCookiesConsent: function(id, value) {
      document.getElementById(id).checked = value;
    },
    vendors: function() {
      return $(".cookies-vendors input[type=checkbox]");
    },
    initialize: function() {
      $(".accept-all-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "all", 365);
        App.CookiesConsent.vendors().each(function() {
          App.Cookies.saveCookie(this.name, true, 365);
          App.CookiesConsent.setCookiesConsent(this.id, true);
        });
        App.CookiesConsent.hide();
      });

      $(".accept-essential-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "essential", 365);
        App.CookiesConsent.vendors().each(function() {
          App.Cookies.saveCookie(this.name, false, 365);
          App.CookiesConsent.setCookiesConsent(this.id, false);
        });
        App.CookiesConsent.hide();
      });

      $(".save-cookies-preferences").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "custom", 365);
        App.CookiesConsent.vendors().each(function() {
          App.Cookies.saveCookie(this.name, this.checked, 365);
        });
        App.CookiesConsent.hide();
      });
    }
  };
}).call(this);
