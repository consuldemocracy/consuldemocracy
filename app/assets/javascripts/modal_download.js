(function() {
  "use strict";
  App.ModalDownload = {
    enableButton: function() {
      $("#js-download-modal-submit").attr("disabled", false);
      $("#js-download-modal-submit").removeClass("disabled");
    },
    initialize: function() {
      $("#js-download-modal-submit").on("click", function() {
        setTimeout(App.ModalDownload.enableButton, 2000);
      });
    }
  };
}).call(this);
