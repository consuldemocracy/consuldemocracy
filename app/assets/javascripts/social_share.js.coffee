"use strict"

App.SocialShare =

  initialize: ->
    $(".social-share-button a").each ->
      $(this).append("<span class='show-for-sr'>#{$(this).data("site")}</span>")
