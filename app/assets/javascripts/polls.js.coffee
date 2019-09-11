"use strict"

App.Polls =
  generateToken: ->
    strings = Array.apply(null, length: 6).map ->
      Math.random().toString(36).substr(2) # remove `0.`

    strings.join("").substring(0, 64)

  replaceToken: (token) ->
    $(".js-question-answer").each ->
      token_param = this.search.slice(-6)
      if token_param == "token="
        this.href = this.href + token

  initialize: ->
    token = App.Polls.generateToken()
    App.Polls.replaceToken(token)

    $(".zoom-link").on "click", (event) ->
      answer = $(event.target).closest("div.answer")

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
