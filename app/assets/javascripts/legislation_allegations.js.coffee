App.LegislationAllegations =

  toggle_comments: ->
    $('.draft-allegation').toggleClass('comments-on');
    $('#comments-box').html('').hide()

  show_comments: ->
    $('.draft-allegation').addClass('comments-on');

  initialize: ->
    $('.js-toggle-allegations .draft-panel').on
        click: (e) ->
          e.preventDefault();
          e.stopPropagation();
          App.LegislationAllegations.toggle_comments()

    $('.js-toggle-allegations').on
        click: (e) ->
          # Toggle comments when the section title is visible
          if $(this).find('.draft-panel .panel-title:visible').length == 0
            App.LegislationAllegations.toggle_comments()
