(function() {
  "use strict";
  App.FoundationExtras = {
    clearSticky: function() {
      if ($("[data-sticky]").length) {
        $("[data-sticky]").foundation("destroy");
      }
    },
    mobile_ui_init: function() {
      $(window).trigger("load.zf.sticky");
    },
    desktop_ui_init: function() {
      $(window).trigger("init.zf.sticky");
    },
    initialize: function() {
      $(document).foundation();
      $(window).trigger("resize");
      window.addEventListener("popstate", this.clearSticky, false);
      $(function() {
        if ($(window).width() < 620) {
          App.FoundationExtras.mobile_ui_init();
        } else {
          App.FoundationExtras.desktop_ui_init();
        }
      });
    }
  };
}).call(this);
