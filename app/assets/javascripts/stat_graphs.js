//= require billboard.js/dist/billboard.pkgd
//= require stats

var initialize_stats_modules = function() {
  "use strict";

  App.Stats.initialize();
};

$(document).ready(initialize_stats_modules);
