App.Followable =

  initialize: ->
    $('.followable-content a[data-toggle]').on 'click', (event) ->
      event.preventDefault()

  update: (followable_id, button) ->
    $("#" + followable_id + " .js-follow").html(button)
