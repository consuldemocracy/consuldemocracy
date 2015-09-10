App.PreventDoubleSubmission =
  disable_button: (button) ->
    unless button.hasClass('disabled')
      loading = button.data('loading') ? '...'
      button.addClass('disabled').attr('disabled', 'disabled')
      button.data('text', button.val())
      button.val(loading)

  reset_button: (button) ->
    if button.hasClass('disabled')
      button_text = button.data('text')
      button.removeClass('disabled').attr('disabled', null)
      if button_text
        button.val(button_text)
        button.data('text', null)

  initialize: ->
    $('form').on('submit', event, ->
      button = $(this).find('.button')
      App.PreventDoubleSubmission.disable_button(button)
    ).on('ajax:success', ->
      button = $(this).find('.button')
      App.PreventDoubleSubmission.reset_button(button)
    )

    false
