(function() {
  "use strict";
  App.AdminSiteCustomizationDocumentsTableActions = {
    initialize: function() {
      $(".admin .site-customization-documents-table-actions .copy-link").on("click", function() {
        var url = $(this).siblings(".download-link").prop("href");

        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(url);
        } else {
          var textarea = document.createElement("textarea");

          textarea.value = url;
          textarea.style.position = "fixed";
          textarea.style.opacity = "0";

          document.body.appendChild(textarea);
          textarea.select();
          document.execCommand("copy");
          document.body.removeChild(textarea);
        }
      });
    }
  };
}).call(this);

