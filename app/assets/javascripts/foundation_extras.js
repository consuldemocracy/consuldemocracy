(function() {
  "use strict";
  App.FoundationExtras = {
    initialize: function() {
      $(document).foundation();
    },
    destroy: function() {
      if ($(".sticky").length > 0) {
        $(".sticky").foundation("_destroy");
      }
    }
  };

  $(document).on("turbolinks:before-visit", App.FoundationExtras.destroy);
}).call(this);
