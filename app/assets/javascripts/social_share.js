(function() {
  "use strict";
  App.SocialShare = {
    initialize: function() {
      $(".social-share-button a").each(function() {
        $(this).append("<span class='show-for-sr'>" + ($(this).data("site")) + "</span>");
      });
    },
    destroy: function() {
      $(".social-share-button a .show-for-sr").remove();
    }
  };
}).call(this);
