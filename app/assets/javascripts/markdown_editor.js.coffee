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
        return

      $(this).find('.fullscreen-toggle').on 'click', ->
        $('.markdown-editor').toggleClass('fullscreen')

        if $('.markdown-editor').hasClass('fullscreen')
          $('.markdown-editor textarea').height($(window).height() - 100)
        else
          $('.markdown-editor textarea').height("10em")

