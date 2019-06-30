"use strict"

App.RegistrationForm =

  initialize: ->
    usernameInput = $("form#new_user[action=\"/users\"] input#user_username")

    clearUsernameMessage = ->
      $("small").remove()

    showUsernameMessage = (response) ->
      klass = if response.available then "no-error" else "error"
      usernameInput.after $("<small class=\"#{klass}\" style=\"margin-top: -16px;\">#{response.message}</small>")

    validateUsername = (username) ->
      request = $.get "/user/registrations/check_username?username=#{username}"
      request.done (response) ->
        showUsernameMessage(response)


    usernameInput.on "focusout", ->
      clearUsernameMessage()
      username = usernameInput.val()
      validateUsername(username) if username != ""
