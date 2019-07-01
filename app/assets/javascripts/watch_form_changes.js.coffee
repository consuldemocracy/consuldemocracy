"use strict"

App.WatchFormChanges =
  forms: ->
    return $("form[data-watch-changes]")

  msg: ->
    return $("[data-watch-form-message]").data("watch-form-message")

  hasChanged: ->
    App.WatchFormChanges.forms().is ->
      $(this).serialize() != $(this).data("watchChanges")

  checkChanges: ->
    if App.WatchFormChanges.hasChanged()
      confirm(App.WatchFormChanges.msg())
    else
      true

  initialize: ->
    if App.WatchFormChanges.forms().length == 0 || App.WatchFormChanges.msg() == undefined
      return

    $(document).off("page:before-change").on("page:before-change", App.WatchFormChanges.checkChanges)

    App.WatchFormChanges.forms().each ->
      $(this).data("watchChanges", $(this).serialize())
