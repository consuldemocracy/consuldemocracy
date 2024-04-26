//= require d3/d3
//= require c3/c3
//= require c3ext
//= require stats

var initialize_stats_modules = function() {
  "use strict";

  App.Stats.initialize();
};

$(document).ready(initialize_stats_modules);
