App.Documentable =

  initialize: ->
    inputFiles = $('input.js-document-attachment[type=file]')

    $.each inputFiles, (index, input) ->
      App.Documentable.initializeDirectUploadInput(input)

  initializeDirectUploadInput: (input) ->

    inputData = @buildData([], input)

    @initializeRemoveDocumentLink(input)

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

        if $(data.input).data('nested-document') == true
          $(data.wrapper).remove()
          $('#new_document_link').show()
          $('.max-documents-notice').hide()
        else
          $(data.destroyAttachmentLinkContainer).find('a.delete').remove()

  initializeRemoveDocumentLink: (input) ->
    wrapper = $(input).closest(".direct-upload")
    remove_document_link = $(wrapper).find('a.remove-nested-field')
    $(remove_document_link).on 'click', (e) ->
      e.preventDefault()
      $(wrapper).remove()
      $('#new_document_link').show()
      $('.max-documents-notice').hide()

  initializeRemoveCachedDocumentLink: (input, data) ->
    wrapper = $(input).closest(".direct-upload")
    remove_document_link = $(wrapper).find('a.remove-cached-attachment')
    $(remove_document_link).on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      App.Documentable.doDeleteCachedAttachmentRequest(this.href, data)

  new: (nested_field) ->
    nested_field = $(nested_field)
    $(".documents-list").append(nested_field)
    input = nested_field.find("input[type='file']")
    @initializeDirectUploadInput(input)

  destroyNestedDocument: (id) ->
    $('#' + id).remove()

  updateNewDocumentButton: (link) ->
    if $('.document').length >= $('.documents').data('max-documents')
      $('#new_document_link').hide()
      $('.max-documents-notice').removeClass('hide')
      $('.max-documents-notice').show()
    else if $('#new_document_link').length > 0
      $('#new_document_link').replaceWith(link)
      $('.max-documents-notice').hide()
    else
      $('.max-documents-notice').hide()
      $(link).insertBefore('.documents hr:last')
