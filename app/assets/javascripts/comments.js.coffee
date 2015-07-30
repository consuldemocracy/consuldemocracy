
App.Comments =

  toggle_form: (id) ->
    $("#js-comment-form-#{id}").toggle()

  initialize: ->
    $('body').on 'click', '.js-add-comment-link', ->
      id = $(this).data().id
      App.Comments.toggle_form(id)
      false


