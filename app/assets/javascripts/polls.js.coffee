App.Polls =
  generateToken: ->
    token = ""
    rand = ""
    for n in [0..5]
      rand = Math.random().toString(36).substr(2) # remove `0.`
      token = token + rand

    token = token.substring(0, 64)
    return token

  replaceToken: (token) ->
    $(".js-question-answer").each ->
      token_param = this.search.slice(-6)
      if token_param == "token="
        this.href = this.href + token

  initialize: ->
    token = App.Polls.generateToken()
    App.Polls.replaceToken(token)

    $(".zoom-link").on "click", (event) ->
      element = event.target
      answer = $(element).closest("div.answer")

      if $(answer).hasClass("medium-6")
        $(answer).removeClass("medium-6")
        $(answer).addClass("answer-divider")
        unless $(answer).hasClass("first")
          $(answer).insertBefore($(answer).prev("div.answer"))
      else
        $(answer).addClass("medium-6")
        $(answer).removeClass("answer-divider")
        unless $(answer).hasClass("first")
          $(answer).insertAfter($(answer).next("div.answer"))
