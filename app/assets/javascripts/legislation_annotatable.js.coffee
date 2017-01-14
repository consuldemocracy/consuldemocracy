_t = (key) -> new Gettext().gettext(key)

App.LegislationAnnotatable =

  makeEditableAndHighlight: (colour) ->
    sel = window.getSelection()
    if sel.rangeCount and sel.getRangeAt
      range = sel.getRangeAt(0)
    document.designMode = 'on'
    if range
      sel.removeAllRanges()
      sel.addRange range
    # Use HiliteColor since some browsers apply BackColor to the whole block
    if !document.execCommand('HiliteColor', false, colour)
      document.execCommand 'BackColor', false, colour
    document.designMode = 'off'
    return

  highlight: (colour) ->
    range = undefined
    sel = undefined
    if window.getSelection
      # IE9 and non-IE
      try
        if !document.execCommand('BackColor', false, colour)
          App.LegislationAnnotatable.makeEditableAndHighlight colour
      catch ex
        App.LegislationAnnotatable.makeEditableAndHighlight colour
    else if document.selection and document.selection.createRange
      # IE <= 8 case
      range = document.selection.createRange()
      range.execCommand 'BackColor', false, colour
    return

  remove_highlight: ->
    $('[data-legislation-draft-version-id] span[style]').replaceWith(->
      return $(this).contents()
    )
    return

  renderAnnotationComments: (event) ->
    $('.comment-box').offset(top: event.offset)
    $.ajax
      method: "GET"
      url: event.annotation_url + "/annotations/" + event.annotation_id + "/comments"
      dataType: 'script'

  onClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    App.LegislationAllegations.show_comments()
    $("#comments-box").show()
    $.event.trigger
      type: "renderLegislationAnnotation"
      annotation_id: $(event.target).data("annotation-id")
      annotation_url: $(event.target).closest(".legislation-annotatable").data("legislation-annotatable-base-url")
      offset: $(event.target).offset()["top"]

  viewerExtension: (viewer) ->
    viewer._onHighlightMouseover = (event) ->
      return

  customShow: (position) ->
    $(@element).html ''
    # Clean comments section and open it
    $('#comments-box').html ''
    App.LegislationAllegations.show_comments()
    $('#comments-box').show()

    annotation_url = $('[data-legislation-annotatable-base-url]').data('legislation-annotatable-base-url')
    $.ajax(
      method: 'GET'
      url: annotation_url + '/annotations/new'
      dataType: 'script').done (->
        $('#new_legislation_annotation #legislation_annotation_quote').val(@annotation.quote)
        $('#new_legislation_annotation #legislation_annotation_ranges').val(JSON.stringify(@annotation.ranges))
        $('#comments-box').css({top: $('.annotator-adder').position().top})

        App.LegislationAnnotatable.highlight('#7fff9a')
        $('#comments-box textarea').focus()

        $("#new_legislation_annotation").on("ajax:complete", (e, data, status, xhr) ->
          App.LegislationAnnotatable.remove_highlight()
          $("#comments-box").html("").hide();
          return true
        ).on("ajax:error", (e, data, status, xhr) ->
          console.log(data)
          return false
        )
        return
    ).bind(this)

  editorExtension: (editor) ->
    editor.show = App.LegislationAnnotatable.customShow

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
    $(document).on('click', '[data-annotation-id]', App.LegislationAnnotatable.onClick)
    $(document).on('click', '[data-cancel-annotation]', (e) ->
      e.preventDefault()
      $('#comments-box').html('')
      $('#comments-box').hide()
      App.LegislationAnnotatable.remove_highlight()
      return
    )

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
        .include(annotator.ui.main, { 
          element: this, 
          viewerExtensions: [App.LegislationAnnotatable.viewerExtension],
          editorExtensions: [App.LegislationAnnotatable.editorExtension]
        })
        .include(App.LegislationAnnotatable.scrollToAnchor)
        .include(annotator.storage.http, { prefix: base_url, urls: { search: "/annotations/search" } })

      app.start().then ->
        app.ident.identity = current_user_id

        options = {}
        options["legislation_draft_version_id"] = ann_id
        app.annotations.load(options)
