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
      false
    )

  uploadButton: ->
    element = $('input[type=file]')
    i = 0
    while i < element.length
      element[i].addEventListener 'change', ->
        idButton = $(this)
        idButton.closest('.image-upload').find('p').text(@files[0].name)
        return
      i++

  initialize: ->
    App.Forms.disableEnter()
    App.Forms.submitOnChange()
    App.Forms.toggleLink()
    App.Forms.uploadButton()
    false
