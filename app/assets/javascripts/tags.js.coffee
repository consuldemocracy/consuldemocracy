App.Tags =

  initialize: ->
    $tag_input = $("input.js-tag-list")

    $("body .js-add-tag-link").each ->
      $this = $(this)

      unless $this.data("initialized") is "yes"
        $this.on("click", ->
          name = "\"#{$(this).text()}\""
          current_tags = $tag_input.val().split(",").filter(Boolean)

          if current_tags.indexOf(name) >= 0
            current_tags.splice(current_tags.indexOf(name), 1)
          else
            current_tags.push name

          $tag_input.val(current_tags.join(","))
          false
        ).data "initialized", "yes"
