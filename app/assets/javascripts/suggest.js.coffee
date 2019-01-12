App.Suggest =

  initialize: ->

    $("[data-js-suggest-result]").each ->

      $this = $(this)

      callback = ->
        $.ajax
          url: $this.data("js-url")
          data:
            search: $this.val()
          type: "GET"
          dataType: "html"
          success: (stHtml) ->
            js_suggest_selector = $this.data("js-suggest")
            if js_suggest_selector.startsWith(".")
              locale = $this.closest(".translatable-fields").data("locale")
              js_suggest_selector += "[data-locale=#{locale}]"
            $(js_suggest_selector).html(stHtml)

      timer = null

      $this.on "keyup", ->
        window.clearTimeout(timer)
        timer = window.setTimeout(callback, 1000)

      $this.on "change", callback
