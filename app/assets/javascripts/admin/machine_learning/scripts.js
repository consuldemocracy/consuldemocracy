(function() {
  "use strict";
  App.AdminMachineLearningScripts = {
    initialize: function() {
      $(".admin .machine-learning-scripts select").on({
        change: function() {
          var element = document.getElementById($(this).val());

          $("#script_descriptions > *").not(element).addClass("hide");
          $(element).removeClass("hide");
        }
      }).trigger("change");
    }
  };
}).call(this);
