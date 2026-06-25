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
      var uploadData, element, lockUpload, processUpload, hiddenInput;

      element = input instanceof HTMLElement ? input : input[0];
      lockUpload = input.lockUpload;

      if ($(element).data("filepondEngine")) {
        return;
      }

      uploadData = this.buildData([], element);

      processUpload = function(fieldName, file, metadata, load, error, progress, abort) {
        var request, csrfToken;

        App.Documentable.clearProgressBar(uploadData);
        App.Documentable.setProgressBar(uploadData, "uploading");

        csrfToken = $("meta[name='csrf-token']").attr("content");
        request = new XMLHttpRequest();
        request.open("POST", $(element).data("url"));
        request.setRequestHeader("X-CSRF-Token", csrfToken);
        request.setRequestHeader("X-Requested-With", "XMLHttpRequest");

        request.upload.onprogress = function(e) {
          if (e.lengthComputable) {
            progress(e.lengthComputable, e.loaded, e.total);
          }
        };

        request.onload = function() {
          var result, destroyAttachmentLink, response;

          if (request.status >= 200 && request.status < 300) {
            result = JSON.parse(request.responseText);
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
          } else {
            response = JSON.parse(request.responseText);
            $(uploadData.cachedAttachmentField).val("");
            App.Documentable.clearFilename(uploadData);
            App.Documentable.setProgressBar(uploadData, "errors");
            App.Documentable.clearInputErrors(uploadData);
            uploadData.jqXHR = { responseJSON: response };
            App.Documentable.setInputErrors(uploadData);
            $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
            $(uploadData.addAttachmentLabel).addClass("error");
            error(response.errors);
          }
        };

        request.onerror = function() {
          error("Upload failed");
        };

        request.send(App.Documentable.buildFormData(file));

        return {
          abort: function() {
            request.abort();
            abort();
          }
        };
      };

      hiddenInput = document.createElement("input");
      hiddenInput.type = "file";
      hiddenInput.style.cssText = "position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;";
      hiddenInput.setAttribute("aria-hidden", "true");
      $(element).closest(".direct-upload").append(hiddenInput);

      FilePond.create(hiddenInput, {
        credits: false,
        allowMultiple: false,
        allowRevert: false,
        allowRemove: false,
        allowBrowse: false,
        allowDrop: false,
        allowPaste: false,
        instantUpload: true,
        labelIdle: "",
        name: "attachment",
        server: {
          process: processUpload
        }
      });

      $(element).on("change", function() {
        var file;

        file = element.files[0];
        if (!file) {
          return;
        }

        App.Documentable.setFilename(uploadData, file.name);
        processUpload("attachment", file, {}, function() {}, function() {}, function(computable, loaded, total) {
          var percent;

          if (computable) {
            percent = parseInt(loaded / total * 100, 10);
            $(uploadData.progressBar).find(".loading-bar").css("width", percent + "%");
          }
        }, function() {});
      });

      $(element).data("filepondEngine", true);
    },
    buildFormData: function(file) {
      var formData;
      formData = new FormData();
      formData.append("attachment", file);
      return formData;
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
