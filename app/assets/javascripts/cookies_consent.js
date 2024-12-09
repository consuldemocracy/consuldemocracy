(function() {
  "use strict";
  App.CookiesConsent = {
    hide: function() {
      if ($("#cookies_consent_banner").length > 0) {
        $("#cookies_consent_banner").hide();
      }
      if ($("#cookies_consent_setup").length > 0) {
        $("#cookies_consent_setup").foundation("close");
      }
    },
    showCallout: function() {
      var callout = $("#cookies_consent_banner").data("notice");
      App.Callout.show(new DOMParser().parseFromString(callout, "text/html").documentElement.textContent);
    },
    setCookiesConsent: function(id, value) {
      document.getElementById(id).checked = value;
    },
    vendors: function() {
      return $(".cookies-vendors input[type=checkbox]:not([disabled])");
    },
    initialize: function() {
      $(".accept-all-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "all", 365);
        App.CookiesConsent.vendors().each(function() {
          App.Cookies.saveCookie(this.name, true, 365);
          App.CookiesConsent.setCookiesConsent(this.id, true);
        });
        App.CookiesConsent.showCallout();
        App.CookiesConsent.hide();
      });

      $(".accept-essential-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "essential", 365);
        App.CookiesConsent.vendors().each(function() {
          App.Cookies.saveCookie(this.name, false, 365);
          App.CookiesConsent.setCookiesConsent(this.id, false);
        });
        App.CookiesConsent.showCallout();
        App.CookiesConsent.hide();
      });

      $(".save-cookies-preferences").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "custom", 365);
        App.CookiesConsent.vendors().each(function() {
          App.Cookies.saveCookie(this.name, this.checked, 365);
        });
        App.CookiesConsent.showCallout();
        App.CookiesConsent.hide();
      });
    }
  };
}).call(this);
