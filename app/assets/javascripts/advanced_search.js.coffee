App.AdvancedSearch =

  advanced_search_terms: ->
    $('#js-advanced-search').data('advanced-search-terms')

  toggle_form: (event) ->
    event.preventDefault();
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

    $('#js-advanced-search-title').on
      click: (event) ->
        App.AdvancedSearch.toggle_form(event)

    $('#js-advanced-search-date-min').on
      change: ->
        App.AdvancedSearch.toggle_date_options()