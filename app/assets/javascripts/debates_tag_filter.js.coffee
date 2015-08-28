App.DebatesTagFilter =

  href_with_params: (query_params) ->
    loc = window.location

    loc.protocol + "//" + loc.hostname +
      (if loc.port then ':' + loc.port else '') +
      loc.pathname +
      loc.hash +
      '?' + $.param(query_params)

  initialize: ->
    $('.js-tag-filter').on 'change', ->
      query_params = window.getQueryParameters()
      query_params['tag'] = $(this).val()
      window.location.assign(App.DebatesTagFilter.href_with_params(query_params))

