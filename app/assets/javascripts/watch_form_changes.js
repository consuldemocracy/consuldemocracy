(function() {
  "use strict";
  App.WatchFormChanges = {
    forms: function() {
      return $("form[data-watch-changes]");
    },
    msg: function() {
      return $("[data-watch-form-message]").data("watch-form-message");
    },
    hasChanged: function() {
      return App.WatchFormChanges.forms().is(function() {
        return $(this).serialize() !== $(this).data("watchChanges");
      });
    },
    checkChanges: function() {
      if (App.WatchFormChanges.hasChanged()) {
        return confirm(App.WatchFormChanges.msg());
      } else {
        return true;
      }
    },
    initialize: function() {
      if (App.WatchFormChanges.forms().length === 0 || App.WatchFormChanges.msg() === undefined) {
        return;
      }
      $(document).off("turbolinks:before-visit").on("turbolinks:before-visit", App.WatchFormChanges.checkChanges);
      App.WatchFormChanges.forms().each(function() {
        $(this).data("watchChanges", $(this).serialize());
      });
    }
  };
}).call(this);
