(function() {
  "use strict";
  App.Sortable = {
    initialize: function() {
      $(".sortable").sortable({
        update: function() {
          var new_order;
          new_order = $(this).sortable("toArray", {
            attribute: "data-answer-id"
          });
          $.ajax({
            url: $(".sortable").data("js-url"),
            data: {
              ordered_list: new_order
            },
            type: "POST"
          });
        }
      });
    }
  };
}).call(this);
