//= require annotator
//= require legislation_annotatable

var initialize_modules = function() {
  "use strict";

  if ($(".legislation-annotatable").length) {
    App.LegislationAnnotatable.initialize();
  }
};

$(document).ready(initialize_modules);
