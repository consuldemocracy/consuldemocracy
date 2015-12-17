App.Annotatable =
  initialize: ->
    $("[data-annotatable-type]").each ->
      $this       = $(this)
      ann_type    = $this.data("annotatable-type")
      ann_id      = $this.data("annotatable-id")

      app = new annotator.App()
        .include ->
          beforeAnnotationCreated: (ann) ->
            ann[ann_type + "_id"] = ann_id
            ann.permissions = ann.permissions || {}
            ann.permissions.admin = []
        .include(annotator.ui.main, { element: this })
        .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })


      app.start().then ->
        app.ident.identity = $('html').data('current-user-id')

        options = {}
        options[ann_type + "_id"] = ann_id
        app.annotations.load(options)
