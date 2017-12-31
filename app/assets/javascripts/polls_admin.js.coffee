App.PollsAdmin =

  initialize: ->
    $("select[class='js-poll-shifts']").on
      change: ->
        switch ($(this).val())
          when 'vote_collection'
            $("select[class='js-shift-vote-collection-dates']").show();
            $("select[class='js-shift-recount-scrutiny-dates']").hide();
          when 'recount_scrutiny'
            $("select[class='js-shift-recount-scrutiny-dates']").show();
            $("select[class='js-shift-vote-collection-dates']").hide();
