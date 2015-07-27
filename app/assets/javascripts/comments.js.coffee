jQuery ->

  toggle_comment = (id, klass) ->
    $("#js-comment-form-#{id}-#{klass}").toggle()

  ready = ->
    $('.js-add-comment-link').click ->
      id = $(this).data().id
      klass = $(this).data().klass
      toggle_comment(id, klass)
      false

  $(document).ready(ready)
  $(document).on('page:load', ready)