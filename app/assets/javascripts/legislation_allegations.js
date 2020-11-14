(function() {
  "use strict";
  App.LegislationAllegations = {
    show_comments: function() {
      if (!App.LegislationAnnotatable.isMobile()) {
        document.querySelector(".draft-allegation details.calc-comments").open = true;
      }
    }
  };
}).call(this);
