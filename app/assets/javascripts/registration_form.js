(function() {
  "use strict";
  App.RegistrationForm = {
    initialize: function() {
      var clearUsernameMessage, showUsernameMessage, usernameInput, validateUsername;
      usernameInput = $("form#new_user[action=\"/users\"] input#user_username");
      clearUsernameMessage = function() {
        $("small").remove();
      };
      showUsernameMessage = function(response) {
        var klass;
        klass = response.available ? "no-error" : "error";
        usernameInput.after($("<small class=\"" + klass + "\" style=\"margin-top: -16px;\">" + response.message + "</small>"));
      };
      validateUsername = function(username) {
        var request;
        request = $.get("/user/registrations/check_username?username=" + username);
        request.done(function(response) {
          showUsernameMessage(response);
        });
      };
      usernameInput.on("focusout", function() {
        var username;
        clearUsernameMessage();
        username = usernameInput.val();
        if (username !== "") {
          validateUsername(username);
        }
      });
    }
  };
}).call(this);
