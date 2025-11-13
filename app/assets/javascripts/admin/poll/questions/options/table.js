(function() {
  "use strict";
  App.AdminPollQuestionOptionsTable = {
    initialize: function() {
      $(".poll-question-options-table tbody").sortable({
        update: function() {
          var new_order;
          new_order = $(this).sortable("toArray", {
            attribute: "data-option-id"
          });
          $.ajax({
            url: $(this).data("js-url"),
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
