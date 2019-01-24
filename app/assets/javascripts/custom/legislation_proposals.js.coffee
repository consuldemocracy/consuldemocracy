App.LegislationProposals =
  checkProposalType: ->
    switch ($("#legislation_proposal_proposal_type").val())
      when 'proposal'
        $("#js-legislation-proposal-summary").show()
        $("#js-legislation-proposal-video-url").show()
        $(".js-legislation-proposal-documents").show()
        $("#js-legislation-proposal-geozone").show()
        $("#js-legislation-proposal-tags").show()
        $("#js-legislation-proposal-label-description").show()
        $("#js-legislation-proposal-label-question-description").hide()
      when 'question'
        $("#js-legislation-proposal-summary").hide()
        $("#js-legislation-proposal-video-url").hide()
        $("#js-legislation-proposal-documents").hide()
        $("#js-legislation-proposal-geozone").hide()
        $("#js-legislation-proposal-tags").hide()
        $("#js-legislation-proposal-label-description").hide()
        $("#js-legislation-proposal-label-question-description").show()
  initialize: ->
    $ ->
      App.LegislationProposals.checkProposalType()

    $("#legislation_proposal_proposal_type").on change: ->
      App.LegislationProposals.checkProposalType()
