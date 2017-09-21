App.TagAutocomplete =

  split: ( val ) ->
    return (val.split( /,\s*/ ))

  extractLast: ( term ) ->
    return (App.TagAutocomplete.split( term ).pop())

  init_autocomplete: ->
    $('.tag-autocomplete').autocomplete
      source: (request, response) ->
        $.ajax
          url: $('.tag-autocomplete').data('js-url'),
          data: {search: App.TagAutocomplete.extractLast( request.term )},
          type: 'GET',
          dataType: 'json'
          success: ( data ) ->
            response( data );

      minLength: 0,
      search: ->
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