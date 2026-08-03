(function() {
  "use strict";
  App.SpeechToText = {
    MAX_RECORDING_MS: 60000,
    TIMESLICE_MS: 1000,
    PARTIAL_INTERVAL_MS: 4000,
    toggle: function(editor) {
      var state;
      state = App.SpeechToText.stateFor(editor);
      if (state === "recording") {
        App.SpeechToText.stopRecording(editor);
      } else if (state === "idle") {
        App.SpeechToText.startRecording(editor);
      }
    },
    stateFor: function(editor) {
      return App.SpeechToText.editorData(editor).state;
    },
    editorData: function(editor) {
      var data;
      data = $(editor.element.$).data("speechToText");
      if (!data) {
        data = { state: "idle" };
        $(editor.element.$).data("speechToText", data);
      }
      return data;
    },
    configFor: function(editor) {
      var element;
      element = editor.element;
      return {
        endpoint: element.getAttribute("data-speech-to-text-endpoint"),
        locale: element.getAttribute("data-speech-to-text-locale"),
        labelIdle: element.getAttribute("data-speech-to-text-label-idle"),
        labelRecording: element.getAttribute("data-speech-to-text-label-recording"),
        labelLoading: element.getAttribute("data-speech-to-text-label-loading"),
        errorMicrophoneBlocked: element.getAttribute("data-speech-to-text-error-microphone-blocked"),
        errorUnsupportedBrowser: element.getAttribute("data-speech-to-text-error-unsupported-browser"),
        errorTranscriptionFailed: element.getAttribute("data-speech-to-text-error-transcription-failed")
      };
    },
    errorElementFor: function(editor) {
      return $(editor.container.$).siblings(".js-speech-to-text-error").first();
    },
    updateEditorState: function(editor, state) {
      var command, data;
      data = App.SpeechToText.editorData(editor);
      data.state = state;
      command = editor.getCommand("speechToText");

      if (state === "recording") {
        command.setState(CKEDITOR.TRISTATE_ON);
        editor.container.addClass("speech-to-text-recording");
      } else if (state === "loading") {
        command.setState(CKEDITOR.TRISTATE_DISABLED);
        editor.container.removeClass("speech-to-text-recording");
      } else {
        command.setState(CKEDITOR.TRISTATE_OFF);
        editor.container.removeClass("speech-to-text-recording");
      }

      App.SpeechToText.updateButtonLabel(editor, state);
    },
    setupToolbarButton: function(editor) {
      var anchor, config, error, label, toolbar;
      anchor = editor.container.findOne(".cke_button__speechtotext");
      if (!anchor) {
        return;
      }
      toolbar = anchor.getAscendant(function(element) {
        return element.hasClass("cke_toolbar");
      });
      if (toolbar) {
        toolbar.addClass("cke_toolbar_speech");
      }
      label = anchor.findOne(".cke_button_label");
      if (!label) {
        return;
      }
      config = App.SpeechToText.configFor(editor);
      label.setText(config.labelIdle);

      if (App.SpeechToText.errorElementFor(editor).length === 0) {
        error = new CKEDITOR.dom.element("small");
        error.addClass("speech-to-text-error");
        error.addClass("error");
        error.addClass("hide");
        error.addClass("js-speech-to-text-error");
        error.insertAfter(editor.container);
      }
    },
    updateButtonLabel: function(editor, state) {
      var anchor, config, label, text;
      anchor = editor.container.findOne(".cke_button__speechtotext");
      if (!anchor) {
        return;
      }
      label = anchor.findOne(".cke_button_label");
      if (!label) {
        return;
      }
      config = App.SpeechToText.configFor(editor);
      if (state === "recording") {
        text = config.labelRecording;
      } else if (state === "loading") {
        text = config.labelLoading;
      } else {
        text = config.labelIdle;
      }
      label.setText(text);
    },
    showError: function(editor, message) {
      App.SpeechToText.errorElementFor(editor).text(message).removeClass("hide");
    },
    clearError: function(editor) {
      App.SpeechToText.errorElementFor(editor).text("").addClass("hide");
    },
    supportedMimeType: function() {
      var candidates, i;
      candidates = ["audio/webm;codecs=opus", "audio/webm", "audio/mp4", "audio/ogg"];
      if (typeof MediaRecorder === "undefined" || typeof MediaRecorder.isTypeSupported !== "function") {
        return "";
      }
      for (i = 0; i < candidates.length; i += 1) {
        if (MediaRecorder.isTypeSupported(candidates[i])) {
          return candidates[i];
        }
      }
      return "";
    },
    captureInsertionAnchor: function(editor) {
      var data, selection;
      data = App.SpeechToText.editorData(editor);
      selection = editor.getSelection();
      if (selection) {
        data.bookmark = selection.createBookmarks(true);
      }
    },
    restoreInsertionAnchor: function(editor) {
      var data, range;
      data = App.SpeechToText.editorData(editor);
      if (!data.bookmark) {
        return;
      }
      try {
        editor.getSelection().selectBookmarks(data.bookmark);
      } catch (error) {
        range = editor.createRange();
        range.moveToElementEditEnd(editor.editable());
        editor.getSelection().selectRanges([range]);
      }
      data.bookmark = null;
    },
    findProvisionalElement: function(editor) {
      if (!editor.document) {
        return null;
      }
      return editor.document.findOne("span[data-speech-provisional]");
    },
    clearProvisionalMarkup: function(editor) {
      var cleared, provisional;

      cleared = false;
      while ((provisional = App.SpeechToText.findProvisionalElement(editor))) {
        provisional.remove(true);
        cleared = true;
      }
      if (cleared) {
        editor.updateElement();
      }
    },
    upsertTranscript: function(editor, text, options) {
      var data, finalize, provisional, selection;

      data = App.SpeechToText.editorData(editor);
      finalize = options.finalize;
      provisional = App.SpeechToText.findProvisionalElement(editor);
      App.SpeechToText.restoreInsertionAnchor(editor);

      if (provisional) {
        if (text) {
          provisional.setText(text);
        }
        if (finalize) {
          provisional.remove(true);
        }
      } else if (text) {
        if (finalize) {
          editor.insertText(text);
        } else {
          editor.insertHtml(
            '<span data-speech-provisional="true">' +
              CKEDITOR.tools.htmlEncode(text) +
              "</span>"
          );
        }
      }

      selection = editor.getSelection();
      if (selection && !finalize) {
        data.bookmark = selection.createBookmarks(true);
      }
      editor.updateElement();
    },
    applyLevel: function(editor, level) {
      if (!editor.container) {
        return;
      }
      editor.container.$.style.setProperty("--speech-level", level.toFixed(3));
    },
    startLevelMeter: function(editor, stream) {
      var AudioContextClass, analyser, context, data, dataArray, source;

      AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (!AudioContextClass) {
        return;
      }

      try {
        context = new AudioContextClass();
        analyser = context.createAnalyser();
        analyser.fftSize = 256;
        source = context.createMediaStreamSource(stream);
        source.connect(analyser);
      } catch (error) {
        if (context) {
          context.close();
        }
        return;
      }

      data = App.SpeechToText.editorData(editor);
      data.audioContext = context;
      dataArray = new window.Uint8Array(analyser.fftSize);

      function tick() {
        var i, level, rms, sample, sum;

        if (App.SpeechToText.stateFor(editor) !== "recording") {
          return;
        }

        analyser.getByteTimeDomainData(dataArray);
        sum = 0;
        for (i = 0; i < dataArray.length; i += 1) {
          sample = (dataArray[i] - 128) / 128;
          sum += sample * sample;
        }
        rms = Math.sqrt(sum / dataArray.length);
        level = Math.min(1, rms * 4);
        App.SpeechToText.applyLevel(editor, level);
        data.levelFrameId = window.requestAnimationFrame(tick);
      }

      if (context.state === "suspended") {
        context.resume();
      }
      tick();
    },
    stopLevelMeter: function(editor) {
      var data;

      data = App.SpeechToText.editorData(editor);
      if (data.levelFrameId) {
        window.cancelAnimationFrame(data.levelFrameId);
        data.levelFrameId = null;
      }
      if (data.audioContext) {
        data.audioContext.close();
        data.audioContext = null;
      }
      App.SpeechToText.applyLevel(editor, 0);
    },
    startPartialUploads: function(editor) {
      var data;

      data = App.SpeechToText.editorData(editor);
      clearInterval(data.partialIntervalId);
      data.partialIntervalId = setInterval(function() {
        App.SpeechToText.sendAudio(editor, { final: false });
      }, App.SpeechToText.PARTIAL_INTERVAL_MS);
    },
    stopPartialUploads: function(editor) {
      var data;

      data = App.SpeechToText.editorData(editor);
      clearInterval(data.partialIntervalId);
      data.partialIntervalId = null;
    },
    beginRecording: function(editor, stream, mimeType, config) {
      var chunks, data, recorder, timeoutId;

      data = App.SpeechToText.editorData(editor);
      chunks = [];
      recorder = new MediaRecorder(stream, { mimeType: mimeType });
      data.stream = stream;
      data.recorder = recorder;
      data.chunks = chunks;
      data.mimeType = mimeType;
      data.pendingPartial = false;
      data.finished = false;
      recorder.ondataavailable = function(event) {
        if (event.data && event.data.size > 0) {
          chunks.push(event.data);
        }
      };
      recorder.onerror = function() {
        App.SpeechToText.showError(editor, config.errorTranscriptionFailed);
        App.SpeechToText.reset(editor);
      };
      recorder.onstop = function() {
        stream.getTracks().forEach(function(track) {
          track.stop();
        });
        clearTimeout(data.timeoutId);
        data.timeoutId = null;
        App.SpeechToText.stopPartialUploads(editor);
        App.SpeechToText.sendAudio(editor, { final: true });
      };
      recorder.start(App.SpeechToText.TIMESLICE_MS);
      timeoutId = setTimeout(function() {
        App.SpeechToText.stopRecording(editor);
      }, App.SpeechToText.MAX_RECORDING_MS);
      data.timeoutId = timeoutId;
      App.SpeechToText.updateEditorState(editor, "recording");
      App.SpeechToText.startLevelMeter(editor, stream);
      App.SpeechToText.startPartialUploads(editor);
    },
    startRecording: function(editor) {
      var config, mimeType;
      config = App.SpeechToText.configFor(editor);
      App.SpeechToText.clearError(editor);
      if (!navigator.mediaDevices || typeof navigator.mediaDevices.getUserMedia !== "function") {
        App.SpeechToText.showError(editor, config.errorUnsupportedBrowser);
        return;
      }
      mimeType = App.SpeechToText.supportedMimeType();
      if (!mimeType) {
        App.SpeechToText.showError(editor, config.errorUnsupportedBrowser);
        return;
      }
      App.SpeechToText.clearProvisionalMarkup(editor);
      App.SpeechToText.captureInsertionAnchor(editor);
      App.SpeechToText.updateEditorState(editor, "loading");
      navigator.mediaDevices.getUserMedia({ audio: true }).then(function(stream) {
        if (App.SpeechToText.stateFor(editor) !== "loading") {
          stream.getTracks().forEach(function(track) {
            track.stop();
          });
          return;
        }
        App.SpeechToText.beginRecording(editor, stream, mimeType, config);
      }).catch(function() {
        App.SpeechToText.showError(editor, config.errorMicrophoneBlocked);
        App.SpeechToText.reset(editor);
      });
    },
    stopRecording: function(editor) {
      var data, recorder;
      data = App.SpeechToText.editorData(editor);
      recorder = data.recorder;
      App.SpeechToText.stopLevelMeter(editor);
      App.SpeechToText.stopPartialUploads(editor);
      if (!recorder || recorder.state === "inactive") {
        App.SpeechToText.updateEditorState(editor, "idle");
        return;
      }
      App.SpeechToText.updateEditorState(editor, "loading");
      recorder.stop();
    },
    sendAudio: function(editor, options) {
      var blob, config, data, finalUpload, formData, message, mimeType, request;

      data = App.SpeechToText.editorData(editor);
      config = App.SpeechToText.configFor(editor);
      finalUpload = options.final;

      if (finalUpload) {
        // Prevent partial re-uploads during the final upload.
        data.finished = true;
      }

      if (data.finished && !finalUpload) {
        return;
      }

      if (!finalUpload && data.xhr) {
        data.pendingPartial = true;
        return;
      }

      if (finalUpload && data.xhr) {
        data.xhr.abort();
        data.xhr = null;
      }

      if (!data.chunks || data.chunks.length === 0) {
        if (finalUpload) {
          App.SpeechToText.reset(editor);
        }
        return;
      }

      mimeType = data.mimeType;
      blob = new Blob(data.chunks, { type: mimeType });
      if (blob.size === 0) {
        if (finalUpload) {
          App.SpeechToText.reset(editor);
        }
        return;
      }

      data.pendingPartial = false;

      formData = new FormData();
      formData.append("audio_file", blob, "recording." + mimeType.split(/[/;]/)[1]);
      formData.append("locale", config.locale);

      request = $.ajax({
        url: config.endpoint,
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        dataType: "json",
        headers: { "X-CSRF-Token": $("meta[name='csrf-token']").attr("content") },
        success: function(response) {
          if (data.xhr !== request) {
            return;
          }
          data.xhr = null;

          App.SpeechToText.upsertTranscript(editor, response.text, { finalize: finalUpload });
          if (finalUpload) {
            App.SpeechToText.reset(editor);
            return;
          }
          if (data.pendingPartial && App.SpeechToText.stateFor(editor) === "recording") {
            App.SpeechToText.sendAudio(editor, { final: false });
          }
        },
        error: function(jqXHR) {
          if (data.xhr !== request) {
            return;
          }
          data.xhr = null;

          if (jqXHR.statusText === "abort") {
            return;
          }

          if (finalUpload) {
            message = (jqXHR.responseJSON && jqXHR.responseJSON.errors) ||
              config.errorTranscriptionFailed;
            App.SpeechToText.showError(editor, message);
            App.SpeechToText.reset(editor);
            return;
          }

          if (data.pendingPartial && App.SpeechToText.stateFor(editor) === "recording") {
            App.SpeechToText.sendAudio(editor, { final: false });
          }
        }
      });
      data.xhr = request;
    },
    clearRecordingData: function(editor) {
      var data, recorder, stream;
      data = App.SpeechToText.editorData(editor);
      App.SpeechToText.stopLevelMeter(editor);
      App.SpeechToText.stopPartialUploads(editor);
      if (data.xhr) {
        data.xhr.abort();
        data.xhr = null;
      }
      recorder = data.recorder;
      if (recorder && recorder.state !== "inactive") {
        recorder.onstop = null;
        recorder.stop();
      }
      stream = data.stream;
      if (stream) {
        stream.getTracks().forEach(function(track) {
          track.stop();
        });
      }
      clearTimeout(data.timeoutId);
      data.timeoutId = null;
      data.recorder = null;
      data.stream = null;
      data.chunks = null;
      data.mimeType = null;
      data.pendingPartial = false;
      data.finished = false;
    },
    reset: function(editor) {
      App.SpeechToText.restoreInsertionAnchor(editor);
      App.SpeechToText.clearProvisionalMarkup(editor);
      App.SpeechToText.clearRecordingData(editor);
      App.SpeechToText.updateEditorState(editor, "idle");
    }
  };
}).call(this);
