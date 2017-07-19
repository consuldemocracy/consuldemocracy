App.Followable =

  update: (followable_id, button) ->
    $("#" + followable_id + " .js-follow").html(button)
