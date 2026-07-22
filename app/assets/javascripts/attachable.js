(function() {
  "use strict";

  App.Attachable = {
    setupInput: function(config) {
      var $input, $container, uploadData, dropzone, $zone, dropzoneOptions;

      $input = $(config.input);
      $container = $input.closest(config.attachmentContainer);
      $zone = $("<div>", { class: "hidden-dropzone-upload" });
      $container.append($zone);

      uploadData = {};

      dropzoneOptions = {
        url: $input.data("url"),
        paramName: "attachment",
        maxFiles: 1,
        clickable: false,
        headers: { "X-CSRF-Token": $("meta[name=csrf-token]").attr("content") },
        previewTemplate: "<div></div>"
      };

      dropzone = new Dropzone($zone[0], dropzoneOptions);

      $input.on("change", function() {
        uploadData = App.Attachable.buildData(config.input);
        App.Attachable.setFilename(uploadData, this.files[0].name);
        dropzone.addFile(this.files[0]);
      });

      dropzone.on("addedfile", function() {
        uploadData = App.Attachable.buildData(config.input);
        App.Attachable.clearProgressBar(uploadData);
      });

      dropzone.on("uploadprogress", function(_file, progress) {
        uploadData.progressBar.val(progress);
      });

      dropzone.on("success", function(_file, response) {
        var destroyAttachmentLink;

        $(uploadData.cachedAttachmentField).val(response.cached_attachment);
        App.Attachable.setTitleFromFile(uploadData, response.filename);
        App.Attachable.setProgressBar(uploadData, "complete");
        App.Attachable.setFilename(uploadData, response.filename);
        App.Attachable.clearInputErrors(uploadData);
        destroyAttachmentLink = $(response.destroy_link);
        $(uploadData.destroyAttachmentLinkContainer).html(destroyAttachmentLink);

        if (config.onSuccess) {
          config.onSuccess(uploadData, response);
        }
      });

      dropzone.on("error", function(file, message) {
        $(uploadData.cachedAttachmentField).val("");
        App.Attachable.clearFilename(uploadData);
        App.Attachable.setProgressBar(uploadData, "errors");
        App.Attachable.clearInputErrors(uploadData);
        App.Attachable.setInputErrors(uploadData, message.errors);
        $(uploadData.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove();
        $(uploadData.addAttachmentLabel).addClass("error");

        if (config.onError) {
          config.onError(uploadData);
        }

        dropzone.removeFile(file);
      });
    },
    buildData: function(input) {
      var data, wrapper;

      data = [];
      wrapper = $(input).closest(".direct-upload");

      data.wrapper = wrapper;
      data.progressBar = $(wrapper).find("progress");
      data.errorContainer = $(wrapper).find(".action-add");
      data.fileNameContainer = $(wrapper).find("p.file-name");
      data.destroyAttachmentLinkContainer = $(wrapper).find(".action-remove");
      data.addAttachmentLabel = $(wrapper).find(".action-add label");
      data.cachedAttachmentField = $(wrapper).find("input[name$='[cached_attachment]']");
      data.titleField = $(wrapper).find("input[name$='[title]']");

      return data;
    },
    clearFilename: function(data) {
      $(data.fileNameContainer).text("");
    },
    clearInputErrors: function(data) {
      $(data.errorContainer).find("small.error").remove();
    },
    clearProgressBar: function(data) {
      $(data.progressBar).removeClass("complete errors").val("");
    },
    setFilename: function(data, file_name) {
      $(data.fileNameContainer).text(file_name);
    },
    setProgressBar: function(data, klass) {
      data.progressBar.addClass(klass);
    },
    setTitleFromFile: function(data, title) {
      if ($(data.titleField).val() === "") {
        $(data.titleField).val(title);
      }
    },
    setInputErrors: function(data, errors) {
      if (!errors) {
        return;
      }
      $(data.errorContainer).append("<small class='error'>" + errors + "</small>");
    }
  };
}).call(this);
