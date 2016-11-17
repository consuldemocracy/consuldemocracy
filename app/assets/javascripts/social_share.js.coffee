App.SocialShare =

  initialize: ->
    $(".social-share-button a").each ->
      $(this).after("<span class='accessibility'> </span>")