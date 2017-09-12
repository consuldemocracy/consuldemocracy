App.Imageable =

  initialize: ->
    @initializeDirectUploads()
    @initializeInterface()

  initializeDirectUploads: ->

    $('input.image_ajax_attachment[type=file]').fileupload

      paramName: "image[attachment]"

      formData: null

      add: (e, data) ->
        wrapper = $(e.target).closest('.image')
        index = $(e.target).data('index')
        is_nested_image = $(e.target).data('nested-image')
        $(wrapper).find('.progress-bar-placeholder').empty()
        data.progressBar = $(wrapper).find('.progress-bar-placeholder').html('<div class="progress-bar"><div class="loading-bar uploading"></div></div>')
        $(wrapper).find('.progress-bar-placeholder').css('display','block')
        data.formData = {
          "image[title]": $(wrapper).find('input.image-title').val() || data.files[0].name
          "index": index,
          "nested_image": is_nested_image
        }
        data.submit()

      change: (e, data) ->
        wrapper = $(e.target).parent()
        $.each(data.files, (index, file)->
          $(wrapper).find('.file-name').text(file.name)
        )

      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $(data.progressBar).find('.loading-bar').css 'width', progress + '%'
        return

  initializeInterface: ->
    input_files = $('input.image_ajax_attachment[type=file]')

    $.each input_files, (index, file) ->
      wrapper = $(file).parent()
      App.Imageable.watchRemoveImagebutton(wrapper)

  watchRemoveImagebutton:  (wrapper) ->
    remove_image_button = $(wrapper).find('.remove-image')
    $(remove_image_button).on 'click', (e) ->
      e.preventDefault()
      $(wrapper).remove()
      $('#new_image_link').show()
      $('.max-images-notice').hide()

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
    @initialize()

  destroyNestedImage: (id, notice) ->
    $('#' + id).remove()
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
