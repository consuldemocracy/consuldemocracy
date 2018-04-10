App.Globalize =

  display_locale: (locale) ->
    $(".js-globalize-locale-link").each ->
      if $(this).data("locale") == locale
        $(this).show()
      $(".js-globalize-locale option:selected").removeAttr("selected");
      return

  display_translations: (locale) ->
    $(".js-globalize-attribute").each ->
      console.log("In standard")
      console.log($(this))
      if $(this).data("locale") == locale
        $(this).show()
      else
        $(this).hide()

  highlight_locale: (element) ->
    $('.js-globalize-locale-link').removeClass('highlight');
    element.addClass('highlight');

  initialize: ->
    $('.js-globalize-locale').on 'change', ->
      App.Globalize.display_translations($(this).val())
      App.Globalize.display_locale($(this).val())

    $('.js-globalize-locale-link').on 'click', ->
      locale = $(this).data("locale")
      App.Globalize.display_translations(locale)
      App.Globalize.highlight_locale($(this))