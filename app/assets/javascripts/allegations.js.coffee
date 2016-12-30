App.Allegations =

  toggle_comments: ->
    $('.draft-allegation').toggleClass('comments-on');

  initialize: ->
    $('.js-toggle-allegations .draft-panel').on
        click: (e) ->
          e.preventDefault();
          e.stopPropagation();
          App.Allegations.toggle_comments()

    $('.js-toggle-allegations').on
        click: (e) ->
          # Toggle comments when the section title is visible
          if $(this).find('.draft-panel .panel-title:visible').length == 0
            App.Allegations.toggle_comments()
