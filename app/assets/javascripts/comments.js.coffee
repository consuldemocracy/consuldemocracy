jQuery ->

  toggle_comment = (id) ->
    $("#js-comment-form-#{id}").toggle()

  $('.js-add-comment-link').click ->
    id = $(this).data().id
    toggle_comment(id)
    false