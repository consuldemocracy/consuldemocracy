App.MarkdownEditor =

  refresh_preview: (element, md) ->
    textarea_content = App.MarkdownEditor.find_textarea(element).val()
    result = md.render(textarea_content)
    element.find('#markdown-preview').html(result)

  # Multi-locale (translatable) form fields work by hiding inputs of locales
  # which are not "active".
  find_textarea: (editor) ->
    editor.find('textarea:visible')

  initialize: ->
    $('.markdown-editor').each ->
      md = window.markdownit({
        html: true,
        breaks: true,
        typographer: true,
      })

      editor = $(this)

      editor.on 'input', ->
        App.MarkdownEditor.refresh_preview($(this), md)
        $('.legislation-draft-versions-edit .warning').show()
        return

      editor.find('textarea').on 'scroll', ->
        $('#markdown-preview').scrollTop($(this).scrollTop())

      editor.find('.fullscreen-toggle').on 'click', ->
        editor.toggleClass('fullscreen')
        $('.fullscreen-container').toggleClass('medium-8', 'medium-12')
        span = $(this).find('span')
        current_html = span.html()
        if(current_html == span.data('open-text'))
          span.html(span.data('closed-text'))
        else
          span.html(span.data('open-text'))

        if editor.hasClass('fullscreen')
          App.MarkdownEditor.find_textarea(editor).height($(window).height() - 100)
          App.MarkdownEditor.refresh_preview(editor, md)
        else
          App.MarkdownEditor.find_textarea(editor).height("10em")
