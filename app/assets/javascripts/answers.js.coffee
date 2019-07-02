"use strict"

App.Answers =

  initializeAnswers: (answers) ->
    $(answers).on "cocoon:after-insert", (e, new_answer) ->
      given_order = App.Answers.maxGivenOrder(answers) + 1
      $(new_answer).find("[name$='[given_order]']").val(given_order)

  maxGivenOrder: (answers) ->
    max_order = 0
    $(answers).find("[name$='[given_order]']").each (index, answer) ->
      value = parseFloat($(answer).val())
      max_order = if value > max_order then value else max_order
    return max_order

  nestedAnswers: ->
    $(".js-answers").each (index, answers) ->
      App.Answers.initializeAnswers(answers)

  initialize: ->
    App.Answers.nestedAnswers()
