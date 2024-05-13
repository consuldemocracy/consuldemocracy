(function() {
  "use strict";
  App.Options = {
    initializeOptions: function(answers) {
      $(answers).on("cocoon:after-insert", function(e, new_answer) {
        var given_order;
        given_order = App.Options.maxGivenOrder(answers) + 1;
        $(new_answer).find("[name$='[given_order]']").val(given_order);
      });
    },
    maxGivenOrder: function(answers) {
      var max_order;
      max_order = 0;
      $(answers).find("[name$='[given_order]']").each(function(index, answer) {
        var value;
        value = parseFloat($(answer).val());
        max_order = value > max_order ? value : max_order;
      });
      return max_order;
    },
    nestedOptions: function() {
      $(".js-answers").each(function(index, answers) {
        App.Options.initializeOptions(answers);
      });
    },
    initialize: function() {
      App.Options.nestedOptions();
    }
  };
}).call(this);
