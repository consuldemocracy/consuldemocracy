App.FoundationExtras =

  initialize: ->
    $(document).foundation()
    $(window).trigger "init.zf.sticky"
    $(window).trigger "resize"

    clearSticky = ->
      $("[data-sticky]").foundation("destroy") if $("[data-sticky]").length

    $(document).on("page:before-unload", clearSticky)

    window.addEventListener("popstate", clearSticky, false)
