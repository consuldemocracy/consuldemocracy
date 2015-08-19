App.ModeratorDebates =

  add_class_faded: (id) ->
    $("##{id}").addClass("faded")
    $("#comments").addClass("faded")

  hide_moderator_actions: (id) ->
    $("##{id} #moderator-debate-actions:first").hide()