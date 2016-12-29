App.LegislationQuestions =

  initialize: ->
    $('form#new_legislation_answer input.button').hide()
    $('form#new_legislation_answer input[type=radio]').on
      click: ->
        $('form#new_legislation_answer').submit()

