App.Banners =

  update_banner: (selector, text) ->
    $(selector).html(text)

  update_style: (selector, style) ->
    $(selector).removeClass($(selector).attr("class"), true)
      .addClass(style, true)

  update_background_color: (selector, text_selector, background_color) ->
    $(selector).css('background-color', background_color);
    $(text_selector).val(background_color);

  update_font_color: (selector, text_selector, font_color) ->
    $(selector).css('color', font_color);
    $(text_selector).val(font_color);

  initialize: ->
    $('[data-js-banner-title]').on
      change: ->
        App.Banners.update_banner("#js-banner-title", $(this).val())

    $('[data-js-banner-description]').on
      change: ->
        App.Banners.update_banner("#js-banner-description", $(this).val())

    $("#banner_background_color_picker").on
      change: ->
        App.Banners.update_background_color("#js-banner-background", "#banner_background_color", $(this).val());

    $("#banner_background_color").on
      change: ->
        App.Banners.update_background_color("#js-banner-background", "#banner_background_color_picker", $(this).val());

    $("#banner_font_color_picker").on
      change: ->
        App.Banners.update_font_color("#js-banner-title", "#banner_font_color", $(this).val());
        App.Banners.update_font_color("#js-banner-description", "#banner_font_color", $(this).val());

    $("#banner_font_color").on
      change: ->
        App.Banners.update_font_color("#js-banner-title", "#banner_font_color_picker", $(this).val());
        App.Banners.update_font_color("#js-banner-description", "#banner_font_color_picker", $(this).val());
