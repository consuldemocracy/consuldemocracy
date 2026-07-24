(function() {
  "use strict";
  App.Imageable = {
    initialize: function() {
      $("#nested-image [type=file]").each(function() {
        App.Imageable.initializeDirectUploadInput(this);
      });
      $("#nested-image").on("cocoon:after-remove", function() {
        $("#new_image_link").removeClass("hide");
      });
      $("#nested-image").on("cocoon:before-insert", function() {
        $("#nested-image [type=file]").closest(".image-fields").remove();
      });
      $("#nested-image").on("cocoon:after-insert", function(e, nested_image) {
        var input;
        $("#new_image_link").addClass("hide");
        input = $(nested_image).find("[type=file]");
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
        onError: App.Imageable.initializeDirectUploadInput
      });
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
        $.ajax({
          url: "/image_suggestions",
          type: "POST",
          data: dataString,
          dataType: "text",
          success: function(script) {
            $.globalEval(script);
          },
          error: function() {
            button.prop("disabled", false);
            button.removeClass("is-loading");
          }
        });
      });
    },
    attachSuggestedImage: function($fieldsContainer, response, suggestions) {
      App.Attachable.setNewContent($fieldsContainer, response, suggestions);
      $("#new_image_link").addClass("hide");
      App.Imageable.initializeDirectUploadInput($fieldsContainer.find("[type=file]"));
      $fieldsContainer.focus();
    },
    initializeAttachSuggestedImage: function() {
      $("body").on("click", ".suggested-image-button", function() {
        var imageId, resourceType, resourceId, dataString, $fieldsContainer, wrapper;
        imageId = $(this).data("image-id");
        wrapper = $(this).closest(".suggested-images-wrapper");
        resourceType = wrapper.data("resource-type");
        resourceId = wrapper.data("resource-id");
        $fieldsContainer = $(this).closest(".nested-fields");

        dataString = {
          resource_type: resourceType,
          title: $fieldsContainer.find("input[name$='[title]']").val()
        };

        if (resourceId) {
          dataString.resource_id = resourceId;
        }
        $.ajax({
          url: "/image_suggestions/" + imageId + "/attach",
          type: "POST",
          data: dataString,
          dataType: "json",
          success: function(response) {
            App.Imageable.attachSuggestedImage($fieldsContainer, response);
          },
          error: function(xhr) {
            var response = xhr.responseJSON;

            if (response && response.content) {
              var $suggestions = $fieldsContainer.find(".suggested-images-wrapper").detach();

              App.Imageable.attachSuggestedImage($fieldsContainer, response, $suggestions);
            }
          }
        });
      });
    },
    removeImage: function(id) {
      $("#" + id).remove();
      $("#new_image_link").removeClass("hide");
    }
  };
}).call(this);
