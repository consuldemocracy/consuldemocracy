App.SurveyAnswers =

  initialize: ->
    $(".survey-questions").on
      click: (event) ->
        event.preventDefault();
        $("#login_required").show()