App.Flaggable =

  update: (resource_id, button) ->
    $("#" + resource_id + " .js-flag-actions").html(button).foundation()
