_t = (key) -> new Gettext().gettext(key)

App.LegislationAnnotatable =

  renderAnnotationComments: (event) ->
    $('.comment-box').offset(top: event.offset)
    $.ajax
      method: "GET"
      url: event.annotation_url + "/annotations/" + event.annotation_id + "/comments"
      dataType: 'script'

  viewerExtension: (viewer) ->
    viewer._onHighlightMouseover = (event) ->
      App.LegislationAllegations.show_comments()
      $.event.trigger
        type: "renderLegislationAnnotation"
        annotation_id: $(event.target).data("annotation-id")
        annotation_url: $(event.target).closest(".legislation-annotatable").data("legislation-annotatable-base-url")
        offset: $(event.target).offset()["top"]



  scrollToAnchor: ->
    annotationsLoaded: (annotations) ->
      if anchor = $(location).attr('hash')
        ann_id = anchor.split("-")[-1..]
        el = $("span[data-annotation-id='" + ann_id + "']")
        App.LegislationAllegations.show_comments()
        $('html,body').animate({scrollTop: el.offset().top})
        $.event.trigger
          type: "renderLegislationAnnotation"
          annotation_id: ann_id
          annotation_url: el.closest(".legislation-annotatable").data("legislation-annotatable-base-url")
          offset: el.offset()["top"]

  initialize: ->
    $(document).on("renderLegislationAnnotation", App.LegislationAnnotatable.renderAnnotationComments)

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
        .include(annotator.ui.main, { element: this, viewerExtensions: [App.LegislationAnnotatable.viewerExtension] })
        .include(App.LegislationAnnotatable.scrollToAnchor)
        .include(annotator.storage.http, { prefix: base_url, urls: { search: "/annotations/search" } })

      app.start().then ->
        app.ident.identity = current_user_id

        options = {}
        options["legislation_draft_version_id"] = ann_id
        app.annotations.load(options)
