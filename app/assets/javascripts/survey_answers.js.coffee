App.SurveyAnswers =

  initialize: ->
    verified_user_id = $('#survey').data('verified-id')
    if verified_user_id == ""
      $(".survey-questions").on
        click: (event) ->
          event.preventDefault();
          $alert = $("#login_required")
          if $alert.is(":visible")
            $("#login_required_text").effect("shake")
          else
            $alert.show()
