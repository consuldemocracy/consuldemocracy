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
      if ($(".subfooter a[data-open=cookies_consent_setup]").length > 0) {
        App.CookiesConsent.showCallout();
      }
    },
    showCallout: function() {
      var callout = $("#cookies_consent_setup").data("notice");
      App.Callout.show(new DOMParser().parseFromString(callout, "text/html").documentElement.textContent);
    },
    initialize: function() {
      $(".accept-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "all", 365);
        App.CookiesConsent.hide();
      });

      $(".reject-cookies").on("click", function() {
        App.Cookies.saveCookie("cookies_consent", "essential", 365);
        App.CookiesConsent.hide();
      });
    }
  };
}).call(this);
