App.WatchFormChanges =
  forms: ->
    return $('form[data-watch-changes]')

  msg: ->
    if($('[data-watch-form-message]').length)
      return $('[data-watch-form-message]').data('watch-form-message')

  checkChanges: (event) ->
    changes = false
    App.WatchFormChanges.forms().each ->
      form = $(this)
      if form.serialize() != form.data('watchChanges')
        changes = true
    if changes
      return confirm(App.WatchFormChanges.msg())
    else
      return true

  initialize: ->
    if App.WatchFormChanges.forms().length == 0 || App.WatchFormChanges.msg() == undefined
      return

    $(document).off('page:before-change').on('page:before-change', (e) -> App.WatchFormChanges.checkChanges(e))

    App.WatchFormChanges.forms().each ->
      form = $(this)
      form.data('watchChanges', form.serialize())

    false
