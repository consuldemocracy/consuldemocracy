App.BudgetsInvestments =

  hoverize: (votes) ->
    $(document).on {
      'mouseenter focus': ->
        $("div.register-not-allowed", this).show();
        $("div.register-allowed", this).hide();
      mouseleave: ->
        $("div.register-not-allowed", this).hide();
        $("div.register-allowed", this).show();
    }, votes

  initialize: ->
    App.BudgetsInvestments.hoverize "div.register-investment"
    false
