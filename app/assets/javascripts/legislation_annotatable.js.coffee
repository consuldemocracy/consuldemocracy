_t = (key) -> new Gettext().gettext(key)

App.LegislationAnnotatable =
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

    $(".legislation-annotatable").each ->
      $this          = $(this)
      ann_type       = "legislation_draft_version"
      ann_id         = $this.data("legislation-draft-version-id")
      base_url       = $this.data("legislation-annotatable-base-url")

      app = new annotator.App()
        .include ->
          beforeAnnotationCreated: (ann) ->
            ann["legislation_draft_version_id"] = ann_id
            ann.permissions = ann.permissions || {}
            ann.permissions.admin = []
        .include(annotator.ui.main, { element: this })
        .include(annotator.storage.http, { prefix: base_url, urls: { search: "/annotations/search" } })

      app.start().then ->
        app.ident.identity = current_user_id

        options = {}
        options["legislation_draft_version_id"] = ann_id
        app.annotations.load(options)
