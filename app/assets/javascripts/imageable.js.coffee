App.Imageable =

  initialize: ->
    inputFiles = $('input.js-document-attachment[type=file]')

    $.each inputFiles, (index, input) ->
      App.Imageable.initializeDirectUploadInput(input)

    $("#new_image_link").on 'click', -> $(this).hide()

  initializeDirectUploadInput: (input) ->

    inputData = @buildData([], input)

    @initializeRemoveImageLink(input)

    @initializeRemoveCachedImageLink(input, inputData)

    $(input).fileupload

      paramName: "attachment"

      formData: null

      add: (e, data) ->
        data = App.Imageable.buildFileUploadData(e, data)
        App.Imageable.clearProgressBar(data)
        App.Imageable.setProgressBar(data, 'uploading')
        data.submit()

      change: (e, data) ->
        $.each data.files, (index, file) ->
          App.Imageable.setFilename(inputData, file.name)

      fail: (e, data) ->
        $(data.cachedAttachmentField).val("")
        App.Imageable.clearFilename(data)
        App.Imageable.setProgressBar(data, 'errors')
        App.Imageable.clearInputErrors(data)
        App.Imageable.setInputErrors(data)
        App.Imageable.clearPreview(data)
        $(data.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove()
        $(data.addAttachmentLabel).addClass('error')
        $(data.addAttachmentLabel).show()

      done: (e, data) ->
        $(data.cachedAttachmentField).val(data.result.cached_attachment)
        App.Imageable.setTitleFromFile(data, data.result.filename)
        App.Imageable.setProgressBar(data, 'complete')
        App.Imageable.setFilename(data, data.result.filename)
        App.Imageable.clearInputErrors(data)
        $(data.addAttachmentLabel).hide()
        $(data.wrapper).find(".attachment-actions").removeClass('small-12').addClass('small-6 float-right')
        $(data.wrapper).find(".attachment-actions .action-remove").removeClass('small-3').addClass('small-12')

        App.Imageable.setPreview(data)
        destroyAttachmentLink = $(data.result.destroy_link)
        $(data.destroyAttachmentLinkContainer).html(destroyAttachmentLink)
        $(destroyAttachmentLink).on 'click', (e) ->
          e.preventDefault()
          e.stopPropagation()
          App.Imageable.doDeleteCachedAttachmentRequest(this.href, data)

      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $(data.progressBar).find('.loading-bar').css 'width', progress + '%'
        return

  buildFileUploadData: (e, data) ->
    data = @buildData(data, e.target)
    return data

  buildData: (data, input) ->
    wrapper = $(input).closest('.direct-upload')
    data.input = input
    data.wrapper = wrapper
    data.progressBar = $(wrapper).find('.progress-bar-placeholder')
    data.preview = $(wrapper).find('.image-preview')
    data.errorContainer = $(wrapper).find('.attachment-errors')
    data.fileNameContainer = $(wrapper).find('p.file-name')
    data.destroyAttachmentLinkContainer = $(wrapper).find('.action-remove')
    data.addAttachmentLabel = $(wrapper).find('.action-add label')
    data.cachedAttachmentField = $(wrapper).find("#" + $(input).data('cached-attachment-input-field'))
    data.titleField = $(wrapper).find("#" + $(input).data('title-input-field'))
    $(wrapper).find('.progress-bar-placeholder').css('display', 'block')
    return data

  clearFilename: (data) ->
    $(data.fileNameContainer).text('')
    $(data.fileNameContainer).hide()

  clearInputErrors: (data) ->
    $(data.errorContainer).find('small.error').remove()

  clearProgressBar: (data) ->
    $(data.progressBar).find('.loading-bar').removeClass('complete errors uploading').css('width', "0px")

  clearPreview: (data) ->
    $(data.wrapper).find('.image-preview').remove()

  setFilename: (data, file_name) ->
    $(data.fileNameContainer).text(file_name)
    $(data.fileNameContainer).show()

  setProgressBar: (data, klass) ->
    $(data.progressBar).find('.loading-bar').addClass(klass)

  setTitleFromFile: (data, title) ->
    if $(data.titleField).val() == ""
      $(data.titleField).val(title)

  setInputErrors: (data) ->
    errors = '<small class="error">' + data.jqXHR.responseJSON.errors + '</small>'
    $(data.errorContainer).append(errors)

  setPreview: (data) ->
    console.log 'App.Imageable.setPreview'
    image_preview = '<div class="small-12 column text-center image-preview"><figure><img src="' + data.result.attachment_url + '" class="cached-image"/></figure></div>'
    if $(data.preview).length > 0
      $(data.preview).replaceWith(image_preview)
    else
      $(image_preview).insertBefore($(data.wrapper).find(".attachment-actions"))
      data.preview = $(data.wrapper).find('.image-preview')

  watchRemoveImagebutton:  (wrapper) ->
    remove_image_button = $(wrapper).find('a.delete[href="#"]')
    $(remove_image_button).on 'click', (e) ->
      e.preventDefault()
      $(wrapper).remove()
      $('#new_image_link').show()

  doDeleteCachedAttachmentRequest: (url, data) ->
    $.ajax
      type: "POST"
      url: url
      dataType: "json"
      data: { "_method": "delete" }
      complete: ->
        $(data.cachedAttachmentField).val("")
        $(data.addAttachmentLabel).show()

        App.Imageable.clearFilename(data)
        App.Imageable.clearInputErrors(data)
        App.Imageable.clearProgressBar(data)
        App.Imageable.clearPreview(data)

        if $(data.input).data('nested-image') == true
          $(data.wrapper).remove()
          $('#new_image_link').show()
        else
          $(data.destroyAttachmentLinkContainer).find('a.delete').remove()

  initializeRemoveImageLink: (input) ->
    wrapper = $(input).closest(".direct-upload")
    remove_image_link = $(wrapper).find('a.remove-nested-field')
    $(remove_image_link).on 'click', (e) ->
      e.preventDefault()
      $(wrapper).remove()
      $('#new_image_link').show()

  initializeRemoveCachedImageLink: (input, data) ->
    wrapper = $(input).closest(".direct-upload")
    remove_image_link = $(wrapper).find('a.remove-cached-attachment')
    $(remove_image_link).on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      App.Imageable.doDeleteCachedAttachmentRequest(this.href, data)

  new: (nested_field) ->
    nested_field = $(nested_field)
    $(".images-list").append(nested_field)
    input = nested_field.find("input[type='file']")
    @initializeDirectUploadInput(input)
    $("#new_image_link").hide()

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
