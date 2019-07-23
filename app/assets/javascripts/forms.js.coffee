App.Forms =

  disableEnter: ->
    $("form.js-enter-disabled").on("keyup keypress", (event) ->
      if event.which == 13
        e.preventDefault()
    )

  submitOnChange: ->
    $(".js-submit-on-change").unbind("change").on("change", ->
      $(this).closest("form").submit()
      false
    )

  toggleLink: ->
    $(".js-toggle-link").unbind("click").on("click", ->
      $($(this).data("toggle-selector")).toggle("down")
      if $(this).data("toggle-text") isnt undefined
        toggle_txt = $(this).text()
        $(this).text( $(this).data("toggle-text")  )
        $(this).data("toggle-text", toggle_txt)

      false
    )

  synchronizeInputs: ->
    progress_bar = "[name='progress_bar[percentage]']"
    process_background = "[name='legislation_process[background_color]']"
    process_font = ", [name='legislation_process[font_color]']"
    processes = process_background + process_font
    banners = "[name='banner[background_color]'], [name='banner[font_color]']"

    inputs = $("#{progress_bar}, #{processes}, #{banners}")
    inputs.on
      input: ->
        $("[name='#{this.name}']").val($(this).val())

    inputs.trigger("input")

  hideOrShowFieldsAfterSelection: ->
    $("[name='progress_bar[kind]']").on
      change: ->
        locale = App.Globalize.selected_language()
        title_field = $(".translatable-fields[data-locale=#{locale}]")

        if this.value == "primary"
          title_field.hide()
          $(".globalize-languages").hide()
        else
          title_field.show()
          $(".globalize-languages").show()

    $("[name='progress_bar[kind]']").change()

  initialize: ->
    App.Forms.disableEnter()
    App.Forms.submitOnChange()
    App.Forms.toggleLink()
    App.Forms.synchronizeInputs()
    App.Forms.hideOrShowFieldsAfterSelection()
    false
