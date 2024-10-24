(function() {
  "use strict";
  App.Banners = {
    initialize: function() {
      $("[data-js-banner-title]").on({
        change: function() {
          $(".banner h2").text($(this).val());
        }
      });
      $("[data-js-banner-description]").on({
        change: function() {
          $(".banner h3").text($(this).val());
        }
      });
      $("[name='banner[background_color]']").on({
        change: function() {
          $(".banner").css("background-color", $(this).val());
        }
      });
      $("[name='banner[font_color]']").on({
        change: function() {
          $(".banner h2").css("color", $(this).val());
          $(".banner h3").css("color", $(this).val());
        }
      });
    }
  };
}).call(this);
