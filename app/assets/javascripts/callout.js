(function() {
  "use strict";
  App.Callout = {
    show: function(notice) {
      if ($("[data-alert]").length > 0) {
        $("[data-alert]").replaceWith(notice);
      } else {
        $("body").append(notice);
      }
    }
  };
}).call(this);
