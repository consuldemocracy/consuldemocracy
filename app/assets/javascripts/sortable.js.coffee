App.Sortable =
  initialize: ->
    $(".sortable").sortable
      update: (event, ui) ->
        new_order = $(this).sortable('toArray', {attribute: 'data-answer-id'});
        $.ajax
          url: $('.sortable').data('js-url'),
          data: {ordered_list: new_order},
          type: 'POST'
