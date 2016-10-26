App.Probe =

  hide_option: ($this) ->
    id = $this.data('id')
    $("#probe_option_#{id}").hide()
    $("#js-show-hidden-projects").css('display', 'inline-block')
    false

  display_all_options: ->
    $(".probe_option").css('display', 'initial')
    false

  initialize: ->
    $('.js-hide-probe-option').on 'click', ->
      App.Probe.hide_option $(this)

    $('#js-show-hidden-projects').on 'click', ->
      App.Probe.display_all_options()