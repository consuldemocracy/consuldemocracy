_t = (key) -> new Gettext().gettext(key)

App.Annotatable =
  initialize: ->
    current_user_id = $('html').data('current-user-id')
    if current_user_id == ""
      annotator.ui.editor.Editor.template = [
        '<div class="annotator-outer annotator-editor annotator-hide">',
        '  <form class="annotator-widget">',
        '    ' + _t('Unregistered'),
        '    <div class="annotator-controls">',
        '      <a href="#cancel" class="annotator-cancel">' + _t('Cancel') + '</a>',
        '    </div>',
        '  </form>',
        '</div>'
      ].join('\n')

    $("[data-annotatable-type]").each ->
      $this       = $(this)
      ann_type    = $this.data("annotatable-type")
      ann_id      = $this.data("annotatable-id")
      readonly    = $this.data("annotatable-readonly")

      app = new annotator.App()
        .include ->
          beforeAnnotationCreated: (ann) ->
            ann[ann_type + "_id"] = ann_id
            ann.permissions = ann.permissions || {}
            ann.permissions.admin = []
        .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })

      if readonly
        element = this
        app.include(->
          ui = {}
          {
            start: ->
              ui.highlighter = new (annotator.ui.highlighter.Highlighter)(element)
              ui.viewer = new (annotator.ui.viewer.Viewer)(
                permitEdit: (ann) -> false
                permitDelete: (ann) -> false
                autoViewHighlights: element)
              ui.viewer.attach()

            destroy: ->
              ui.highlighter.destroy()
              ui.viewer.destroy()

            annotationsLoaded: (anns) ->
              ui.highlighter.drawAll anns
           }
        )
      else
        app.include(annotator.ui.main, { element: this })

      app.start().then ->
        unless readonly
          app.ident.identity = current_user_id

        options = {}
        options[ann_type + "_id"] = ann_id
        app.annotations.load(options)
