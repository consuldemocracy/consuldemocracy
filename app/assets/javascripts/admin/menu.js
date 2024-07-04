(function() {
  "use strict";
  App.AdminMenu = {
    initialize: function() {
      var toggle_buttons = $(".admin-sidebar [aria-expanded]");

      toggle_buttons.removeAttr("disabled");
      toggle_buttons.filter("[aria-expanded='false']").find("+ *").hide();

      toggle_buttons.on("click", function() {
        $(this).attr("aria-expanded", !JSON.parse($(this).attr("aria-expanded")));
        $(this).next().slideToggle();
      });
    }
  };
}).call(this);
