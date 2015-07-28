jQuery ->

  toggle_comment = (id) ->
    $("#js-comment-form-#{id}").toggle()

  ready = ->
    $('body').on 'click', '.js-add-comment-link', ->
      id = $(this).data().id
      toggle_comment(id)
      false

  $(document).ready(ready)
  $(document).on('page:load', ready)