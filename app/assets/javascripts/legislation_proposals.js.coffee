App.LegislationProposals =
  checkProposalType: ->
    switch ($("#legislation_proposal_proposal_type").val())
      when 'proposal'
        $("#js-legislation-proposal-summary").show()
        $("#js-legislation-proposal-video-url").show()
        $(".js-legislation-proposal-documents").show()
        $("#js-legislation-proposal-geozone").show()
        $("#js-legislation-proposal-tags").show()
      when 'question'
        $("#js-legislation-proposal-summary").hide()
        $("#js-legislation-proposal-video-url").hide()
        $("#js-legislation-proposal-documents").hide()
        $("#js-legislation-proposal-geozone").hide()
        $("#js-legislation-proposal-tags").hide()
  initialize: ->
    $ ->
      App.LegislationProposals.checkProposalType()

    $("#legislation_proposal_proposal_type").on change: ->
      App.LegislationProposals.checkProposalType()
