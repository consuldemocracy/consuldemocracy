(function() {
  "use strict";
  App.Banners = {
    initialize: function() {
      $("[data-js-banner-title]").on({
        change: function() {
          $("#js-banner-title").html($(this).val());
        }
      });
      $("[data-js-banner-description]").on({
        change: function() {
          $("#js-banner-description").html($(this).val());
        }
      });
      $("[name='banner[background_color]']").on({
        change: function() {
          $("#js-banner-background").css("background-color", $(this).val());
        }
      });
      $("[name='banner[font_color]']").on({
        change: function() {
          $("#js-banner-title").css("color", $(this).val());
          $("#js-banner-description").css("color", $(this).val());
        }
      });
    }
  };
}).call(this);
