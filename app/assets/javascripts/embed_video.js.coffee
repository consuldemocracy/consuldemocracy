App.EmbedVideo =

  initialize: ->
    $('#js-embedded-video').each ->
      code = $(this).data("video-code")
      $('#js-embedded-video').html(code)
