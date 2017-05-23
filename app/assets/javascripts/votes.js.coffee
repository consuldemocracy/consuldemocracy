App.Votes =

  hoverize: (votes) ->
    $(document).on {
      'mouseenter focus': ->
        $("div.participation-not-allowed", this).show();
        $("div.participation-allowed", this).hide();
      mouseleave: ->
        $("div.participation-not-allowed", this).hide();
        $("div.participation-allowed", this).show();
    }, votes

  initialize: ->
    App.Votes.hoverize "div.votes"
    App.Votes.hoverize "div.supports"
    false
