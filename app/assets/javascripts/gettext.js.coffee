i18n = {
  es: {
    "Comments": "Comentarios",
    "No comment": "Sin comentarios",
    "Cancel": "Cancelar",
    "Save": "Guardar",
    "Edit": "Editar",
    "Delete": "Borrar",
    "Unregistered": "<p>Necesitas <a href='/users/sign_in'>iniciar sesión</a> o <a href='/users/sign_up'>registrarte</a> para continuar.</p>"
  },
  en: {
    "Comments": "Coments",
    "No comment": "No comment",
    "Cancel": "Cancel",
    "Save": "Save",
    "Edit": "Edit",
    "Delete": "Delete",
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
