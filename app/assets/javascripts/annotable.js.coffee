App.Annotable =
  initialize: ->
    $("[data-annotable-type]").each ->
      $this       = $(this)
      ann_type    = $this.data("annotable-type")
      ann_id      = $this.data("annotable-id")
      ann_user_id = $this.data("annotable-user-id")

      app = new annotator.App()
        .include(annotator.ui.main, { element: this })
        .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })
        .include ->
          beforeAnnotationCreated: (ann) ->
            ann[ann_type + "_id"] = ann_id
            ann.user_id           = ann_user_id

      app.start().then ->
        options = {}
        options[ann_type + "_id"] = ann_id
        app.annotations.load(options)
