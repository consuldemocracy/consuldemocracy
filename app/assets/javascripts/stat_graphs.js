//= require d3
//= require c3
//= require c3ext
//= require stats

var initialize_stats_modules = function() {
  "use strict";

  App.Stats.initialize();
};

$(document).on("turbolinks:load", initialize_stats_modules);
$(document).on("ajax:complete", initialize_stats_modules);
