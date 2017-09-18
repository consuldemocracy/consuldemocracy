App.DirectUploads =

  progressBarTemplate: '<div class="progress-bar"><div class="loading-bar uploading"></div></div>'

  initialize: ->
    inputFiles = $('input.direct_upload_attachment[type=file]')

    $.each inputFiles, (index, input) ->
      App.DirectUploads.initializeDirectUploadInput(input)

  initializeDirectUploadInput: (input) ->

    $(input).fileupload

      paramName: "attachment"

      formData: null

      add: (e, data) ->
        data = App.DirectUploads.buildFileUploadData(e, data)
        data.submit()

      change: (e, data) ->
        $.each data.files, (index, file) ->
          App.DirectUploads.setFilename(data, file)

      fail: (e, data) ->
        $(data.cachedAttachmentField).val("")
        App.DirectUploads.clearFilename(data)
        App.DirectUploads.setProgressBar(data, 'errors')
        App.DirectUploads.clearInputErrors(data)
        App.DirectUploads.setInputErrors(data)
        App.DirectUploads.clearPreview(data)
        $(data.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove()
        $(data.addAttachmentLabel).show()

      done: (e, data) ->
        $(data.cachedAttachmentField).val(data.result.cached_attachment)
        App.DirectUploads.setTitleFromFile(data, data.result.filename)
        App.DirectUploads.setProgressBar(data, 'complete')
        App.DirectUploads.setFilename(data, data.result.filename)
        App.DirectUploads.clearInputErrors(data)

        $(data.destroyAttachmentLinkContainer).html(data.result.destroy_link)
        data.destroyAttachmentLinkContainer = $(data.wrapper).find('.action-remove')
        $(data.addAttachmentLabel).hide()

        App.DirectUploads.setPreview(data)

        $(data.destroyAttachmentLinkContainer).on 'click', (e) ->
          e.preventDefault()
          e.stopPropagation()
          console.log data
          App.DirectUploads.doDeleteCachedAttachmentRequest(e, data)


      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $(data.progressBar).find('.loading-bar').css 'width', progress + '%'
        return

  buildFileUploadData: (e, data) ->
    wrapper = $(e.target).closest('.direct-upload')
    data.input = e.target
    data.wrapper = wrapper
    data.preview = $(wrapper).find('.image-preview')
    data.progressBar = $(wrapper).find('.progress-bar-placeholder').html(App.DirectUploads.progressBarTemplate)
    data.errorContainer = $(wrapper).find('.attachment-errors')
    data.fileNameContainer = $(wrapper).find('p.file-name')
    data.destroyAttachmentLinkContainer = $(wrapper).find('.action-remove')
    data.addAttachmentLabel = $(wrapper).find('.action-add label')
    data.cachedAttachmentField = $(wrapper).find("#" + $(e.target).data('cached-attachment-input-field'))
    data.titleField = $(wrapper).find("#" + $(e.target).data('title-input-field'))
    $(wrapper).find('.progress-bar-placeholder').css('display', 'block')
    return data

  clearFilename: (data) ->
    $(data.fileNameContainer).text('')
    $(data.fileNameContainer).hide()

  clearInputErrors: (data) ->
    $(data.errorContainer).find('small.error').remove()

  clearProgressBar: (data) ->
    $(data.progressBar).find('.loading-bar').removeClass('complete errors uploading').css('width', "0px").css('display', "none")

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
    if data.result.is_image
      image_preview = '<div class="small-12 column text-center image-preview"><figure><img src="' + data.result.attachment_url + '" class="cached-image"/></figure></div>'
      if $(data.preview).length > 0
        $(data.preview).replaceWith(image_preview)
      else
        $(image_preview).insertBefore($(data.wrapper).find(".attachment-actions"))
        data.preview = $(data.wrapper).find('.image-preview')

  replaceWithNestedDestroyLink: (e, data) ->
    $(data.destroyAttachmentLinkContainer).find('a.delete').replaceWith('<a class="delete float-right remove-nested" href="#">Remove document</a>')
    $(data.destroyAttachmentLinkContainer).find('a.remove-nested').on 'click', (e) ->
      e.preventDefault()
      $(data.wrapper).remove()
      $(data.addAttachmentLabel).show()

  doDeleteCachedAttachmentRequest: (e, data) ->
    $.ajax
      type: "POST"
      url: e.target.href
      dataType: "json"
      data: { "_method": "delete" }
      complete: ->
        $(data.cachedAttachmentField).val("")
        $(data.addAttachmentLabel).show()

        console.log data
        App.DirectUploads.clearFilename(data)
        App.DirectUploads.clearInputErrors(data)
        App.DirectUploads.clearProgressBar(data)
        App.DirectUploads.clearPreview(data)

        if $(data.input).data('nested-image') == true
          App.DirectUploads.replaceWithNestedDestroyLink(e, data)
        else
          $(data.destroyAttachmentLinkContainer).find('a.delete').remove()