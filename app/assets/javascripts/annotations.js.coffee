proposalSelector =  ".proposal-show"

proposalId =  ->
  return {
    beforeAnnotationCreated: (ann) ->
      ann.proposal_id = $(proposalSelector).data("id")
  };

App.annotations =
  initialize: ->
    new annotator.App()
      .include(annotator.ui.main, {element: $(proposalSelector)[0]})
      .include(annotator.storage.http, {id: 1, prefix: ""})
      .include(proposalId)
      .start();