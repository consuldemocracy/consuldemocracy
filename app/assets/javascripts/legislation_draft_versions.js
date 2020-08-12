(function() {
  "use strict";
  App.LegislationDraftVersions = {
    msg: function() {
      return $("[data-markdown-changes-message]").data("markdown-changes-message");
    },
    hasChanged: function() {
      return $(".markdown-editor textarea").is(function() {
        return this.value !== this.defaultValue;
      });
    },
    checkChanges: function() {
      if (App.LegislationDraftVersions.hasChanged()) {
        return confirm(App.LegislationDraftVersions.msg());
      } else {
        return true;
      }
    },
  };

  $(document).on("turbolinks:before-visit", App.LegislationDraftVersions.checkChanges);
}).call(this);
