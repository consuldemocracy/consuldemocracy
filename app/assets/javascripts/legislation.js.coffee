App.Legislation =

  initialize: ->
    $('#js-toggle-debate').on
      click: ->
        $('#debate-show').toggle()

    $('#js-toggle-small-debate').on
      click: ->
        $('#debate-show').toggle()
        $('span').toggleClass('icon-angle-up')

    $('form#new_legislation_answer input.button').hide()
    $('form#new_legislation_answer input[type=radio]').on
      click: ->
        $('form#new_legislation_answer').submit()

    $('form#draft_version_go_to_version input.button').hide()
    $('form#draft_version_go_to_version select').on
      change: ->
        $('form#draft_version_go_to_version').submit()

    $('#js-toggle-legislation-process-header').on
      click: ->
        $('[data-target="legislation-header-full"]').toggle()
