(function() {
  "use strict";
  App.ManagementPrint = {
    initialize: function() {
      $("#print_button").on("click", function() {
        window.print();
      });
    }
  };
}).call(this);
