(function() {
  "use strict";
  App.FixedBar = {
    initialize: function() {
      $("[data-fixed-bar]").each(function() {
        var $this, fixedBarTopPosition;
        $this = $(this);
        fixedBarTopPosition = $this.offset().top;
        $(window).on("scroll", function() {
          if ($(window).scrollTop() > fixedBarTopPosition) {
            $this.addClass("is-fixed");
            $("#check-ballot").css({ "display": "inline-block" });
          } else {
            $this.removeClass("is-fixed");
            $("#check-ballot").hide();
          }
        });
      });
    }
  };
}).call(this);
