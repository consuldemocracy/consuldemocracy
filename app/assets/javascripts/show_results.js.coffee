App.ShowResults =
  show: (ajax_show, ajax_url, query) ->
    $.ajax
      url: ajax_url,
      data: {search: query},
      type: 'GET',
      dataType: 'html'
      success: (stHtml) ->
        $(ajax_show).html(stHtml)
      error: (xhr, status) ->
      complete: (xhr, status) ->

  initialize: ->
    $('[data-ajax-target]').on('blur',(event) ->
      App.ShowResults.show($(this).data('ajax-show'), $(this).data('ajax-url'), $(this).val()) )