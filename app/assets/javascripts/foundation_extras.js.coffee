App.FoundationExtras =
  clearSticky: ->
    $("[data-sticky]").foundation("destroy") if $("[data-sticky]").length

  mobile_ui_init: ->
    $(window).trigger "load.zf.sticky"

  desktop_ui_init: ->
    $(window).trigger "init.zf.sticky"

  initialize: ->
    $(document).foundation()
    $(window).trigger "resize"
    $(document).on("page:before-unload", this.clearSticky)
    window.addEventListener("popstate", this.clearSticky, false)

    $ ->
      if $(window).width() < 620
        App.FoundationExtras.mobile_ui_init()
      else
        App.FoundationExtras.desktop_ui_init()
