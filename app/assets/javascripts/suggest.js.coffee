App.Suggest =

  initialize: ->

    $('[data-js-suggest-result]').each ->

      $this = $(this)

      callback = ->
        $.ajax
          url: $this.data('js-url')
          data: {search: $this.val()},
          type: 'GET',
          dataType: 'html'
          success: (stHtml) ->
            js_suggest_selector = $this.data('js-suggest')
            $(js_suggest_selector).html(stHtml)

      $this.on 'keyup', ->
        window.clearTimeout(callback)
        window.setTimeout(callback, 1000)

      $this.on 'change', callback
