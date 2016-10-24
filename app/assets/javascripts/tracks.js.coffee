App.Tracks =

  tracking_enabled: ->
    _paq?

  track_current_page: ->
    _paq.push(['setCustomUrl',   window.location.href])
    _paq.push(['setReferrerUrl', document.referrer])
    _paq.push(['trackPageView',  $(document).find("title").text()])

  set_custom_var: (id, name, value, scope) ->
    _paq.push(['setCustomVariable', id, name, value, scope])
    _paq.push(['trackPageView'])

  track_event: ($this) ->
    category = $this.data('track-event-category')
    action   = $this.data('track-event-action')
    _paq.push(['trackEvent', category, action])

  initialize: ->
    if App.Tracks.tracking_enabled()
      App.Tracks.track_current_page()

      $('[data-track-usertype]').each ->
        $this = $(this)
        cvar = $this.data('track-usertype')
        App.Tracks.set_custom_var(1, "Tipo_de_usuario", cvar, "visit")

      $('[data-track-age_group]').each ->
        $this = $(this)
        cvar = $this.data('track-age_group')
        App.Tracks.set_custom_var(2, "Grupo_de_edad", cvar, "visit")

      $('[data-track-gender]').each ->
        $this = $(this)
        cvar = $this.data('track-gender')
        App.Tracks.set_custom_var(3, "Género", cvar, "visit")

      $('[data-track-event-category]').each ->
        $this = $(this)
        App.Tracks.track_event($this)
