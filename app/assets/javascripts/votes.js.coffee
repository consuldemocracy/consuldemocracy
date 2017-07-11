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

  hide_button: ->
    console.log("Entro al metodo hide button")
    $('.button-support').click ->
      $(this).hide();
      console.log($($(".button-support")[0].closest(".row")).siblings()[0]);
      return

  initialize: ->
    console.log("initialize")
    App.Votes.hoverize "div.votes"
    App.Votes.hoverize "div.supports"
    App.Votes.hide_button ""
    false
