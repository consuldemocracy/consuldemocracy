App.PreventDoubleSubmission =
  click_and_disable_link: (link, event) ->
    if link.is('[disabled]')
      event.stopPropagation()
      event.preventDefault()
      false
    else
      link.addClass('disabled').attr('disabled', 'disabled')

  reset_links: ->
    $('.js-prevent-double-submit').each ->
      $this = $(this)

      if $this.is('[disabled]')
        $this.removeClass('disabled').attr('disabled', null)

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
    $('form').on('submit', ->
      button = $(this).find(':button, :submit')
      App.PreventDoubleSubmission.disable_button(button)
    ).on('ajax:success', ->
      button = $(this).find(':button, :submit')
      App.PreventDoubleSubmission.reset_button(button)
    )

    $('.js-prevent-double-submit').on 'click', event, ->
      App.PreventDoubleSubmission.click_and_disable_link($(this), event)

    false
