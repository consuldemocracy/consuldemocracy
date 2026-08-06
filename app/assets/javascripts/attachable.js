(function() {
  "use strict";

  App.Attachable = {
    setupInput: function(config) {
      var $input, $container, $fieldsContainer, dropzone, $progressBar, $zone, dropzoneOptions;

      $input = $(config.input);
      $fieldsContainer = $input.closest(".nested-fields");
      $progressBar = $fieldsContainer.find("progress");
      $container = $input.closest(config.attachmentContainer);
      $zone = $("<div>", { class: "hidden-dropzone-upload" });
      $container.append($zone);

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
        var uploadUrl, title;

        uploadUrl = new URL($input.data("url"), window.location.href);
        title = $fieldsContainer.find("input[name$='[title]']").val() || "";
        uploadUrl.searchParams.set("direct_upload[title]", title);

        dropzone.options.url = uploadUrl;
        dropzone.addFile(this.files[0]);

        $progressBar.removeClass("complete errors");
      });

      dropzone.on("uploadprogress", function(_file, progress) {
        $progressBar.val(progress);
      });

      dropzone.on("success", function(_file, response) {
        App.Attachable.setNewContent($fieldsContainer, response);

        if (config.onSuccess) {
          config.onSuccess($fieldsContainer.find("[type=file]"));
        }

        $fieldsContainer.focus();
      });

      dropzone.on("error", function(file, response) {
        App.Attachable.setNewContent($fieldsContainer, response);
        var new_input = $fieldsContainer.find("[type=file]");

        if (config.onError) {
          config.onError(new_input);
        }

        new_input.focus();
        dropzone.removeFile(file);
      });
    },
    setNewContent: function(fields_container, response) {
      fields_container.html($(response.content).html()).find("progress").val(100);
    }
  };
}).call(this);
