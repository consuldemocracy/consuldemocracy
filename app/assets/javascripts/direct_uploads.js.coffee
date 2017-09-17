App.DirectUploads =

  progressBarTemplate: '<div class="progress-bar"><div class="loading-bar uploading"></div></div>'

  buildData: (e, data) ->
    wrapper = $(e.target).closest('.direct-upload')
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

  remove_cached_attachment: (e, data) ->
    e.preventDefault()
    e.stopPropagation()
    $.ajax
      type: "POST"
      url: e.target.href
      dataType: "json"
      data: {"_method":"delete"}
      complete: ->
         console.log data
        $(data.cachedAttachmentField).val("")
        $(data.addAttachmentLabel).show()
        $(data.destroyAttachmentLinkContainer).find('a.delete').remove()
        $(data.fileNameContainer).text('')
        $(data.fileNameContainer).hide()
        $(data.errorContainer).find('small.error').remove()
        $(data.progressBar).find('.loading-bar').removeClass('complete errors uploading').css('width', "0px").css('display', "none")
        $(data.wrapper).find(".image-preview").remove()
        $(data.preview).html('')

  initialize: ->

    $('.action-remove a.delete').on 'click', (e) ->
      data = App.DirectUploads.buildData(e, [])
      App.DirectUploads.remove_cached_attachment(e, data)
      $(data.wrapper).find('small.error').remove()
      $(data.wrapper).find('label.error').removeClass('error')

    $('input.direct_upload_attachment[type=file]').fileupload

      paramName: "attachment"

      formData: null

      add: (e, data) ->
        data = App.DirectUploads.buildData(e, data)
        data.submit()

      change: (e, data) ->
        $.each data.files, (index, file) ->
          $(e.target).closest('.direct-upload').find('p.file-name').text(file.name)
          $(e.target).closest('.direct-upload').find('p.file-name').show()

      fail: (e, data) ->
        $(data.cachedAttachmentField).val("")
        $(data.progressBar).find('.loading-bar').addClass('errors')
        $(data.errorContainer).find('small.error').remove()
        $(data.errorContainer).append('<small class="error">' + data.jqXHR.responseJSON.errors + '</small>')
        $(data.fileNameContainer).text('')
        $(data.fileNameContainer).hide()
        $(data.destroyAttachmentLinkContainer).find("a.delete").remove()
        $(data.addAttachmentLabel).show()
        $(data.wrapper).find(".image-preview").remove()

      done: (e, data) ->
        $(data.cachedAttachmentField).val(data.result.cached_attachment)
        if $(data.titleField).val() == ""
          $(data.titleField).val(data.result.filename)
        $(data.progressBar).find('.loading-bar').addClass('complete')
        $(data.fileNameContainer).text(data.result.filename)
        $(data.fileNameContainer).show()
        $(data.errorContainer).find('small.error').remove()
        $(data.destroyAttachmentLinkContainer).html(data.result.destroy_link)
        data.destroyAttachmentLinkContainer = $(data.wrapper).find('.action-remove')
        $(data.addAttachmentLabel).hide()
        if data.result.is_image
          image = '<div class="small-12 column text-center image-preview"><figure><img src="' + data.result.attachment_url + '" class="cached-image"/></figure></div>'
          if $('.image-preview').length > 0
            $('.image-preview').replaceWith(image)
          else
            $(image).insertBefore($(data.wrapper).find(".attachment-actions"))

        $(data.destroyAttachmentLinkContainer).on 'click', (e) ->
          App.DirectUploads.remove_cached_attachment(e, data)


      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $(data.progressBar).find('.loading-bar').css 'width', progress + '%'
        return