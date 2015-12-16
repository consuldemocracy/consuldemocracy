App.Annotable =
  initialize: ->
    $("[data-annotable-type]").each ->
      $this       = $(this)
      ann_type    = $this.data("annotable-type")
      ann_id      = $this.data("annotable-id")

      app = new annotator.App()
        .include(annotator.ui.main, { element: this })
        .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })
        .include ->
          beforeAnnotationCreated: (ann) ->
            ann[ann_type + "_id"] = ann_id

      app.start().then ->
        app.ident.identity = $('html').data('current-user-id')

        options = {}
        options[ann_type + "_id"] = ann_id
        app.annotations.load(options)
