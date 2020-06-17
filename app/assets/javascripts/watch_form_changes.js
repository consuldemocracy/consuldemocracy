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
        var id = "#" + App.WatchFormChanges.trackInputId(this);
        return $(this).serialize() !== $(id).val();
      });
    },
    checkChanges: function() {
      if (App.WatchFormChanges.hasChanged()) {
        return confirm(App.WatchFormChanges.msg());
      } else {
        return true;
      }
    },
    trackInputId: function(form) {
      return form.id + "_watch_form_changes";
    },
    serialize: function(form) {
      var id = App.WatchFormChanges.trackInputId(form);
      var input = $("<input>").attr({ id: id, type: "hidden", value: $(form).serialize() });
      $(input).insertBefore(form);
    },
    initialize: function() {
      if (App.WatchFormChanges.forms().length === 0 || App.WatchFormChanges.msg() === undefined) {
        return;
      }

      App.WatchFormChanges.forms().each(function(_, form) {
        // Serialize form directly if there is not ckeditors within form
        if ($(form).find(".html-area").length === 0) {
          App.WatchFormChanges.serialize(form);
          return;
        }

        App.WatchFormChanges.wait_for_html_editors(form);
      });
    }
  };

  $(document).on("turbolinks:before-visit", App.WatchFormChanges.checkChanges);
}).call(this);
