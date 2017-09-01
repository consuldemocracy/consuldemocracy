App.Forms =

  disableEnter: ->
    $('form.js-enter-disabled').on('keyup keypress', (event) ->
      if event.which == 13
        e.preventDefault()
    )

  submitOnChange: ->
    $('.js-submit-on-change').unbind('change').on('change', ->
      $(this).closest('form').submit()
      false
    )

  toggleLink: ->
    $('.js-toggle-link').unbind('click').on('click', ->
      $($(this).data('toggle-selector')).toggle("down")
      if $(this).data('toggle-text') isnt undefined
        toggle_txt = $(this).text()
        $(this).text( $(this).data('toggle-text')  )
        $(this).data('toggle-text', toggle_txt)

      false
    )

  initialize: ->
    App.Forms.disableEnter()
    App.Forms.submitOnChange()
    App.Forms.toggleLink()
    false
