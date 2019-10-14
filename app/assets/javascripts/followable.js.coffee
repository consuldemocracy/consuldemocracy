App.Followable =

  update: (followable_id, button, notice) ->
    $("#" + followable_id + " .js-follow").html(button)
    if ($('[data-alert]').length > 0)
      $('[data-alert]').replaceWith(notice)
    else
      $("body").append(notice)
