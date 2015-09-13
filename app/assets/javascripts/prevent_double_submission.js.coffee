App.PreventDoubleSubmission =
  disable_button: (buttons) ->
    buttons.each (button)->
      unless button.hasClass('disabled')
        loading = button.data('loading') ? '...'
        button.addClass('disabled').attr('disabled', 'disabled')
        button.data('text', button.val())
        button.val(loading)

  reset_button: (buttons) ->
    buttons.each (button)->
      if button.hasClass('disabled')
        button_text = button.data('text')
        button.removeClass('disabled').attr('disabled', null)
        if button_text
          button.val(button_text)
          button.data('text', null)

  initialize: ->
    $('form').on('submit', event, ->
      buttons = $(this).find(':button, :submit')
      App.PreventDoubleSubmission.disable_buttons(buttons)
    ).on('ajax:success', ->
      buttons = $(this).find(':button, :submit')
      App.PreventDoubleSubmission.reset_buttons(buttons)
    )

    false
