(function() {
  "use strict";

  CKEDITOR.plugins.add("speechtotext", {
    init: function(editor) {
      editor.addCommand("speechToText", {
        exec: function(ed) {
          App.SpeechToText.toggle(ed);
        }
      });

      editor.ui.addButton("SpeechToText", {
        label: editor.element.getAttribute("data-speech-to-text-label-idle"),
        command: "speechToText",
        toolbar: "speech,0"
      });

      editor.on("instanceReady", function() {
        App.SpeechToText.setupToolbarButton(editor);
      });

      editor.on("destroy", function() {
        App.SpeechToText.reset(editor);
      });
    }
  });
}).call(this);
