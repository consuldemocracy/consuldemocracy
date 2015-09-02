App.Votes =

  hoverize: (votes) ->
    $(votes).hover ->
      $("div.anonymous-votes", votes).show();
      $("div.organizations-votes", votes).show();
      $("div.not-logged", votes).show();
    , ->
      $("div.anonymous-votes", votes).hide();
      $("div.organizations-votes", votes).hide();
      $("div.not-logged", votes).hide();

  initialize: ->
    App.Votes.hoverize votes for votes in $("div.votes")
    false




