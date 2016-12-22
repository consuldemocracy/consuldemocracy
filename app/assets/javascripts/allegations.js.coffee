App.Allegations =
  
  toggle_comments: ->
    $('.draft-allegation').toggleClass('comments-on');
    
  initialize: ->
    $('.js-toggle-allegations .draft-panel').on
        click: ->
          console.log("panel")
          App.Allegations.toggle_comments()
          
    $('.js-toggle-allegations').on
        click: ->
          console.log("column")
          if $('.draft-allegation').hasClass('comments-on')
            console.log("comments-on")
            return false
          else
            App.Allegations.toggle_comments()
