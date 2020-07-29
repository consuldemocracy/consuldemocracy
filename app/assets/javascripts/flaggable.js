(function() {
  "use strict";
  App.Flaggable = {
    update: function(resource_id, button) {
      $("#" + resource_id + " .js-flag-actions").first().html(button).foundation();
    }
  };
}).call(this);
