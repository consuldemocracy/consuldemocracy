$(function() {
  "use strict";
  $(document).on("turbolinks:before-render", function() {
    App.HTMLEditor.destroy();
  });
});
