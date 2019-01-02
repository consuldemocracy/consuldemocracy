App.LegislationAdmin =

  update_background_color: (selector, text_selector, background_color) ->
    $(selector).css('background-color', background_color);
    $(text_selector).val(background_color);

  update_font_color: (selector, text_selector, font_color) ->
    $(selector).css('color', font_color);
    $(text_selector).val(font_color);

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

    $("#nested_question_options").on "cocoon:after-insert", ->
      App.Globalize.refresh_visible_translations()

    #banner colors for proccess header

    $("#legislation_process_background_color_picker").on
      change: ->
        App.LegislationAdmin.update_background_color("#js-legislation_process-background", "#legislation_process_background_color", $(this).val());

    $("#legislation_process_background_color").on
      change: ->
        App.LegislationAdmin.update_background_color("#js-legislation_process-background", "#legislation_process_background_color_picker", $(this).val());

    $("#legislation_process_font_color_picker").on
      change: ->
        App.LegislationAdmin.update_font_color("#js-legislation_process-title", "#legislation_process_font_color", $(this).val());
        App.LegislationAdmin.update_font_color("#js-legislation_process-description", "#legislation_process_font_color", $(this).val());

    $("#legislation_process_font_color").on
      change: ->
        App.LegislationAdmin.update_font_color("#js-legislation_process-title", "#legislation_process_font_color_picker", $(this).val());
        App.LegislationAdmin.update_font_color("#js-legislation_process-description", "#legislation_process_font_color_picker", $(this).val());
