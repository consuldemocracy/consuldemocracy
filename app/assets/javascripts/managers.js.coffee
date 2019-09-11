"use strict"

App.Managers =

  generatePassword: ->
    possible_chars = "aAbcdeEfghiJkmnpqrstuUvwxyz23456789"

    chars = Array.apply(null, length: 12).map ->
      i = Math.floor(Math.random() * possible_chars.length)
      possible_chars.charAt(i)

    chars.join("")

  togglePassword: (type) ->
    $("#user_password").prop "type", type

  initialize: ->
    $(".generate-random-value").on "click", ->
      $("#user_password").val(App.Managers.generatePassword())

    $(".show-password").on "click", ->
      if $("#user_password").is("input[type='password']")
        App.Managers.togglePassword("text")
      else
        App.Managers.togglePassword("password")
