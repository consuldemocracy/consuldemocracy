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
    $('.button-support').click ->
      $(this).hide()
      $element = $(this).closest(".row").siblings().children(".total-votes-text").children(".total-votes-count")
      $count = parseInt($element.text()) + 1
      $element.replaceWith("<span class='total-votes-count'>" + $count + "</span>")
      return

  initialize: ->
    App.Votes.hoverize "div.votes"
    App.Votes.hoverize "div.supports"
    App.Votes.hide_button ""
    false
