App.FixedBar =
  initialize: ->
    $('[data-fixed-bar]').each ->
      $this = $(this)
      fixedBarTopPosition = $this.offset().top

      $(window).on 'scroll', ->
        if $(window).scrollTop() > fixedBarTopPosition
          $this.addClass('is-fixed')
        else
          $this.removeClass('is-fixed')

