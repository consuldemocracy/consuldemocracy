App.Suggest =

  initialize: ->
    $('[data-js-suggest-result]').on('blur',(event) ->
 
      js_suggest = $(this).data('js-suggest')
       
      $.ajax
        url: $(this).data('js-url')
        data: {search: $(this).val()},
        type: 'GET',
        dataType: 'html'
        success: (stHtml) ->
          $(js_suggest).html(stHtml)
        error: (xhr, status) ->
        complete: (xhr, status) ->) 
