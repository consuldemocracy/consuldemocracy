//= require leaflet
//= require map

$(document).on("turbolinks:load", App.Map.initialize);
$(document).on("turbolinks:before-cache", App.Map.destroy);
