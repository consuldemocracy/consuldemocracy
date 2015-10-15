App.ModeratorMedidas =

  add_class_faded: (id) ->
    $("##{id}").addClass("faded")
    $("#comments").addClass("faded")

  hide_moderator_actions: (id) ->
    $("##{id} .js-moderator-medida-actions:first").hide()
