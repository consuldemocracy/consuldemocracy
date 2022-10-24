(function() {
  "use strict";
  App.Managers = {
    generatePassword: function() {
      var chars, possible_chars;
      possible_chars = "aAbcdeEfghiJkmnpqrstuUvwxyz23456789";
      chars = Array.apply(null, {
        length: 12
      }).map(function() {
        var i;
        i = Math.floor(Math.random() * possible_chars.length);
        return possible_chars.charAt(i);
      });
      return chars.join("");
    },
    togglePassword: function(type) {
      $("#user_password").prop("type", type);
    },
    initialize: function() {
      $(".generate-random-value").on("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        $("#user_password").val(App.Managers.generatePassword());
      });
      $(".show-password").on("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        if ($("#user_password").is("input[type='password']")) {
          App.Managers.togglePassword("text");
        } else {
          App.Managers.togglePassword("password");
        }
      });
    }
  };
}).call(this);
