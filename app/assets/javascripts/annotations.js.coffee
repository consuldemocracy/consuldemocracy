legislationSelector =  ".annotate"

annotationsMetadata =  ->
  return {
    beforeAnnotationCreated: (ann) ->
      ann.legislation_id = $(legislationSelector).data("id");
      ann.user_id = $(legislationSelector).data("user-id");
  };

App.annotations =
  initialize: ->
    app = new annotator.App()
      .include(annotator.ui.main, { element: $(legislationSelector)[0] })
      .include(annotator.storage.http, { prefix: "", urls: { search: "/annotations/search" } })
      .include(annotationsMetadata)

    app.start()
      .then( ->
        app.annotations.load( { legislation_id: $(legislationSelector).data("id") } )
      )