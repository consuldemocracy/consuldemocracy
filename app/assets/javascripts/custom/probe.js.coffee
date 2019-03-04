App.Probe =

  hide_option: (id) ->
    $("#probe_option_#{id}").hide()
    $("#js-show-hidden-projects").css('display', 'inline-block')
    false

  display_all_options: ->
    $(".probe_option").css('display', 'initial')
    $("#js-show-hidden-projects").css('display', 'none')
    false
