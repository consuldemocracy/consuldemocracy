(function() {
  "use strict";
  App.EmbedVideo = {
    initialize: function() {
      $("#js-embedded-video").each(function() {
        var code;
        code = $(this).data("video-code");
        $("#js-embedded-video").html(code);
      });
    }
  };
}).call(this);
