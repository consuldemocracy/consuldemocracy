(function() {
  "use strict";
  App.Followable = {
    update: function(followable_id, button, notice) {
      $("#" + followable_id + " .js-follow").html(button);
      App.Callout.show(notice);
    }
  };
}).call(this);
