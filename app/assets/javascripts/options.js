(function() {
  "use strict";
  App.Options = {
    initializeOptions: function(options) {
      $(options).on("cocoon:after-insert", function(e, new_option) {
        var given_order;
        given_order = App.Options.maxGivenOrder(options) + 1;
        $(new_option).find("[name$='[given_order]']").val(given_order);
      });
    },
    maxGivenOrder: function(options) {
      var max_order;
      max_order = 0;
      $(options).find("[name$='[given_order]']").each(function(index, option) {
        var value;
        value = parseFloat($(option).val());
        max_order = value > max_order ? value : max_order;
      });
      return max_order;
    },
    nestedOptions: function() {
      $(".js-options").each(function(index, options) {
        App.Options.initializeOptions(options);
      });
    },
    initialize: function() {
      App.Options.nestedOptions();
    }
  };
}).call(this);
