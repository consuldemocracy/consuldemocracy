App.Supports =

  initialize: ->
    $(document).on {
      'mouseenter focus': ->
        $(this).find(".js-supports-not-allowed").show();
        $(this).find(".js-supports-allowed").hide();
      mouseleave: ->
        $(this).find(".js-supports-not-allowed").hide();
        $(this).find(".js-supports-allowed").show();
    }, ".js-supports"
    false
