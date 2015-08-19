App.LocaleSwitcher =

  href_with_params: (query_params) ->
    loc = window.location

    loc.protocol + "//" + loc.hostname +
      (if loc.port then ':' + loc.port else '') +
      loc.pathname +
      loc.hash +
      '?' + $.param(query_params)

  initialize: ->
    $('.js-locale-switcher').on 'change', ->
      query_params = window.getQueryParameters()
      query_params['locale'] = $(this).val()
      window.location.assign(App.LocaleSwitcher.href_with_params(query_params))



