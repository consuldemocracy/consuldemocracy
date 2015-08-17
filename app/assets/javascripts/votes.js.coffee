App.Votes =

  hoverize: (votes) ->
    $(votes).hover ->
      $("div.not-logged", votes).show()
    , ->
      $("div.not-logged", votes).hide()

  initialize: ->
    App.Votes.hoverize votes for votes in $("div.votes")
    false




