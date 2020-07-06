(function() {
  "use strict";
  App.FoundationExtras = {
    clearSticky: function() {
      if ($("[data-sticky]").length) {
        $("[data-sticky],[data-stick-to]").foundation("destroy");
      }
    },
    initialize: function() {
      // Fix sticky elements restored from browser cache before Foundation initialization
      // Now data-sticky-to property is mandatory to make this patch to work
      if ($("[data-sticky]").length !== $("[data-stick-to]").length) {
        $("[data-stick-to]").attr("data-sticky", "true");
      }

      $("[data-sticky]").each(function(_, sticky) {
        var breakpoints = $(sticky).data("sticky-on") || "small medium large xlarge xxlarge";
        breakpoints = breakpoints.split(" ");
        if (breakpoints.indexOf(Foundation.MediaQuery.current) > -1) {
          return;
        }
        $("[data-sticky]").removeAttr("data-sticky");
      });
      $(document).foundation();
    }
  };

  // Destroy always sticky elements to remove window scroll listener that will fail
  // at all other pages loaded through turbolinks
  $(document).on("turbolinks:before-cache", App.FoundationExtras.clearSticky);
}).call(this);
