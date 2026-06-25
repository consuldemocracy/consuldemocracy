(function() {
  "use strict";
  App.Documentable = {
    initialize: function() {
      $(".js-document-attachment").each(function() {
        App.Documentable.initializeDirectUploadInput(this);
      });
      $("#nested-documents").on("cocoon:after-remove", function() {
        App.Documentable.unlockUploads();
      });
      $("#nested-documents").on("cocoon:after-insert", function(e, nested_document) {
        var input, document_fields;
        input = $(nested_document).find(".js-document-attachment");
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
      var lockUpload;

      lockUpload = input.lockUpload;

      App.AttachableFilepond.setupInput({
        input: input,
        attachable: App.Documentable,
        onSuccess: function(uploadData, result, load) {
          var destroyAttachmentLink;

          $(uploadData.cachedAttachmentField).val(result.cached_attachment);
          App.Documentable.setTitleFromFile(uploadData, result.filename);
          App.Documentable.setProgressBar(uploadData, "complete");
          App.Documentable.setFilename(uploadData, result.filename);
          App.Documentable.clearInputErrors(uploadData);
          destroyAttachmentLink = $(result.destroy_link);
          $(uploadData.destroyAttachmentLinkContainer).html(destroyAttachmentLink);
          if (lockUpload) {
            App.Documentable.showNotice();
          }
          load(result.cached_attachment);
        },
        onFailure: function(uploadData, response, message, error) {
          var errors;

          errors = (response && response.errors) || message || "Upload failed";
          $(uploadData.cachedAttachmentField).val("");
          App.Documentable.clearFilename(uploadData);
          App.Documentable.setProgressBar(uploadData, "errors");
          App.Documentable.clearInputErrors(uploadData);
          uploadData.jqXHR = { responseJSON: { errors: errors } };
          App.Documentable.setInputErrors(uploadData);
          $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
          $(uploadData.addAttachmentLabel).addClass("error");
          error(errors);
        }
      });
    },
    buildData: function(data, input) {
      var wrapper;
      wrapper = $(input).closest(".direct-upload");
      data.progressBar = $(wrapper).find(".progress-bar-placeholder");
      data.errorContainer = $(wrapper).find(".attachment-errors");
      data.fileNameContainer = $(wrapper).find("p.file-name");
      data.destroyAttachmentLinkContainer = $(wrapper).find(".action-remove");
      data.addAttachmentLabel = $(wrapper).find(".action-add label");
      data.cachedAttachmentField = $(wrapper).find("input[name$='[cached_attachment]']");
      data.titleField = $(wrapper).find("input[name$='[title]']");
      $(wrapper).find(".progress-bar-placeholder").css("display", "block");
      return data;
    },
    clearFilename: function(data) {
      $(data.fileNameContainer).text("");
    },
    clearInputErrors: function(data) {
      $(data.errorContainer).find("small.error").remove();
    },
    clearProgressBar: function(data) {
      $(data.progressBar).find(".loading-bar").removeClass("complete errors uploading").css("width", "0px");
    },
    setFilename: function(data, file_name) {
      $(data.fileNameContainer).text(file_name);
    },
    setProgressBar: function(data, klass) {
      $(data.progressBar).find(".loading-bar").addClass(klass);
    },
    setTitleFromFile: function(data, title) {
      if ($(data.titleField).val() === "") {
        $(data.titleField).val(title);
      }
    },
    setInputErrors: function(data) {
      var errors;
      errors = "<small class='error'>" + data.jqXHR.responseJSON.errors + "</small>";
      $(data.errorContainer).append(errors);
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
