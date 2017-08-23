App.Documentable =

  initialize: ->
    @initializeDirectUploads()
    @initializeInterface()

  initializeDirectUploads: ->

    $('input.document_ajax_attachment[type=file]').fileupload

      paramName: "document[attachment]"

      formData: null

      add: (e, data) ->
        wrapper = $(e.target).parent()
        index = $(e.target).data('index')
        $(wrapper).find('.progress-bar-placeholder').empty()
        data.progressBar = $(wrapper).find('.progress-bar-placeholder').html('<div class="progress-bar"><div class="loading-bar uploading"></div></div>')
        data.formData = {
          "document[title]": $(wrapper).find('input.document-title').val() || data.files[0].name
          "index": index
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
    input_files = $('input.document_ajax_attachment[type=file]')

    $.each input_files, (index, file) ->
      wrapper = $(file).parent()
      App.Documentable.watchRemoveDocumentbutton(wrapper)

  watchRemoveDocumentbutton:  (wrapper) ->
    remove_document_button = $(wrapper).find('.remove-document')
    $(remove_document_button).on 'click', (e) ->
      e.preventDefault()
      $(wrapper).remove()
      $('#new_document_link').show()
      $('.max-documents-notice').hide()

  upload: (id, nested_document, result) ->
    $('#' + id).replaceWith(nested_document)
    if result
      $('#' + id).find('.loading-bar').addClass 'complete'
    else
      $('#' + id).find('.loading-bar').addClass 'errors'
    @initialize()

  new: (nested_fields) ->
    $(".documents-list").append(nested_fields)
    @initialize()

  destroy: (id, notice) ->
    $('#' + id).remove()
    @updateNotice(notice)

  updateNotice: (notice) ->
    if $('[data-alert]').length > 0
      $('[data-alert]').replaceWith(notice)
    else
      $("body").append(notice)

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
