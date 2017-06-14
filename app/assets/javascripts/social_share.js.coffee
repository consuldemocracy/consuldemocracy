App.SocialShare =

  initialize: ->
    $(".social-share-button a").each ->
      element = $(this)
      site = element.data('site')
      element.append("<span class='show-for-sr'>#{site}</span>")