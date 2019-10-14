App.ModeratorComments =

  add_class_faded: (id) ->
    $("##{id} .comment-body:first").addClass("faded")

  hide_moderator_actions: (id) ->
    $("##{id} .js-moderator-comment-actions").hide()
