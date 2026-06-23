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
        $(".js-image-attachment").closest(".image-fields").remove();
      });
      $("#nested-image").on("cocoon:after-insert", function(e, nested_image) {
        var input;
        $("#new_image_link").addClass("hide");
        input = $(nested_image).find(".js-image-attachment");
        App.Imageable.initializeDirectUploadInput(input);
      });
      App.Imageable.initializeRemoveCachedImageLinks();
      App.Imageable.initializeSuggestImage();
      App.Imageable.initializeAttachSuggestedImage();
    },
    initializeDirectUploadInput: function(input) {
      var $input, uploadData, dropzone, $zone;

      $input = $(input);

      if ($input.data("imageableDropzone")) {
        return;
      }

      $zone = $input.closest(".image-attachment").find(".js-image-dropzone");
      if ($zone.length === 0) {
        $zone = $('<div class="js-image-dropzone" style="position:absolute;width:0;height:0;overflow:hidden"></div>');
        $input.closest(".image-attachment").append($zone);
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

      $input.on("change.imageable", function() {
        if (this.files.length === 0) {
          return;
        }

        uploadData = App.Imageable.buildData([], input);
        App.Imageable.setFilename(uploadData, this.files[0].name);
        dropzone.removeAllFiles(true);
        dropzone.addFile(this.files[0]);
      });

      dropzone.on("addedfile", function() {
        uploadData = App.Imageable.buildData([], input);
        App.Imageable.clearProgressBar(uploadData);
        App.Imageable.setProgressBar(uploadData, "uploading");
      });

      dropzone.on("uploadprogress", function(_file, progress) {
        $(uploadData.progressBar).find(".loading-bar").css("width", progress + "%");
      });

      dropzone.on("success", function(_file, response) {
        var destroyAttachmentLink;

        uploadData.result = response;
        $(uploadData.cachedAttachmentField).val(response.cached_attachment);
        App.Imageable.setTitleFromFile(uploadData, response.filename);
        App.Imageable.setProgressBar(uploadData, "complete");
        App.Imageable.setFilename(uploadData, response.filename);
        App.Imageable.clearInputErrors(uploadData);
        App.Imageable.setPreview(uploadData);
        destroyAttachmentLink = $(response.destroy_link);
        $(uploadData.destroyAttachmentLinkContainer).html(destroyAttachmentLink);
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
        App.Imageable.clearFilename(uploadData);
        App.Imageable.setProgressBar(uploadData, "errors");
        App.Imageable.clearInputErrors(uploadData);
        App.Imageable.setInputErrors(uploadData);
        App.Imageable.clearPreview(uploadData);
        $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
        $(uploadData.addAttachmentLabel).addClass("error");
        dropzone.removeFile(file);
      });

      $input.data("imageableDropzone", dropzone);
    },
    buildData: function(data, input) {
      var wrapper;
      wrapper = $(input).closest(".direct-upload");
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
      image_preview = "<div class='small-12 column text-center image-preview'>" +
        "<figure><img src='" + data.result.attachment_url + "' class='cached-image'></figure></div>";
      if ($(data.preview).length > 0) {
        $(data.preview).replaceWith(image_preview);
      } else {
        $(image_preview).insertBefore($(data.wrapper).find(".attachment-actions"));
        data.preview = $(data.wrapper).find(".image-preview");
      }
    },
    initializeRemoveCachedImageLinks: function() {
      $("#nested-image").on("click", "a.remove-cached-attachment", function(event) {
        event.preventDefault();
        $("#new_image_link").removeClass("hide");
        $(this).closest(".direct-upload").remove();
      });
    },
    imageSuggestionsParams: function(form, resourceType) {
      var params;
      params = form.serializeArray().filter(function(item) {
        return item.name !== "_method";
      });
      params.push({ name: "resource_type", value: resourceType });
      return $.param(params);
    },
    initializeSuggestImage: function() {
      $("body").on("click", ".js-suggest-image", function() {
        var form, dataString, button, wrapper, resourceType;
        button = $(this);
        form = button.closest("form");
        wrapper = button.closest(".suggested-images-wrapper");
        resourceType = wrapper.data("resource-type");

        button.prop("disabled", true);
        button.addClass("is-loading");

        if (typeof CKEDITOR !== "undefined") {
          for (var name in CKEDITOR.instances) {
            CKEDITOR.instances[name].updateElement();
          }
        }

        dataString = App.Imageable.imageSuggestionsParams(form, resourceType);
        var uploadData = App.Imageable.buildData([], button.closest(".image-fields.direct-upload"));
        App.Imageable.clearInputErrors(uploadData);
        $.ajax({
          url: "/image_suggestions",
          type: "POST",
          data: dataString,
          dataType: "script"
        });
      });
    },
    attachSuggestedImageSuccess: function(responseData) {
      var data = App.Imageable.buildData([], this);
      data.result = {
        cached_attachment: responseData.cached_attachment,
        filename: responseData.filename,
        attachment_url: responseData.attachment_url,
        destroy_link: responseData.destroy_link
      };
      $(data.cachedAttachmentField).val(data.result.cached_attachment);
      App.Imageable.setTitleFromFile(data, data.result.filename);
      App.Imageable.setFilename(data, data.result.filename);
      App.Imageable.setPreview(data);
      $(data.destroyAttachmentLinkContainer).html(data.result.destroy_link);
      $("#new_image_link").addClass("hide");
      App.Imageable.clearInputErrors(data);
    },
    attachSuggestedImageError: function(xhr) {
      var data = App.Imageable.buildData([], this);
      data.jqXHR = xhr;
      App.Imageable.clearInputErrors(data);
      App.Imageable.setInputErrors(data);
    },
    initializeAttachSuggestedImage: function() {
      $("body").on("click", ".suggested-image-button", function() {
        var imageId, resourceType, resourceId, dataString, wrapper;
        imageId = $(this).data("image-id");
        wrapper = $(this).closest(".suggested-images-wrapper");
        resourceType = wrapper.data("resource-type");
        resourceId = wrapper.data("resource-id");

        dataString = { resource_type: resourceType };
        if (resourceId) {
          dataString.resource_id = resourceId;
        }
        $.ajax({
          url: "/image_suggestions/" + imageId + "/attach",
          type: "POST",
          data: dataString,
          dataType: "json",
          context: $(this).closest(".image-fields.direct-upload"),
          success: App.Imageable.attachSuggestedImageSuccess,
          error: App.Imageable.attachSuggestedImageError
        });
      });
    },
    removeImage: function(id) {
      $("#" + id).remove();
      $("#new_image_link").removeClass("hide");
    }
  };
}).call(this);
