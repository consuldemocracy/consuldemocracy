App.Imageable =

  initialize: ->
    console.log 'App.Imageable initialize'
    input_files = $('input.direct_upload_attachment[type=file]')

    $.each input_files, (index, file) ->
      wrapper = $(file).closest(".direct-upload")
      App.Imageable.watchRemoveImagebutton(wrapper)

    $("#new_image_link").on 'click', ->
      $(this).hide()

  watchRemoveImagebutton:  (wrapper) ->
    console.log 'App.Imageable watchRemoveDocumentbutton'
    remove_image_button = $(wrapper).find('a.delete[href="#"]')
    $(remove_image_button).on 'click', (e) ->
      e.preventDefault()
      $(wrapper).remove()
      $('#new_image_link').show()

  uploadNestedImage: (id, nested_image, result) ->
    $('#' + id).replaceWith(nested_image)
    @updateLoadingBar(id, result)
    @initialize()

  uploadPlainImage: (id, nested_image, result) ->
    $('#' + id).replaceWith(nested_image)
    @updateLoadingBar(id, result)
    @initialize()

  updateLoadingBar: (id, result) ->
    if result
      $('#' + id).find('.loading-bar').addClass 'complete'
    else
      $('#' + id).find('.loading-bar').addClass 'errors'
    $('#' + id).find('.progress-bar-placeholder').css('display','block')

  new: (nested_fields) ->
    $(".images-list").append(nested_fields)
    $("#new_image_link").hide()
    @initialize()

  destroyNestedImage: (id, notice) ->
    $('#' + id).remove()
    $("#new_image_link").show()
    @updateNotice(notice)

  replacePlainImage: (id, notice, plain_image) ->
    $('#' + id).replaceWith(plain_image)
    @updateNotice(notice)
    @initialize()

  updateNotice: (notice) ->
    if $('[data-alert]').length > 0
      $('[data-alert]').replaceWith(notice)
    else
      $("body").append(notice)

  updateNewImageButton: (link) ->
    if $('.image').length >= $('.images').data('max-images')
      $('#new_image_link').hide()
      $('.max-images-notice').removeClass('hide')
      $('.max-images-notice').show()
    else if $('#new_image_link').length > 0
      $('#new_image_link').replaceWith(link)
      $('.max-images-notice').hide()
    else
      $('.max-images-notice').hide()
      $(link).insertBefore('.images hr:last')
