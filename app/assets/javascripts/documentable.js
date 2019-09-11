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
        var input;
        input = $(nested_document).find(".js-document-attachment");
        input.lockUpload = $(nested_document).closest("#nested-documents").find(".document:visible").length >= $("#nested-documents").data("max-documents-allowed");
        App.Documentable.initializeDirectUploadInput(input);
        if (input.lockUpload) {
          App.Documentable.lockUploads();
        }
      });
    },
    initializeDirectUploadInput: function(input) {
      var inputData;
      inputData = this.buildData([], input);
      this.initializeRemoveCachedDocumentLink(input, inputData);
      $(input).fileupload({
        paramName: "attachment",
        formData: null,
        add: function(e, data) {
          var upload_data;
          upload_data = App.Documentable.buildData(data, e.target);
          App.Documentable.clearProgressBar(upload_data);
          App.Documentable.setProgressBar(upload_data, "uploading");
          upload_data.submit();
        },
        change: function(e, data) {
          data.files.forEach(function(file) {
            App.Documentable.setFilename(inputData, file.name);
          });
        },
        fail: function(e, data) {
          $(data.cachedAttachmentField).val("");
          App.Documentable.clearFilename(data);
          App.Documentable.setProgressBar(data, "errors");
          App.Documentable.clearInputErrors(data);
          App.Documentable.setInputErrors(data);
          $(data.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
          $(data.addAttachmentLabel).addClass("error");
          $(data.addAttachmentLabel).show();
        },
        done: function(e, data) {
          var destroyAttachmentLink;
          $(data.cachedAttachmentField).val(data.result.cached_attachment);
          App.Documentable.setTitleFromFile(data, data.result.filename);
          App.Documentable.setProgressBar(data, "complete");
          App.Documentable.setFilename(data, data.result.filename);
          App.Documentable.clearInputErrors(data);
          $(data.addAttachmentLabel).hide();
          $(data.wrapper).find(".attachment-actions").removeClass("small-12").addClass("small-6 float-right");
          $(data.wrapper).find(".attachment-actions .action-remove").removeClass("small-3").addClass("small-12");
          destroyAttachmentLink = $(data.result.destroy_link);
          $(data.destroyAttachmentLinkContainer).html(destroyAttachmentLink);
          $(destroyAttachmentLink).on("click", function(event) {
            event.preventDefault();
            event.stopPropagation();
            App.Documentable.doDeleteCachedAttachmentRequest(this.href, data);
          });
          if (input.lockUpload) {
            App.Documentable.showNotice();
          }
        },
        progress: function(e, data) {
          var progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          $(data.progressBar).find(".loading-bar").css("width", progress + "%");
        }
      });
    },
    buildData: function(data, input) {
      var wrapper;
      wrapper = $(input).closest(".direct-upload");
      data.input = input;
      data.wrapper = wrapper;
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
      $(data.fileNameContainer).hide();
    },
    clearInputErrors: function(data) {
      $(data.errorContainer).find("small.error").remove();
    },
    clearProgressBar: function(data) {
      $(data.progressBar).find(".loading-bar").removeClass("complete errors uploading").css("width", "0px");
    },
    setFilename: function(data, file_name) {
      $(data.fileNameContainer).text(file_name);
      $(data.fileNameContainer).show();
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
    doDeleteCachedAttachmentRequest: function(url, data) {
      $.ajax({
        type: "POST",
        url: url,
        dataType: "json",
        data: {
          "_method": "delete"
        },
        complete: function() {
          $(data.cachedAttachmentField).val("");
          $(data.addAttachmentLabel).show();
          App.Documentable.clearFilename(data);
          App.Documentable.clearInputErrors(data);
          App.Documentable.clearProgressBar(data);
          App.Documentable.unlockUploads();
          $(data.wrapper).find(".attachment-actions").addClass("small-12").removeClass("small-6 float-right");
          $(data.wrapper).find(".attachment-actions .action-remove").addClass("small-3").removeClass("small-12");
          if ($(data.input).data("nested-document") === true) {
            $(data.wrapper).remove();
          } else {
            $(data.wrapper).find("a.remove-cached-attachment").remove();
          }
        }
      });
    },
    initializeRemoveCachedDocumentLink: function(input, data) {
      var remove_document_link, wrapper;
      wrapper = $(input).closest(".direct-upload");
      remove_document_link = $(wrapper).find("a.remove-cached-attachment");
      $(remove_document_link).on("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        App.Documentable.doDeleteCachedAttachmentRequest(this.href, data);
      });
    },
    removeDocument: function(id) {
      $("#" + id).remove();
    }
  };
}).call(this);
