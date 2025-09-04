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
      // Serialize the form data
      const formData = form.serialize();
      const formAction = submitter.attr("formaction") || form.attr("action");
      const formMethod = form.attr("method") || "POST";
      
      // Submit via AJAX
      $.ajax({
        url: formAction,
        type: formMethod,
        data: formData,
        dataType: "script", // This tells Rails to expect JavaScript response
        success: function(response) {
          console.log("Form submitted successfully");
        },
        error: function(xhr, status, error) {
          console.error("Form submission failed:", error);
        }
      });
    },
  };
}).call(this);
