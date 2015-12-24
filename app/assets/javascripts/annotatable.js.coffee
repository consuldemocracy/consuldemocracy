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

      app = new annotator.App()
        .include ->
          beforeAnnotationCreated: (ann) ->
            ann[ann_type + "_id"] = ann_id
            ann.permissions = ann.permissions || {}
            ann.permissions.admin = []
        .include(annotator.ui.main, { element: this })
        .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })


      app.start().then ->
        app.ident.identity = current_user_id

        options = {}
        options[ann_type + "_id"] = ann_id
        app.annotations.load(options)
