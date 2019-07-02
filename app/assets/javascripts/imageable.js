(function() {
  "use strict";
  App.Imageable = {
    initialize: function() {
      $(".js-image-attachment").each(function() {
        App.Imageable.initializeDirectUploadInput(this);
      });
      $("#nested-image").on("cocoon:after-remove", function() {
        $("#new_image_link").removeClass("hide");
      });
      $("#nested-image").on("cocoon:before-insert", function() {
        $(".js-image-attachment").closest(".image").remove();
      });
      $("#nested-image").on("cocoon:after-insert", function(e, nested_image) {
        var input;
        $("#new_image_link").addClass("hide");
        input = $(nested_image).find(".js-image-attachment");
        App.Imageable.initializeDirectUploadInput(input);
      });
    },
    initializeDirectUploadInput: function(input) {
      var inputData;
      inputData = this.buildData([], input);
      this.initializeRemoveCachedImageLink(input, inputData);
      $(input).fileupload({
        paramName: "attachment",
        formData: null,
        add: function(e, data) {
          var upload_data;
          upload_data = App.Imageable.buildData(data, e.target);
          App.Imageable.clearProgressBar(upload_data);
          App.Imageable.setProgressBar(upload_data, "uploading");
          upload_data.submit();
        },
        change: function(e, data) {
          data.files.forEach(function(file) {
            App.Imageable.setFilename(inputData, file.name);
          });
        },
        fail: function(e, data) {
          $(data.cachedAttachmentField).val("");
          App.Imageable.clearFilename(data);
          App.Imageable.setProgressBar(data, "errors");
          App.Imageable.clearInputErrors(data);
          App.Imageable.setInputErrors(data);
          App.Imageable.clearPreview(data);
          $(data.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
          $(data.addAttachmentLabel).addClass("error");
          $(data.addAttachmentLabel).show();
        },
        done: function(e, data) {
          var destroyAttachmentLink;
          $(data.cachedAttachmentField).val(data.result.cached_attachment);
          App.Imageable.setTitleFromFile(data, data.result.filename);
          App.Imageable.setProgressBar(data, "complete");
          App.Imageable.setFilename(data, data.result.filename);
          App.Imageable.clearInputErrors(data);
          $(data.addAttachmentLabel).hide();
          $(data.wrapper).find(".attachment-actions").removeClass("small-12").addClass("small-6 float-right");
          $(data.wrapper).find(".attachment-actions .action-remove").removeClass("small-3").addClass("small-12");
          App.Imageable.setPreview(data);
          destroyAttachmentLink = $(data.result.destroy_link);
          $(data.destroyAttachmentLinkContainer).html(destroyAttachmentLink);
          $(destroyAttachmentLink).on("click", function(e) {
            e.preventDefault();
            e.stopPropagation();
            App.Imageable.doDeleteCachedAttachmentRequest(this.href, data);
          });
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
      data.preview = $(wrapper).find(".image-preview");
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
    clearPreview: function(data) {
      $(data.wrapper).find(".image-preview").remove();
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
    setPreview: function(data) {
      var image_preview;
      image_preview = "<div class='small-12 column text-center image-preview'><figure><img src='" + data.result.attachment_url + "' class='cached-image'></figure></div>";
      if ($(data.preview).length > 0) {
        $(data.preview).replaceWith(image_preview);
      } else {
        $(image_preview).insertBefore($(data.wrapper).find(".attachment-actions"));
        data.preview = $(data.wrapper).find(".image-preview");
      }
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
          App.Imageable.clearFilename(data);
          App.Imageable.clearInputErrors(data);
          App.Imageable.clearProgressBar(data);
          App.Imageable.clearPreview(data);
          $("#new_image_link").removeClass("hide");
          $(data.wrapper).find(".attachment-actions").addClass("small-12").removeClass("small-6 float-right");
          $(data.wrapper).find(".attachment-actions .action-remove").addClass("small-3").removeClass("small-12");
          if ($(data.input).data("nested-image") === true) {
            $(data.wrapper).remove();
          } else {
            $(data.wrapper).find("a.remove-cached-attachment").remove();
          }
        }
      });
    },
    initializeRemoveCachedImageLink: function(input, data) {
      var remove_image_link, wrapper;
      wrapper = $(input).closest(".direct-upload");
      remove_image_link = $(wrapper).find("a.remove-cached-attachment");
      $(remove_image_link).on("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        App.Imageable.doDeleteCachedAttachmentRequest(this.href, data);
      });
    },
    removeImage: function(id) {
      $("#" + id).remove();
      $("#new_image_link").removeClass("hide");
    }
  };

}).call(this);
