App.Tracks =

  tracking_enabled: ->
    _paq?

  track_current_page: ->
    _paq.push(['setCustomUrl',   window.location.href])
    _paq.push(['setReferrerUrl', document.referrer])
    _paq.push(['trackPageView',  App.Tracks.page_title()])

  set_custom_var: (id, name, value, scope) ->
    _paq.push(['setCustomVariable', id, name, value, scope])
    _paq.push(['trackPageView'])

  track_event: ($this) ->
    category = $this.data('track-event-category')
    action   = $this.data('track-event-action')
    _paq.push(['trackEvent', category, action])

  proposal_show_page: ->
    $("#js-tracking").data('proposal-show')

  track_proposal: ->
    page_title = App.Tracks.page_title()
    proposal_rank = $('#js-tracking').data('proposal-rank')
    _paq.push(['trackPageView', page_title, {dimension6: proposal_rank}])

  page_title: ->
    $(document).find("title").text()

  initialize: ->
    if App.Tracks.tracking_enabled()

      if App.Tracks.proposal_show_page()
        App.Tracks.track_proposal()

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
