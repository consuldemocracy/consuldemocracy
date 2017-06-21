App.Banners =

  update_banner: (selector, text) ->
    $(selector).html(text)

  update_style: (selector, style) ->
    $(selector).removeClass($(selector).attr("class"), true)
      .addClass(style, true)

  initialize: ->
    $('[data-js-banner-title]').on
      change: ->
        App.Banners.update_banner("#js-banner-title", $(this).val())

    $('[data-js-banner-description]').on
      change: ->
        App.Banners.update_banner("#js-banner-description", $(this).val())

    $("#banner_style").on
      change: ->
        App.Banners.update_style("#js-banner-style", $(this).val())

    $("#banner_image").on
      change: ->
        App.Banners.update_style("#js-banner-image", $(this).val())
