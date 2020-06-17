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
      if ($("#" + id).length > 0) {
        return;
      }

      var input = $("<input>").attr({ id: id, type: "hidden", value: $(form).serialize() });
      $(input).insertBefore(form);
    },
    wait_for_html_editors: function(form) {
      var id = App.WatchFormChanges.trackInputId(form);
      // Do not need to serialize if was already done. This is only needed when
      // restoring page from history with a modified but unsaved ckeditor content
      if ($("#" + id).length === 0) {
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.attributeName !== "data-ready-to-serialize") {
              return;
            }
            var textareas = $(form).find(".html-area");
            // Serialize form when all editors are ready to be serialized
            if (textareas.length === textareas.filter("[data-ready-to-serialize=true]").length) {
              App.WatchFormChanges.serialize(form);
            }
          });
        });
        $.each($(form).find(".html-area"), function() {
          observer.observe(this, { attributes: true });
        });
      }

      for (var instanceName in CKEDITOR.instances) {
        // Refresh textarea element when instance is ready and mark it
        // as ready to serialization
        CKEDITOR.instances[instanceName].on("instanceReady", function() {
          this.updateElement();
          this.element.setAttribute("data-ready-to-serialize", "true");
        });
      }
    },
    update_editor_form_elements: function() {
      for (var instanceName in CKEDITOR.instances) {
        CKEDITOR.instances[instanceName].updateElement();
      }
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
