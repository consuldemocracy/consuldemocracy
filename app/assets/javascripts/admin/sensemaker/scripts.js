(function() {
  "use strict";
  App.AdminSensemakerScripts = {

    initialize: function() {
      var buttons = ".admin .sensemaker form button[type='submit'][data-remote='true']";
      var inputs = ".admin .sensemaker form input[type='submit'][data-remote='true']";
      var remoteSubmits = $(buttons + ", " + inputs);

      remoteSubmits.on("click", function(event) {
        event.preventDefault();
        var form = $(this).closest("form");
        App.AdminSensemakerScripts.remoteSubmit(form, $(this));
      });

      var forms = $(".admin .sensemaker form");
      forms.on("submit", this.handleTempDisable);
    },

    handleTempDisable: function() {
      var form = $(this);
      var submitButtons = form.find(
        "button[type='submit'][data-temp-disable='true'], input[type='submit'][data-temp-disable='true']"
      );
      submitButtons.attr("disabled", "disabled");
      setTimeout(function() {
        submitButtons.removeAttr("disabled");
      }, 1000);
    },

    remoteSubmit: function(form, submitter) {
      // Serialize the form data
      var formData = form.serialize();
      var formAction = submitter.attr("formaction") || form.attr("action");
      var formMethod = form.attr("method") || "POST";

      // Submit via AJAX
      $.ajax({
        url: formAction,
        type: formMethod,
        data: formData,
        dataType: "script" // This tells Rails to expect JavaScript response
      });
    },
  };
}).call(this);
