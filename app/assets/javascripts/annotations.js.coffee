proposalSelector =  ".proposal-show"

proposalId =  ->
  return {
    beforeAnnotationCreated: (ann) ->
      ann.proposal_id = $(proposalSelector).data("id")
  };

App.annotations =
  initialize: ->
    app = new annotator.App()
      .include(annotator.ui.main, { element: $(proposalSelector)[0] })
      .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })
      .include(proposalId)

    app.start()
      .then( ->
        app.annotations.load( { proposal_id: $(proposalSelector).data("id") } )
      )