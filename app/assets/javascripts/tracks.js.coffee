App.Tracks =

  tracking_enabled: ->
    _paq?

  set_custom_var: (id, name, value, scope) ->
    _paq.push(['setCustomVariable', id, name, value, scope])
    _paq.push(['trackPageView'])

  track_event: ($this) ->
    category = $this.data('track-event-category')
    action   = $this.data('track-event-action')
    _paq.push(['trackEvent', category, action])

  initialize: ->
    if App.Tracks.tracking_enabled()
      $('[data-track-usertype]').each ->
        $this = $(this)
        usertype = $this.data('track-usertype')
        App.Tracks.set_custom_var(1, "usertype", usertype, "visit")

      $('[data-track-event-category]').each ->
        $this = $(this)
        App.Tracks.track_event($this)

      $('[data-track-click]').on 'click', ->
        $this = $(this)
        App.Tracks.track_event($this)
