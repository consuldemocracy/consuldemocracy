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
      var uploadData, element, processUpload, hiddenInput, handleUploadSuccess, handleUploadFailure;

      element = input instanceof HTMLElement ? input : input[0];

      if ($(element).data("filepondEngine")) {
        return;
      }

      uploadData = this.buildData([], element);

      handleUploadSuccess = function(result) {
        var destroyAttachmentLink;

        $(uploadData.cachedAttachmentField).val(result.cached_attachment);
        uploadData.result = result;
        App.Imageable.setTitleFromFile(uploadData, result.filename);
        App.Imageable.setProgressBar(uploadData, "complete");
        App.Imageable.setFilename(uploadData, result.filename);
        App.Imageable.clearInputErrors(uploadData);
        App.Imageable.setPreview(uploadData);
        destroyAttachmentLink = $(result.destroy_link);
        $(uploadData.destroyAttachmentLinkContainer).html(destroyAttachmentLink);
      };

      handleUploadFailure = function(response, message) {
        var errors;

        errors = (response && response.errors) || message || "Upload failed";
        $(uploadData.cachedAttachmentField).val("");
        App.Imageable.clearFilename(uploadData);
        App.Imageable.setProgressBar(uploadData, "errors");
        App.Imageable.clearInputErrors(uploadData);
        App.Imageable.clearPreview(uploadData);
        uploadData.jqXHR = { responseJSON: { errors: errors } };
        App.Imageable.setInputErrors(uploadData);
        $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
        $(uploadData.addAttachmentLabel).addClass("error");
      };

      processUpload = function(fieldName, file, metadata, load, error, progress, abort) {
        var request, csrfToken, parseResponse;

        parseResponse = function() {
          try {
            return JSON.parse(request.responseText);
          } catch (e) {
            return null;
          }
        };

        App.Imageable.clearProgressBar(uploadData);
        App.Imageable.setProgressBar(uploadData, "uploading");

        csrfToken = $("meta[name='csrf-token']").attr("content");
        request = new XMLHttpRequest();
        request.open("POST", $(element).data("url"));
        if (csrfToken) {
          request.setRequestHeader("X-CSRF-Token", csrfToken);
        }
        request.setRequestHeader("X-Requested-With", "XMLHttpRequest");

        request.upload.onprogress = function(e) {
          if (e.lengthComputable) {
            progress(e.lengthComputable, e.loaded, e.total);
          }
        };

        request.onload = function() {
          var result, response;

          if (request.status >= 200 && request.status < 300) {
            result = parseResponse();
            if (!result) {
              handleUploadFailure(null, "Upload failed");
              error("Upload failed");
              return;
            }
            handleUploadSuccess(result);
            load(result.cached_attachment);
          } else {
            response = parseResponse();
            handleUploadFailure(response, null);
            error((response && response.errors) || "Upload failed");
          }
        };

        request.onerror = function() {
          handleUploadFailure(null, "Upload failed");
          error("Upload failed");
        };

        request.send(App.Imageable.buildFormData(file));

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

        App.Imageable.setFilename(uploadData, file.name);
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
