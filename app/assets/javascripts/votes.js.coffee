App.Votes =

  hoverize: (votes) ->
    $(document).on {
      'mouseenter focus': ->
        $("div.anonymous-votes", this).show();
        $("div.organizations-votes", this).show();
        $("div.not-logged", this).show();
        $("div.no-supports-allowed", this).show();
        $("div.logged", this).hide();
      mouseleave: ->
        $("div.anonymous-votes", this).hide();
        $("div.organizations-votes", this).hide();
        $("div.not-logged", this).hide();
        $("div.no-supports-allowed", this).hide();
        $("div.logged", this).show();
    }, votes

  initialize: ->
    App.Votes.hoverize "div.votes"
    App.Votes.hoverize "div.supports"
    false
