//= require d3
//= require c3
//= require c3ext
//= require stats

var initialize_stats_modules = function() {
  App.Stats.initialize();
};

$(function(){
  $(document).ready(initialize_stats_modules);
  $(document).on('page:load', initialize_stats_modules);
  $(document).on('ajax:complete', initialize_stats_modules);
});
