(function() {
  "use strict";
  App.Utils = {
    isNumeric: function(value) {
      return !isNaN(parseFloat(value)) && isFinite(value);
    }
  };
}).call(this);
