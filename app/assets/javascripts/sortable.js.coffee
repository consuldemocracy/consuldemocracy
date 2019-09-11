App.Sortable =
  initialize: ->
    $(".sortable").sortable
      update: ->
        new_order = $(this).sortable("toArray", { attribute: "data-answer-id" })
        $.ajax
          url: $(".sortable").data("js-url"),
          data: { ordered_list: new_order },
          type: "POST"

    $(".sortable-priotirized-votation").sortable
      update: ->
        new_order = $(this).sortable("toArray", { attribute: "data-answer-id" })
        $.ajax
          url: $(this).data("js-url"),
          data: { ordered_list: new_order },
          type: "POST"
