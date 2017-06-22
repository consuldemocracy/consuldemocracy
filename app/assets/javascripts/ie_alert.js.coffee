App.IeAlert =
  set_cookie_and_hide: (event) ->
    event.preventDefault()
    $.cookie('ie_alert_closed', 'true', { path: '/', expires: 365 })
    $('.ie-callout').remove()

  initialize: ->
    $('.ie-callout-close-js').on 'click', (event) ->
      App.IeAlert.set_cookie_and_hide(event)
