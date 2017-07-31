App.Documentable =

  initialize: ->
    $('input#document_attachment[type=file]').fileupload

      add: (e, data) ->
        data.progressBar = $('<div class="progress-bar"><div class="loading-bar uploading"></div></div>').insertAfter('#progress-bar')
        options =
          extension: data.files[0].name.match(/(\.\w+)?$/)[0]
          _: Date.now()
        direct_upload_url = $(this).closest('form').data('direct-upload-url')
        console.log direct_upload_url

        fileData = new FormData();
        fileData.append('file', data.fileInput[0].files[0]);

        console.log direct_upload_url

        $.getJSON direct_upload_url, options, (result) ->
          data.formData = result['fields']
          data.url = result['url']
          data.paramName = 'file'
          data.submit()
          return

        # $.ajax
        #   url: direct_upload_url
        #   type: 'POST'
        #   data: fileData
        #   cache: false
        #   contentType: false
        #   processData: false
        #   xhr: ->
        #     console.log 'Progress init'
        #     myXhr = $.ajaxSettings.xhr()
        #     if myXhr.upload
        #       # For handling the progress of the upload
        #       myXhr.upload.addEventListener 'progress', ((e) ->
        #         console.log 'progress listener called'
        #       ), false
        #
        #       myXhr.upload.addEventListener 'complete', ((e) ->
        #         console.log 'complete listener called'
        #         return
        #       ), false
        #     myXhr

      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $('.loading-bar').css 'width', progress + '%'
        return

      done: (e, data) ->
        $('.loading-bar').removeClass 'uploading'
        $('.loading-bar').addClass 'complete'
        image =
          id: data.formData.key
          storage: 'cache'
          metadata:
            size: data.files[0].size
            filename: data.files[0].name.match(/[^\/\\]*$/)[0]
            mime_type: data.files[0].type
        $('#cached_attachment_data').val JSON.stringify(image)
        return