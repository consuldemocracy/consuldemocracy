App.AdvancedSearch =

  advanced_search_terms: ->
    $('#js-advanced-search').data('advanced-search-terms')

  decorate_link: (id) ->
    $('.advanced-search-title').addClass 'blue'

  undecorate_link: (id) ->
    $('.advanced-search-title').removeClass 'blue'

  toggle_form: ->
    $('#js-advanced-search').slideToggle()

  toggle_date_options: ->
    if $('#js-advanced-search-date-min').val() == 'custom'
      $('#js-customized-date').show()
      $('#js-customized-date input').prop 'disabled', false
    else
      $('#js-customized-date').hide()
      $('#js-customized-date input').prop 'disabled', true

  initialize: ->
    if App.AdvancedSearch.advanced_search_terms()
      $('#js-advanced-search').show()
      App.AdvancedSearch.toggle_date_options()

    $('.advanced-search-title').on
      click: ->
        App.AdvancedSearch.toggle_form()
      mouseenter: ->
        App.AdvancedSearch.decorate_link()
      mouseleave: ->
        App.AdvancedSearch.undecorate_link()

    $('#js-advanced-search-date-min').on
      change: ->
        App.AdvancedSearch.toggle_date_options()