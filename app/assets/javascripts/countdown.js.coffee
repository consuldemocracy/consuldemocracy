App.Countdown =

  getTimeRemaining: (deadline) ->
    t = Date.parse(deadline) - Date.parse(new Date)
    return {
      total: t,
      days: Math.floor(t / (1000 * 60 * 60 * 24)),
      hours: Math.floor(t / (1000 * 60 * 60) % 24),
      minutes: Math.floor(t / 1000 / 60 % 60),
      seconds: Math.floor(t / 1000 % 60)
    }

  initialize: ->

    $('[data-countdown]').each ->
      $this = $(this)

      deadline = $this.data('countdown')

      $days = $this.find('[data-days]')
      $hours = $this.find('[data-hours]')
      $minutes = $this.find('[data-minutes]')
      $seconds = $this.find('[data-seconds]')

      updateClock = ->
        t = App.Countdown.getTimeRemaining(deadline)
        $days.text(t.days)
        $hours.text(('0' + t.hours).slice(-2))
        $minutes.text(('0' + t.minutes).slice(-2))
        $seconds.text(('0' + t.seconds).slice(-2))
        if t.total <= 0
          clearInterval timeinterval

      updateClock()
      timeinterval = setInterval(updateClock, 1000)
