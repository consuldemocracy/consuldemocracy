App.Flagable =

  update: (proposal_id, button) ->
    $("#" + proposal_id + " .js-flag-actions-container").html(button).foundation()
