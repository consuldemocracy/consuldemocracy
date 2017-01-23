App.MarkdownEditor =

  refresh_preview: (element, md) ->
    textarea_content = element.find('textarea').val()
    result = md.render(textarea_content)
    element.find('#markdown-preview').html(result)

  initialize: ->
    $('.markdown-editor').each ->
      md = window.markdownit({
        html: true,
        breaks: true,
        typographer: true,
      })

      App.MarkdownEditor.refresh_preview($(this), md)

      $(this).on 'change input paste keyup', ->
        App.MarkdownEditor.refresh_preview($(this), md)
        $('.legislation-draft-versions-edit .warning').show()
        return

      $(this).find('textarea').on 'scroll', ->
        $('#markdown-preview').scrollTop($(this).scrollTop())

      $(this).find('.fullscreen-toggle').on 'click', ->
        $('.markdown-editor').toggleClass('fullscreen')
        $('.fullscreen-container').toggleClass('medium-8', 'medium-12')
        span = $(this).find('span')
        current_html = span.html()
        if(current_html == span.data('open-text'))
          span.html(span.data('closed-text'))
        else
          span.html(span.data('open-text'))

        if $('.markdown-editor').hasClass('fullscreen')
          $('.markdown-editor textarea').height($(window).height() - 100)
        else
          $('.markdown-editor textarea').height("10em")
