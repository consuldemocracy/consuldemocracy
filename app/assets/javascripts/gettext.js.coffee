i18n = {
  es: {
    "Comments": "Comentarios",
    "Cancel": "Cancelar",
    "Save": "Guardar",
    "Unregistered": "Necesitas <a href='/users/sign_in'>iniciar sesión</a> o <a href='/users/sign_up'>registrarte</a> para continuar."
  },
  en: {
    "Comments": "Coments",
    "Cancel": "Cancel",
    "Save": "Save",
    "Unregistered": "You need to <a href='/users/sign_in'>sign in</a> or <a href='/users/sign_up'>sign up</a> to continue."
  }
}

window.Gettext = (key) ->
  gettext: (key) ->
    locale_id = $('html').attr('lang')
    locale    = i18n[locale_id]
    if locale && locale[key]
      return locale[key]
    key
