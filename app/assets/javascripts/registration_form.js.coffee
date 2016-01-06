App.RegistrationForm =

  initialize: ->

    registrationForm = $("form#new_user[action=\"/users\"]")

    submitForm = ->
      registrationForm.submit()

    clearErrors = ->
      $("small").remove()

    checkErrors = (errors) ->
        valid = true
        for key, messages of errors when messages.length > 0
          field = $("input#user_#{key}")
          if field.length > 0
            valid = false
            field.after $("<small class=\"error\" style=\"margin-top: -16px;\">#{messages[0]}</small>")

        submitForm() if valid

    validateUser = ->
      request = $.post "/user/registrations/validate", $("form").serialize()
      request.done (errors) ->
        clearErrors()
        checkErrors(errors)


    if registrationForm.length > 0
      $("input[type=\"submit\"]").on "click", (event) ->
        event.preventDefault()
        validateUser()

