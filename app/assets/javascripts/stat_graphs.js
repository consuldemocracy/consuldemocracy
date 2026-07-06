//= require d3/d3
//= require c3/c3
//= require stats

var initialize_stats_modules = function() {
  "use strict";

  App.Stats.initialize();
};

$(document).on("turbolinks:load", initialize_stats_modules);
$(document).on("ajax:complete", initialize_stats_modules);
