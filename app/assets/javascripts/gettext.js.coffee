i18n = {
  es: {
    "Comments": "Comentarios",
    "Cancel": "Cancelar",
    "Save": "Guardar",
  },
  en: {
    "Comments": "Coments",
    "Cancel": "Cancel",
    "Save": "Save",
  }
}

window.Gettext = (key) ->
  gettext: (key) ->
    locale_id = $('html').attr('lang')
    locale    = i18n[locale_id]
    if locale && locale[key]
      return locale[key]
    key
