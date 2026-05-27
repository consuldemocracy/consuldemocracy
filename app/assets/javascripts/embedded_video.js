(function() {
  "use strict";
  App.EmbeddedVideo = {
    initialize: function() {
      $(".embedded-video").each(function() {
        var video;

        video = $("[data-video-code]", $(this));
        video.html(video.data("video-code"));
      });
    }
  };
}).call(this);
