(function() {
  "use strict";
  App.Polls = {
    generateToken: function() {
      var strings;
      strings = Array.apply(null, {
        length: 6
      }).map(function() {
        return Math.random().toString(36).substr(2); // remove `0.`
      });
      return strings.join("").substring(0, 64);
    },
    replaceToken: function(token) {
      $(".js-question-answer").each(function() {
        var token_param;
        token_param = this.search.slice(-6);
        if (token_param === "token=") {
          this.href = this.href + token;
        }
      });
    },
    initialize: function() {
      var token;
      token = App.Polls.generateToken();
      App.Polls.replaceToken(token);
      $(".zoom-link").on("click", function(event) {
        var answer;
        answer = $(event.target).closest("div.answer");

        if ($(answer).hasClass("medium-6")) {
          $(answer).removeClass("medium-6");
          $(answer).addClass("answer-divider");
          if (!$(answer).hasClass("first")) {
            $(answer).insertBefore($(answer).prev("div.answer"));
          }
        } else {
          $(answer).addClass("medium-6");
          $(answer).removeClass("answer-divider");
          if (!$(answer).hasClass("first")) {
            $(answer).insertAfter($(answer).next("div.answer"));
          }
        }
      });
    }
  };
}).call(this);
