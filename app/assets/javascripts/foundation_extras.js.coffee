App.FoundationExtras =

  initialize: ->
    $(document).foundation()
    $(window).trigger "load.zf.sticky"
