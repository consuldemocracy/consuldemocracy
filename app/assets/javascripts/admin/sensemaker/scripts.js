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

      var busySelector =
        "button[type='submit'][data-temp-disable='true'], input[type='submit'][data-temp-disable='true']";
      forms.on("click", busySelector, this.applyBusyState);
    },

    handleTempDisable: function() {
      App.AdminSensemakerScripts.applyBusyState.call(this, { currentTarget: this });
    },

    applyBusyState: function(event) {
      var form = $(event.currentTarget).closest("form");
      form.addClass("sensemaker-buttons-busy");
    },

    remoteSubmit: function(form, submitter) {
      var formData = form.serialize();
      var formAction = submitter.attr("formaction") || form.attr("action");
      var formMethod = form.attr("method") || "POST";

      $.ajax({
        url: formAction,
        type: formMethod,
        data: formData,
        dataType: "script" // This tells Rails to expect JavaScript response
      });
    },
  };
}).call(this);
