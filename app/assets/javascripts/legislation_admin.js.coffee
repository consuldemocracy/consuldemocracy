App.LegislationAdmin =

  initialize: ->
    $("input[type='checkbox'][data-disable-date]").on
      change: ->
        checkbox = $(this)
        parent = $(this).parents('.row:eq(0)')
        date_selector = $(this).data('disable-date')
        parent.find("input[type='text'][id^='" + date_selector + "']").each ->
          if checkbox.is(':checked')
            $(this).removeAttr("disabled")
          else
            $(this).val("")

    $("#nested-question-options").on "cocoon:after-insert", ->
      App.Globalize.refresh_visible_translations()
