//= require ckeditor/loader
//= require_directory ./ckeditor
//= require html_editor

$(document).on("turbolinks:load", App.HTMLEditor.initialize);
$(document).on("turbolinks:before-cache", App.HTMLEditor.destroy);
