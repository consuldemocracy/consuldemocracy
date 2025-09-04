(function() {
  "use strict";
  App.AdminSensemakerScripts = {

    initialize: function() {
      const remoteSubmits = $(".admin .sensemaker form button[type='submit'][data-remote='true'], .admin .sensemaker form input[type='submit'][data-remote='true']");
      remoteSubmits.on("click", function(event){
        event.preventDefault();
        const form = $(this).closest("form")
        App.AdminSensemakerScripts.remoteSubmit(form, $(this));
      });

      const forms = $(".admin .sensemaker form");
      forms.on("submit", this.handleTempDisable);
    },

    handleTempDisable: function(event) {
      const form = $(this);
      const submitButtons = form.find("button[type='submit'][data-temp-disable='true'], input[type='submit'][data-temp-disable='true']");
      submitButtons.attr("disabled", "disabled");
      setTimeout(function() {
        submitButtons.removeAttr("disabled");
      }, 1000);
    },

    remoteSubmit: function(form, submitter) {
      const tempForm = form.clone();
      if (submitter.attr("formaction")) {
        tempForm.attr("action", submitter.attr("formaction"));
      }
      tempForm.attr("data-remote", "true");
      tempForm.appendTo('body');
      $.rails.fire(tempForm, 'submit');
      tempForm.remove();
    },
  };
}).call(this);
