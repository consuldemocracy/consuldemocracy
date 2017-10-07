App.Polls =
  generateToken: ->
    token = ''
    rand = ''
    for n in [0..5]
      rand = Math.random().toString(36).substr(2) # remove `0.`
      token = token + rand;

    token = token.substring(0, 64)
    return token

  replaceToken: ->
    for link in $('.js-question-answer')
      token_param = link.search.slice(-6)
      if token_param == "token="
        link.href = link.href + @token

  initialize: ->
    @token = App.Polls.generateToken()
    App.Polls.replaceToken()

    $(".js-question-answer").on
      click: =>
        token_message = $(".js-token-message")
        if !token_message.is(':visible')
          token_message.html(token_message.html() + "<br><strong>" + @token + "</strong>");
          token_message.show()
    false
