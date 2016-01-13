App.AdvancedSearch =

  advanced_search_terms: ->
    $('#advanced-search').data('advanced-search-terms')

  decorate_link: (id) ->
    $('.advanced-search-title').addClass 'blue'

  undecorate_link: (id) ->
    $('.advanced-search-title').removeClass 'blue'

  toggle_form: ->
    $('#advanced-search').slideToggle()

  toggle_date_options: ->
    if $('#advanced_search_date_min').val() == 'custom'
      $('.customized-date').show()
      $('.customized-date input').prop 'disabled', false
    else
      $('.customized-date').hide()
      $('.customized-date input').prop 'disabled', true

  initialize: ->
    if App.AdvancedSearch.advanced_search_terms()
      $('#advanced-search').show()

    $('.advanced-search-title').on
      click: ->
        App.AdvancedSearch.toggle_form()
      mouseenter: ->
        App.AdvancedSearch.decorate_link()
      mouseleave: ->
        App.AdvancedSearch.undecorate_link()

    $('#advanced_search_date_min').on
      change: ->
        App.AdvancedSearch.toggle_date_options()