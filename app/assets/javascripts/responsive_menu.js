(function () {
  "use strict";
  App.ResponsiveMenu = {
    toggleAriaExpanded: function () {
      var div = $("#menu-button");
      div.attr("aria-expanded", !JSON.parse(div.attr("aria-expanded")));
    },
    initialize: function () {
      $("#menu-button").on({
        click: function () {
          App.ResponsiveMenu.toggleAriaExpanded();
        },
      });
    },
  };
}).call(this);
