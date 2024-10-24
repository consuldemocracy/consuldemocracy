(function() {
  "use strict";
  App.Questions = {
    nestedQuestions: function() {
      $(".js-questions").on("cocoon:after-insert", function(e, new_question) {
        App.Options.initializeOptions($(new_question).find(".js-options"));
      });
    },
    initialize: function() {
      App.Questions.nestedQuestions();
    }
  };
}).call(this);
