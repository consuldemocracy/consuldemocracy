App.Questions =

  nestedQuestions: ->
    $('.js-questions').on 'cocoon:after-insert', (e, new_question) ->
      App.Answers.initializeAnswers($(new_question).find('.js-answers'))

  initialize: ->
    App.Questions.nestedQuestions()
