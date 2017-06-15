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
    if event.offset
      $("#comments-box").css({top: event.offset - $('.calc-comments').offset().top})

    if App.LegislationAnnotatable.isMobile()
      return

    $.ajax
      method: "GET"
      url: event.annotation_url + "/annotations/" + event.annotation_id + "/comments"
      dataType: 'script'

  onClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    if App.LegislationAnnotatable.isMobile()
      annotation_url = $(event.target).closest(".legislation-annotatable").data("legislation-annotatable-base-url")
      window.location.href = annotation_url + "/annotations/" + $(this).data('annotation-id')
      return

    $('[data-annotation-id]').removeClass('current-annotation')

    target = $(this)

    parents = target.parents('.annotator-hl')
    parents_ids = parents.map (_, elem) ->
      $(elem).data("annotation-id")

    annotation_id = target.data('annotation-id')
    $('[data-annotation-id="' + annotation_id + '"]').addClass('current-annotation')

    $('#comments-box').html('')
    App.LegislationAllegations.show_comments()
    $("#comments-box").show()

    $.event.trigger
      type: "renderLegislationAnnotation"
      annotation_id: target.data("annotation-id")
      annotation_url: target.closest(".legislation-annotatable").data("legislation-annotatable-base-url")
      offset: target.offset()["top"]

    parents_ids.each (i, pid) ->
      $.event.trigger
        type: "renderLegislationAnnotation"
        annotation_id: pid
        annotation_url: target.closest(".legislation-annotatable").data("legislation-annotatable-base-url")

  isMobile: ->
    return window.innerWidth <= 652

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
        $('#comments-box').css({top: position.top - $('.calc-comments').offset().top})

        unless  $('[data-legislation-open-phase]').data('legislation-open-phase') == false
          App.LegislationAnnotatable.highlight('#7fff9a')
          $('#comments-box textarea').focus()

          $("#new_legislation_annotation").on("ajax:complete", (e, data, status, xhr) ->
            App.LegislationAnnotatable.app.destroy()
            if data.status == 200
              App.LegislationAnnotatable.remove_highlight()
              $("#comments-box").html("").hide()
              $.ajax
                method: "GET"
                url: annotation_url + "/annotations/" + data.responseJSON.id + "/comments"
                dataType: 'script'
            else
              $(e.target).find('label').addClass('error')
              $('<small class="error">' + data.responseJSON[0] + '</small>').insertAfter($(e.target).find('textarea'))
            return true
          )
        return
    ).bind(this)

  editorExtension: (editor) ->
    editor.show = App.LegislationAnnotatable.customShow

  scrollToAnchor: ->
    annotationsLoaded: (annotations) ->
      anchor = $(location).attr('hash')
      if anchor && anchor.startsWith('#annotation')
        ann_id = anchor.split("-")[-1..]

        checkExist = setInterval((->
          if $("span[data-annotation-id='" + ann_id + "']").length
            el = $("span[data-annotation-id='" + ann_id + "']")
            el.addClass('current-annotation')
            $('#comments-box').html('')
            App.LegislationAllegations.show_comments()
            $('html,body').animate({scrollTop: el.offset().top})
            $.event.trigger
              type: "renderLegislationAnnotation"
              annotation_id: ann_id
              annotation_url: el.closest(".legislation-annotatable").data("legislation-annotatable-base-url")
              offset: el.offset()["top"]
            clearInterval checkExist
          return
        ), 100)

  propotionalWeight: (v, max) ->
    Math.floor(v * 5 / (max + 1)) + 1

  addWeightClasses: ->
    annotationsLoaded: (annotations) ->
      return if annotations.length == 0
      weights = annotations.map (ann) -> ann.weight
      max_weight = Math.max.apply(null, weights)
      last_annotation = annotations[annotations.length - 1]

      checkExist = setInterval((->
        if $("span[data-annotation-id='" + last_annotation.id + "']").length
          for annotation in annotations
            ann_weight = App.LegislationAnnotatable.propotionalWeight(annotation.weight, max_weight)
            el = $("span[data-annotation-id='" + annotation.id + "']")
            el.addClass('weight-' + ann_weight)
          clearInterval checkExist
        return
      ), 100)

  initialize: ->
    $(document).off("renderLegislationAnnotation").on("renderLegislationAnnotation", App.LegislationAnnotatable.renderAnnotationComments)
    $(document).off('click', '[data-annotation-id]').on('click', '[data-annotation-id]', App.LegislationAnnotatable.onClick)
    $(document).off('click', '[data-cancel-annotation]').on('click', '[data-cancel-annotation]', (e) ->
      e.preventDefault()
      $('#comments-box').html('')
      $('#comments-box').hide()
      App.LegislationAnnotatable.remove_highlight()
      return
    )

    current_user_id = $('html').data('current-user-id')

    $(".legislation-annotatable").each ->
      $this          = $(this)
      ann_type       = "legislation_draft_version"
      ann_id         = $this.data("legislation-draft-version-id")
      base_url       = $this.data("legislation-annotatable-base-url")

      App.LegislationAnnotatable.app = new annotator.App()
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
        .include(App.LegislationAnnotatable.addWeightClasses)
        .include(annotator.storage.http, { prefix: base_url, urls: { search: "/annotations/search" } })

      App.LegislationAnnotatable.app.start().then ->
        App.LegislationAnnotatable.app.ident.identity = current_user_id

        options = {}
        options["legislation_draft_version_id"] = ann_id
        App.LegislationAnnotatable.app.annotations.load(options)
