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
      App.Attachable.setupInput({
        input: input,
        attachmentContainer: ".image-attachment",
        onSuccess: function(uploadData, response) {
          uploadData.result = response;
          App.Imageable.setPreview(uploadData);
        },
        onError: function(uploadData) {
          App.Imageable.clearPreview(uploadData);
        }
      });
    },
    clearPreview: function(data) {
      $(data.wrapper).find(".image-preview").remove();
    },

    setPreview: function(data) {
      var preview, image_preview;

      image_preview = "<div class='small-12 column text-center image-preview'>" +
        "<figure><img src='" + data.result.attachment_url + "' class='cached-image'></figure></div>";
      preview = data.wrapper.find(".image-preview");

      if ($(preview).length > 0) {
        $(preview).replaceWith(image_preview);
      } else {
        $(image_preview).insertBefore($(data.wrapper).find(".attachment-actions"));
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
        var uploadData = App.Attachable.buildData(button.closest(".image-fields.direct-upload"));
        App.Attachable.clearInputErrors(uploadData);
        $.ajax({
          url: "/image_suggestions",
          type: "POST",
          data: dataString,
          dataType: "script"
        });
      });
    },
    attachSuggestedImageSuccess: function(responseData) {
      var data = App.Attachable.buildData(this);
      data.result = {
        cached_attachment: responseData.cached_attachment,
        filename: responseData.filename,
        attachment_url: responseData.attachment_url,
        destroy_link: responseData.destroy_link
      };
      $(data.cachedAttachmentField).val(data.result.cached_attachment);
      App.Attachable.setTitleFromFile(data, data.result.filename);
      App.Attachable.setFilename(data, data.result.filename);
      App.Imageable.setPreview(data);
      $(data.destroyAttachmentLinkContainer).html(data.result.destroy_link);
      $("#new_image_link").addClass("hide");
      App.Attachable.clearInputErrors(data);
    },
    attachSuggestedImageError: function(xhr) {
      var data = App.Attachable.buildData(this);
      App.Attachable.clearInputErrors(data);
      App.Attachable.setInputErrors(data, xhr.responseJSON && xhr.responseJSON.errors);
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
