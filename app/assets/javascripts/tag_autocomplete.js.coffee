App.TagAutocomplete =

  split: ( val ) ->
    return (val.split( /,\s*/ ))

  extractLast: ( term ) ->
    return (App.TagAutocomplete.split( term ).pop())

  init_autocomplete: ->
    $('.js-tag-list').autocomplete
      source: (request, response) ->
        response( $.ui.autocomplete.filter(["Arbol", "Becerro", "Caracol"], App.TagAutocomplete.extractLast( request.term ) ) );
      minLength: 0,
      search: ->
        console.log(this.value);
        console.log(App.TagAutocomplete.extractLast( this.value ));
        App.TagAutocomplete.extractLast( this.value );
      focus: ->
        return false;
      select: ( event, ui ) -> (
        terms = App.TagAutocomplete.split( this.value );
        terms.pop();
        terms.push( ui.item.value );
        terms.push( "" );
        this.value = terms.join( ", " );
        return false;);

  initialize: ->
    App.TagAutocomplete.init_autocomplete();