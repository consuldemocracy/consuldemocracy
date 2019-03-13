App.Banners =

  update_banner: (selector, text) ->
    $(selector).html(text)

  update_style: (selector, style) ->
    $(selector).removeClass($(selector).attr("class"), true)
      .addClass(style, true)

  update_background_color: (selector, background_color) ->
    $(selector).css("background-color", background_color)

  update_font_color: (selector, font_color) ->
    $(selector).css("color", font_color)

  initialize: ->
    $("[data-js-banner-title]").on
      change: ->
        App.Banners.update_banner("#js-banner-title", $(this).val())

    $("[data-js-banner-description]").on
      change: ->
        App.Banners.update_banner("#js-banner-description", $(this).val())

    $("[name='banner[background_color]']").on
      change: ->
        App.Banners.update_background_color("#js-banner-background", $(this).val())

    $("[name='banner[font_color]']").on
      change: ->
        App.Banners.update_font_color("#js-banner-title", $(this).val())
        App.Banners.update_font_color("#js-banner-description", $(this).val())
