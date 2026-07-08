(function() {
  "use strict";
  App.Documentable = {
    initialize: function() {
      $("#nested-documents [type=file]").each(function() {
        App.Documentable.initializeDirectUploadInput(this);
      });
      $("#nested-documents").on("cocoon:after-remove", function() {
        App.Documentable.unlockUploads();
      });
      $("#nested-documents").on("cocoon:after-insert", function(e, nested_document) {
        var input, document_fields;
        input = $(nested_document).find("[type=file]");
        document_fields = $(nested_document).closest("#nested-documents").find(".document-fields:visible");

        input.lockUpload = document_fields.length >= $("#nested-documents").data("max-documents-allowed");
        App.Documentable.initializeDirectUploadInput(input);
        if (input.lockUpload) {
          App.Documentable.lockUploads();
        }
      });
      App.Documentable.initializeRemoveCachedDocumentLinks();
    },
    initializeDirectUploadInput: function(input) {
      App.Attachable.setupInput({
        input: input,
        attachmentContainer: ".document-attachment",
        onSuccess: function() {
          if (input.lockUpload) {
            App.Documentable.showNotice();
          }
        },
        onError: App.Documentable.initializeDirectUploadInput
      });
    },
    lockUploads: function() {
      $("#new_document_link").addClass("hide");
    },
    unlockUploads: function() {
      $("#max-documents-notice").addClass("hide");
      $("#new_document_link").removeClass("hide");
    },
    showNotice: function() {
      $("#max-documents-notice").removeClass("hide");
    },
    initializeRemoveCachedDocumentLinks: function() {
      $("#nested-documents").on("click", "a.remove-cached-attachment", function(event) {
        event.preventDefault();
        App.Documentable.unlockUploads();
        $(this).closest(".direct-upload").remove();
      });
    },
    removeDocument: function(id) {
      $("#" + id).remove();
    }
  };
}).call(this);
