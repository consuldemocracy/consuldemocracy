App.LegislationDebate =

  initialize: ->
    $('#js-toggle-debate').on
      click: ->
        $('#debate-info').toggle()
