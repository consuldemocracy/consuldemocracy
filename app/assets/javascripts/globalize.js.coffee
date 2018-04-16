App.Globalize =

  display_locale: (locale) ->
    $(".js-globalize-locale-link").each ->
      if $(this).data("locale") == locale
        $(this).show()
        App.Globalize.highlight_locale($(this))
      $(".js-globalize-locale option:selected").removeAttr("selected");
      return

  display_translations: (locale) ->
    $(".js-globalize-attribute").each ->
      if $(this).data("locale") == locale
        $(this).show()
      else
        $(this).hide()
      $('.delete-language').hide()
      $('#delete-' + locale).show()

  highlight_locale: (element) ->
    $('.js-globalize-locale-link').removeClass('highlight');
    element.addClass('highlight');

  remove_language: (locale) ->
    $(".js-globalize-attribute[data-locale=" + locale + "]").val('').hide()
    $(".js-globalize-locale-link[data-locale=" + locale + "]").hide()
    next = $(".js-globalize-locale-link:visible").first()
    App.Globalize.highlight_locale(next)
    App.Globalize.display_translations(next.data("locale"))
    $("#delete_translations_" + locale).val(1)

  initialize: ->
    $('.js-globalize-locale').on 'change', ->
      App.Globalize.display_translations($(this).val())
      App.Globalize.display_locale($(this).val())

    $('.js-globalize-locale-link').on 'click', ->
      locale = $(this).data("locale")
      App.Globalize.display_translations(locale)
      App.Globalize.highlight_locale($(this))

    $('.delete-language').on 'click', ->
      locale = $(this).data("locale")
      $(this).hide()
      App.Globalize.remove_language(locale)

