App.SocialShare =

  initialize: ->
    $(".social-share-button a").each ->
      element = $(this)
      site = element.data('site')
      element.append("<span class='sr-only'>#{site}</span>")