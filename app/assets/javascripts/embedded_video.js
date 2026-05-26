(function() {
  "use strict";
  App.EmbeddedVideo = {
    initialize: function() {
      $(".embedded-video").each(function() {
        var video, accept_button;

        video = $("[data-video-code]", $(this));
        accept_button = $("button", video);

        if (accept_button.length > 0) {
          accept_button.on("click", function() {
            video.html(video.data("video-code"));
          });
        } else {
          video.html(video.data("video-code"));
        }
      });
    }
  };
}).call(this);
