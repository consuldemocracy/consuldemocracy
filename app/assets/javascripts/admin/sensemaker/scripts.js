(function() {
  "use strict";
  App.AdminSensemakerScripts = {

    initialize: function() {
      //const forms = $(".admin .sensemaker form");
      //forms.on("submit", this.submitHandler);

      const remoteSubmits = $(".admin .sensemaker form input[type='submit'][data-remote='true']");
      remoteSubmits.on("click", function(event){
        event.preventDefault();
        const form = $(this).closest("form")
        App.AdminSensemakerScripts.remoteSubmit(form, $(this));
      });
    },

    submitHandler: function(event) {
      console.log("Submit handler", event.originalEvent, event.originalEvent.submitter);
      if (event.originalEvent.submitter.dataset.remote === "true") {
        App.AdminSensemakerScripts.remoteSubmit(event);
      }
    },

    remoteSubmit: function(form, submitter) {
      const tempForm = form.clone();
      if (submitter.attr("formaction")) {
        tempForm.attr("action", submitter.attr("formaction"));
      }
      tempForm.attr("data-remote", "true");
      tempForm.appendTo('body');
      console.log("Remote submitting", tempForm, submitter)
      $.rails.fire(tempForm, 'submit');
      tempForm.remove();
    },
  };
}).call(this);
