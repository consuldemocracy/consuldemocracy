App.Allegations =
  
  toggle_comments: ->
    $('.draft-allegation').toggleClass('comments-on');
    
  toggle_index: ->
    $('.draft-allegation').toggleClass('comments-on');
      
  initialize: ->
    $('#js-toggle-allegation-comments').on
      click: ->
        App.Allegations.toggle_comments()
          
    $('#js-toggle-allegation-index').on
      click: ->
        App.Allegations.toggle_index()
