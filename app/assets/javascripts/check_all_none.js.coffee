App.CheckAllNone =

  initialize: ->
    $('[data-check-all]').on 'click', ->
      target_name = $(this).data('check-all')
      $("[name='" + target_name + "']").prop('checked', true)

    $('[data-check-none]').on 'click', ->
      target_name = $(this).data('check-none')
      $("[name='" + target_name + "']").prop('checked', false)



