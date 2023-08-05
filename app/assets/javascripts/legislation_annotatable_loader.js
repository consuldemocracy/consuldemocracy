//= require annotator
//= require legislation_annotatable

var initialize_modules = function() {
  "use strict";

  if ($(".legislation-annotatable").length) {
    App.LegislationAnnotatable.initialize();
  }
};

$(document).on("turbolinks:load", initialize_modules);
$(document).on("turbolinks:before-cache", App.LegislationAnnotatable.destroy);
