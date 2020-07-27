(function() {
  "use strict";
  App.SocialShare = {
    removeScreenReaders: function() {
      $(".social-share-button a .show-for-sr").remove();
    },
    initialize: function() {
      $(".social-share-button a").each(function() {
        $(this).append("<span class='show-for-sr'>" + ($(this).data("site")) + "</span>");
      });
    }
  };

  $(document).on("turbolinks:before-cache", App.SocialShare.removeScreenReaders);
}).call(this);
