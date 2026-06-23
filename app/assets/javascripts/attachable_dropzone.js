(function() {
  "use strict";
  App.AttachableDropzone = {
    setupInput: function(config) {
      var $input, uploadData, dropzone, $zone, attachable;

      $input = $(config.input);
      attachable = config.attachable;

      if ($input.data(config.dropzoneDataKey)) {
        return;
      }

      $zone = $input.closest(config.attachmentContainer).find("." + config.dropzoneClass);
      if ($zone.length === 0) {
        $zone = $('<div class="' + config.dropzoneClass + '" style="position:absolute;width:0;height:0;overflow:hidden"></div>');
        $input.closest(config.attachmentContainer).append($zone);
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

      $input.on("change." + config.changeNamespace, function() {
        if (this.files.length === 0) {
          return;
        }

        uploadData = attachable.buildData([], config.input);
        attachable.setFilename(uploadData, this.files[0].name);
        dropzone.removeAllFiles(true);
        dropzone.addFile(this.files[0]);
      });

      dropzone.on("addedfile", function() {
        uploadData = attachable.buildData([], config.input);
        attachable.clearProgressBar(uploadData);
        attachable.setProgressBar(uploadData, "uploading");
      });

      dropzone.on("uploadprogress", function(_file, progress) {
        $(uploadData.progressBar).find(".loading-bar").css("width", progress + "%");
      });

      dropzone.on("success", function(_file, response) {
        var destroyAttachmentLink;

        $(uploadData.cachedAttachmentField).val(response.cached_attachment);
        attachable.setTitleFromFile(uploadData, response.filename);
        attachable.setProgressBar(uploadData, "complete");
        attachable.setFilename(uploadData, response.filename);
        attachable.clearInputErrors(uploadData);
        destroyAttachmentLink = $(response.destroy_link);
        $(uploadData.destroyAttachmentLinkContainer).html(destroyAttachmentLink);

        if (config.onSuccess) {
          config.onSuccess(uploadData, response);
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
        if (!uploadData.jqXHR.responseJSON) {
          uploadData.jqXHR.responseJSON = { errors: errors };
        } else if (!uploadData.jqXHR.responseJSON.errors) {
          uploadData.jqXHR.responseJSON.errors = errors;
        }
        $(uploadData.cachedAttachmentField).val("");
        attachable.clearFilename(uploadData);
        attachable.setProgressBar(uploadData, "errors");
        attachable.clearInputErrors(uploadData);
        attachable.setInputErrors(uploadData);
        $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
        $(uploadData.addAttachmentLabel).addClass("error");

        if (config.onError) {
          config.onError(uploadData);
        }

        dropzone.removeFile(file);
      });

      $input.data(config.dropzoneDataKey, dropzone);
    }
  };
}).call(this);
