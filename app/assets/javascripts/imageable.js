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
      var inputData;
      inputData = this.buildData([], input);
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
        },
        done: function(e, data) {
          var destroyAttachmentLink;
          $(data.cachedAttachmentField).val(data.result.cached_attachment);
          App.Imageable.setTitleFromFile(data, data.result.filename);
          App.Imageable.setProgressBar(data, "complete");
          App.Imageable.setFilename(data, data.result.filename);
          App.Imageable.clearInputErrors(data);
          App.Imageable.setPreview(data);
          destroyAttachmentLink = $(data.result.destroy_link);
          $(data.destroyAttachmentLinkContainer).html(destroyAttachmentLink);
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
      // we serialize the entire parent form and submit to the image suggestions endpoint
      $("body").on("click", ".js-suggest-image", function() {
        var form, resourceType, dataString, button;
        button = $(this);
        form = button.closest("form");

        // Add spinner and disable button
        button.prop("disabled", true);
        button.prepend('<i class="fa fa-spinner fa-spin" aria-hidden="true"></i> ');

        // Sync CKEditor instances before serializing the form
        if (typeof CKEDITOR !== "undefined") {
          for (var name in CKEDITOR.instances) {
            CKEDITOR.instances[name].updateElement();
          }
        }

        resourceType = button.data("resource-type");
        dataString = App.Imageable.imageSuggestionsParams(form, resourceType);
        var uploadData = App.Imageable.buildData([], $(".direct-upload").first());
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
      // mimic the direct upload behavior to reuse App.Imageable methods
      var data = App.Imageable.buildData([], $(".direct-upload").first());
      data.result = {
        cached_attachment: responseData.cached_attachment,
        filename: responseData.filename,
        attachment_url: responseData.attachment_url,
        destroy_link: responseData.destroy_link
      };
      $(data.cachedAttachmentField).val(data.result.cached_attachment);
      App.Imageable.setTitleFromFile(data, data.result.filename);
      App.Imageable.setProgressBar(data, "complete");
      App.Imageable.setFilename(data, data.result.filename);
      App.Imageable.setPreview(data);
      $(data.destroyAttachmentLinkContainer).html(data.result.destroy_link);
      $("#new_image_link").addClass("hide");
      App.Imageable.clearInputErrors(data);
    },
    attachSuggestedImageError: function(xhr) {
      var data = App.Imageable.buildData([], $(".direct-upload").first());
      data.jqXHR = xhr;
      App.Imageable.setProgressBar(data, "errors");
      App.Imageable.clearInputErrors(data);
      App.Imageable.setInputErrors(data);
    },
    initializeAttachSuggestedImage: function() {
      $("body").on("click", ".js-attach-suggested-image", function(event) {
        var imageId, resourceType, resourceId, dataString, uploadData;
        event.stopPropagation();
        imageId = $(this).data("image-id");
        resourceType = $(this).data("resource-type");
        resourceId = $(this).data("resource-id");
        uploadData = App.Imageable.buildData([], $(".direct-upload").first());
        App.Imageable.clearProgressBar(uploadData);
        $(uploadData.progressBar).find(".loading-bar").css("width", "100%");

        dataString = "resource_type=" + encodeURIComponent(resourceType);
        if (resourceId) {
          dataString += "&resource_id=" + encodeURIComponent(resourceId);
        }
        $.ajax({
          url: "/image_suggestions/" + imageId + "/attach",
          type: "POST",
          data: dataString,
          dataType: "json",
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
