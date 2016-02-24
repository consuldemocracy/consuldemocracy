// This is a manifest file that'll be compiled into admin.js
// It will be included in the admin layout
// and will require all the files listed below.
//
//= require admin_valuators_forms

var initialize_admin_modules = function() {
  App.AdminValuatorsForms.initialize();
};

$(function(){
  $(document).ready(initialize_admin_modules);
  $(document).on('page:load', initialize_admin_modules);
  $(document).on('ajax:complete', initialize_admin_modules);
});
