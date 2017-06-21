App.AllowParticipation =

  initialize: ->
    $(document).on {
      'mouseenter focus': ->
        $(this).find(".js-participation-not-allowed").show()
        $(this).find(".js-participation-allowed").hide()
      mouseleave: ->
        $(this).find(".js-participation-not-allowed").hide()
        $(this).find(".js-participation-allowed").show()
    }, ".js-participation"
    false
