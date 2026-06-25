(function() {
  "use strict";
  App.AttachableFilepond = {
    setupInput: function(config) {
      var element, uploadData, attachable, processUpload, hiddenInput;

      element = config.input instanceof HTMLElement ? config.input : config.input[0];
      attachable = config.attachable;

      if ($(element).data("filepondEngine")) {
        return;
      }

      uploadData = attachable.buildData([], element);

      processUpload = function(fieldName, file, metadata, load, error, progress, abort) {
        var request, csrfToken, parseResponse;

        parseResponse = function() {
          try {
            return JSON.parse(request.responseText);
          } catch (e) {
            return null;
          }
        };

        attachable.clearProgressBar(uploadData);
        attachable.setProgressBar(uploadData, "uploading");

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
              config.onFailure(uploadData, null, "Upload failed", error);
              return;
            }
            config.onSuccess(uploadData, result, load);
          } else {
            response = parseResponse();
            config.onFailure(uploadData, response, null, error);
          }
        };

        request.onerror = function() {
          config.onFailure(uploadData, null, "Upload failed", error);
        };

        request.send(App.AttachableFilepond.buildFormData(file));

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

        attachable.setFilename(uploadData, file.name);
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
    }
  };
}).call(this);
