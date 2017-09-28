App.Documentable =

  initialize: ->

    inputFiles = $('.js-document-attachment')
    $.each inputFiles, (index, input) ->
      App.Documentable.initializeDirectUploadInput(input)

    $('#nested-documents').on 'cocoon:after-remove', (e, insertedItem) ->
      App.Documentable.unlockUploads()

    $('#nested-documents').on 'cocoon:after-insert', (e, nested_document) ->
      input = $(nested_document).find('.js-document-attachment')
      App.Documentable.initializeDirectUploadInput(input)

      if $(nested_document).closest('#nested-documents').find('.document:visible').length >= $('#nested-documents').data('max-documents-allowed')
        App.Documentable.lockUploads()

  initializeDirectUploadInput: (input) ->

    inputData = @buildData([], input)

    @initializeRemoveCachedDocumentLink(input, inputData)

    $(input).fileupload

      paramName: "attachment"

      formData: null

      add: (e, data) ->
        data = App.Documentable.buildFileUploadData(e, data)
        App.Documentable.clearProgressBar(data)
        App.Documentable.setProgressBar(data, 'uploading')
        data.submit()

      change: (e, data) ->
        $.each data.files, (index, file) ->
          App.Documentable.setFilename(inputData, file.name)

      fail: (e, data) ->
        $(data.cachedAttachmentField).val("")
        App.Documentable.clearFilename(data)
        App.Documentable.setProgressBar(data, 'errors')
        App.Documentable.clearInputErrors(data)
        App.Documentable.setInputErrors(data)
        $(data.destroyAttachmentLinkContainer).find("a.delete:not(.remove-nested)").remove()
        $(data.addAttachmentLabel).addClass('error')
        $(data.addAttachmentLabel).show()

      done: (e, data) ->
        $(data.cachedAttachmentField).val(data.result.cached_attachment)
        App.Documentable.setTitleFromFile(data, data.result.filename)
        App.Documentable.setProgressBar(data, 'complete')
        App.Documentable.setFilename(data, data.result.filename)
        App.Documentable.clearInputErrors(data)
        $(data.addAttachmentLabel).hide()
        $(data.wrapper).find(".attachment-actions").removeClass('small-12').addClass('small-6 float-right')
        $(data.wrapper).find(".attachment-actions .action-remove").removeClass('small-3').addClass('small-12')

        destroyAttachmentLink = $(data.result.destroy_link)
        $(data.destroyAttachmentLinkContainer).html(destroyAttachmentLink)
        $(destroyAttachmentLink).on 'click', (e) ->
          e.preventDefault()
          e.stopPropagation()
          App.Documentable.doDeleteCachedAttachmentRequest(this.href, data)

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
    data.errorContainer = $(wrapper).find('.attachment-errors')
    data.fileNameContainer = $(wrapper).find('p.file-name')
    data.destroyAttachmentLinkContainer = $(wrapper).find('.action-remove')
    data.addAttachmentLabel = $(wrapper).find('.action-add label')
    data.cachedAttachmentField = $(wrapper).find("input[name$='[cached_attachment]']")
    data.titleField = $(wrapper).find("input[name$='[title]']")
    $(wrapper).find('.progress-bar-placeholder').css('display', 'block')
    return data

  clearFilename: (data) ->
    $(data.fileNameContainer).text('')
    $(data.fileNameContainer).hide()

  clearInputErrors: (data) ->
    $(data.errorContainer).find('small.error').remove()

  clearProgressBar: (data) ->
    $(data.progressBar).find('.loading-bar').removeClass('complete errors uploading').css('width', "0px")

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

  lockUploads: ->
    $('#max-documents-notice').removeClass('hide')
    $('#new_document_link').addClass('hide')

  unlockUploads: ->
    $('#max-documents-notice').addClass('hide')
    $('#new_document_link').removeClass('hide')

  doDeleteCachedAttachmentRequest: (url, data) ->
    $.ajax
      type: "POST"
      url: url
      dataType: "json"
      data: { "_method": "delete" }
      complete: ->
        $(data.cachedAttachmentField).val("")
        $(data.addAttachmentLabel).show()

        App.Documentable.clearFilename(data)
        App.Documentable.clearInputErrors(data)
        App.Documentable.clearProgressBar(data)

        App.Documentable.unlockUploads()
        $(data.wrapper).find(".attachment-actions").addClass('small-12').removeClass('small-6 float-right')
        $(data.wrapper).find(".attachment-actions .action-remove").addClass('small-3').removeClass('small-12')

        if $(data.input).data('nested-document') == true
          $(data.wrapper).remove()
        else
          $(data.wrapper).find('a.remove-cached-attachment').remove()

  initializeRemoveCachedDocumentLink: (input, data) ->
    wrapper = $(input).closest(".direct-upload")
    remove_document_link = $(wrapper).find('a.remove-cached-attachment')
    $(remove_document_link).on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      App.Documentable.doDeleteCachedAttachmentRequest(this.href, data)

  removeDocument: (id) ->
    $('#' + id).remove()
