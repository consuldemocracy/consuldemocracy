App.CustomManangementUtils =

  generateRandomLogin: () ->

    charset = "abcdefghijklmnopqrstuvwyz";
    digits = "0123456789";
    mid = "12";
    prefix = ((charset.charAt(Math.floor(Math.random() * charset.length))) for num in [3..1]).join('')
    mid = (mid.charAt(Math.floor(Math.random() * mid.length)))
    suffix = ((digits.charAt(Math.floor(Math.random() * digits.length))) for num in [3..1]).join('')

    "#{prefix}#{mid}#{suffix}"

  initialize: ->

    generateRandomLogin = @generateRandomLogin
    $("#new_user input[name='user[randomly_generated_credentials]']").change ->
      domain = $(this).data('domain')
      login  = ""
      email  = ""

      if ( $(this).prop('checked') )
        login = generateRandomLogin()
        email = "#{login}@#{domain}"

      $("#new_user input[name='user[email]']").val(email)
      $("#new_user input[name='user[username]']").val(login)

    false
