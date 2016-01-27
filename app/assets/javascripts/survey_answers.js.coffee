App.SurveyAnswers =

  initialize: ->
    verified_user_id = $('#survey').data('verified-id')
    if verified_user_id == ""
      $(".survey-questions").on
        click: (event) ->
          event.preventDefault();
          $("#login_required").show()