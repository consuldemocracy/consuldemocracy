App.SurveyAnswers =

  initialize: ->
    current_user_id = $('html').data('current-user-id')
    if current_user_id == ""
      $(".survey-questions").on
        click: (event) ->
          event.preventDefault();
          $("#login_required").show()