(function() {
  "use strict";
  App.LegislationAllegations = {
    toggle_comments: function() {
      if (!App.LegislationAnnotatable.isMobile()) {
        $(".draft-allegation").toggleClass("comments-on");
        $("#comments-box").html("").hide();
      }
    },
    show_comments: function() {
      if (!App.LegislationAnnotatable.isMobile()) {
        $(".draft-allegation").addClass("comments-on");
      }
    },
    initialize: function() {
      $(".js-toggle-allegations .draft-panel").on({
        click: function(e) {
          e.preventDefault();
          e.stopPropagation();
          if (!App.LegislationAnnotatable.isMobile()) {
            App.LegislationAllegations.toggle_comments();
          }
        }
      });
      $(".js-toggle-allegations").on({
        click: function() {
          if (!App.LegislationAnnotatable.isMobile()) {
            if ($(this).find(".draft-panel .panel-title:visible").length === 0) {
              App.LegislationAllegations.toggle_comments();
            }
          }
        }
      });
    }
  };

}).call(this);
