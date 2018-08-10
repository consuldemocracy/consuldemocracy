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

  toggleSelect: ->
    $('.js-toggle-select').unbind('change').on('change', ->
      dropdown = $(this)
      target = $(dropdown.data('toggle-selector'))

      if dropdown.val() in dropdown.data('hide-on').split(',')
        target.addClass('hide')
      else
        target.removeClass('hide')
    )

  initialize: ->
    App.Forms.disableEnter()
    App.Forms.submitOnChange()
    App.Forms.toggleLink()
    App.Forms.toggleSelect()
    false
