App.Answers =

  nestedAnswers: ->
    $('.nested-answers').on 'cocoon:after-insert', (e, insertedItem) ->
      nestedAnswersCount = $("input[type='hidden'][name$='[given_order]']").size()
      $(insertedItem).find("input[type='hidden'][name$='[given_order]']").val(nestedAnswersCount)

  initialize: ->
    App.Answers.nestedAnswers()
