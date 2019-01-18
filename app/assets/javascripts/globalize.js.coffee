App.Globalize =

  display_locale: (locale) ->
    App.Globalize.enable_locale(locale)
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
      $('.js-delete-language').hide()
      $('#js_delete_' + locale).show()

  highlight_locale: (element) ->
    $('.js-globalize-locale-link').removeClass('is-active');
    element.addClass('is-active');

  remove_language: (locale) ->
    $(".js-globalize-attribute[data-locale=" + locale + "]").each ->
      $(this).val('').hide()
      if CKEDITOR.instances[$(this).attr('id')]
          CKEDITOR.instances[$(this).attr('id')].setData('')
    $(".js-globalize-locale-link[data-locale=" + locale + "]").hide()
    next = $(".js-globalize-locale-link:visible").first()
    App.Globalize.highlight_locale(next)
    App.Globalize.display_translations(next.data("locale"))
    App.Globalize.disable_locale(locale)

  enable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(false)
    App.Globalize.site_customization_enable_locale_field(locale).val(1)

  disable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(true)
    App.Globalize.site_customization_enable_locale_field(locale).val(0)

  enabled_locales: ->
    $.map(
      $(".js-globalize-locale-link:visible"),
      (element) -> $(element).data("locale")
    )

  destroy_locale_field: (locale) ->
    $("input[id$=_destroy][data-locale=" + locale + "]")

  site_customization_enable_locale_field: (locale) ->
    $("#enabled_translations_" + locale)

  refresh_visible_translations: ->
    locale = $('.js-globalize-locale-link.is-active').data("locale")
    App.Globalize.display_translations(locale)

  initialize: ->
    $('.js-globalize-locale').on 'change', ->
      App.Globalize.display_translations($(this).val())
      App.Globalize.display_locale($(this).val())

    $('.js-globalize-locale-link').on 'click', ->
      locale = $(this).data("locale")
      App.Globalize.display_translations(locale)
      App.Globalize.highlight_locale($(this))

    $('.js-delete-language').on 'click', ->
      locale = $(this).data("locale")
      $(this).hide()
      App.Globalize.remove_language(locale)

    $(".js-add-fields-container").on "cocoon:after-insert", ->
      $.each(
        App.Globalize.enabled_locales(),
        (index, locale) -> App.Globalize.enable_locale(locale)
      )
