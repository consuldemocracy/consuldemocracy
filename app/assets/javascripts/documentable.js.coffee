App.Documentable =

  initialize: ->

    $('input.document_ajax_attachment[type=file]').fileupload

      paramName : "document[attachment]"

      formData: null

      add: (e, data) ->
        wrapper = $(e.target).parent()
        $(wrapper).find('.progress-bar-placeholder').empty()
        data.progressBar = $(wrapper).find('.progress-bar-placeholder').html('<div class="progress-bar"><div class="loading-bar uploading"></div></div>')
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

      done: (e, data) ->
        result = data.response().result
        if result.status == 200
          $(data.progressBar).find('.loading-bar').removeClass 'uploading'
          $(data.progressBar).find('.loading-bar').addClass 'complete'
          inputId = '#' + $(e.target).data('cached-attachment-input-field')
          $(inputId).val result.attachment
        else
          $(data.progressBar).find('.loading-bar').addClass 'errors'
          $(data.progressBar).prepend("<span>" + result.msg + "</span>")
        return

