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
      var $input, uploadData, dropzone, $zone;

      $input = $(input);

      if ($input.data("documentableDropzone")) {
        return;
      }


      $zone = $input.closest(".document-attachment").find(".js-document-dropzone");
      if ($zone.length === 0) {
        $zone = $("<div>", { class: "js-document-dropzone hidden-dropzone-upload" });
        $input.closest(".document-attachment").append($zone);
      }

      uploadData = {};

      dropzone = new Dropzone($zone[0], {
        url: $input.data("url"),
        paramName: "attachment",
        maxFiles: 1,
        clickable: false,
        autoProcessQueue: true,
        headers: { "X-CSRF-Token": $("meta[name=csrf-token]").attr("content") },
        previewTemplate: "<div></div>"
      });

      $input.on("change.documentable", function() {
        if (this.files.length === 0) {
          return;
        }

        uploadData = App.Documentable.buildData([], input);
        App.Documentable.setFilename(uploadData, this.files[0].name);
        dropzone.removeAllFiles(true);
        dropzone.addFile(this.files[0]);
      });

      dropzone.on("addedfile", function() {
        uploadData = App.Documentable.buildData([], input);
        App.Documentable.clearProgressBar(uploadData);
        App.Documentable.setProgressBar(uploadData, "uploading");
      });

      dropzone.on("uploadprogress", function(_file, progress) {
        $(uploadData.progressBar).find(".loading-bar").css("width", progress + "%");
      });

      dropzone.on("success", function(_file, response) {
        var destroyAttachmentLink;

        $(uploadData.cachedAttachmentField).val(response.cached_attachment);
        App.Documentable.setTitleFromFile(uploadData, response.filename);
        App.Documentable.setProgressBar(uploadData, "complete");
        App.Documentable.setFilename(uploadData, response.filename);
        App.Documentable.clearInputErrors(uploadData);
        destroyAttachmentLink = $(response.destroy_link);
        $(uploadData.destroyAttachmentLinkContainer).html(destroyAttachmentLink);

        if (input.lockUpload) {
          App.Documentable.showNotice();
        }
      });

      dropzone.on("error", function(file, message, xhr) {
        var errors;

        if (xhr && xhr.responseJSON && xhr.responseJSON.errors) {
          errors = xhr.responseJSON.errors;
        } else {
          errors = message;
        }

        uploadData.jqXHR = xhr || { responseJSON: { errors: errors } };
        $(uploadData.cachedAttachmentField).val("");
        App.Documentable.clearFilename(uploadData);
        App.Documentable.setProgressBar(uploadData, "errors");
        App.Documentable.clearInputErrors(uploadData);
        App.Documentable.setInputErrors(uploadData);
        $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
        $(uploadData.addAttachmentLabel).addClass("error");
        dropzone.removeFile(file);
      });

      $input.data("documentableDropzone", dropzone);
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
