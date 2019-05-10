App.ModeratorProposalNotifications =

  add_class_faded: (id) ->
    $("##{id}").addClass("faded")

  hide_moderator_actions: (id) ->
    $("##{id} .js-moderator-proposal-notifications-actions:first").hide()
