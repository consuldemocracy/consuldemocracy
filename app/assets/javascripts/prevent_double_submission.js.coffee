App.PreventDoubleSubmission =
  disable_buttons: (buttons) ->
    setTimeout ->
      buttons.each ->
        button = $(this)
        unless button.hasClass('disabled')
          loading = button.data('loading') ? '...'
          button.addClass('disabled').attr('disabled', 'disabled')
          button.data('text', button.val())
          button.val(loading)
    , 1

  reset_buttons: (buttons) ->
    buttons.each ->
      button = $(this)
      if button.hasClass('disabled')
        button_text = button.data('text')
        button.removeClass('disabled').attr('disabled', null)
        if button_text
          button.val(button_text)
          button.data('text', null)

  initialize: ->
    $('form').on('submit', (event) ->
      unless event.target.id == "new_officing_voter"
        buttons = $(this).find(':button, :submit')
        App.PreventDoubleSubmission.disable_buttons(buttons)
    ).on('ajax:success', (event) ->
      unless event.target.id == "new_officing_voter"
        buttons = $(this).find(':button, :submit')
        App.PreventDoubleSubmission.reset_buttons(buttons)
    )

    false
