App.Followable =

  initialize: ->
    $('.followable-content a[data-toggle]').on 'click', (event) ->
      event.preventDefault()
