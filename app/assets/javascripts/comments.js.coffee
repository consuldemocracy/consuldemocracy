jQuery ->

  toggle_comment = (id) ->
    $("#js-comment-form-#{id}").toggle()

  ready = ->
    $('.js-add-comment-link').click ->
      id = $(this).data().id
      toggle_comment(id)
      false

  $(document).ready(ready)
  $(document).on('page:load', ready)