App.ModalDownload =

  enableButton: ->
    $("#js-download-modal-submit").attr("disabled", false)
    $("#js-download-modal-submit").removeClass('disabled')

  initialize: ->
    $("#js-download-modal-submit").on "click", ->
      setTimeout(App.ModalDownload.enableButton, 2000)
