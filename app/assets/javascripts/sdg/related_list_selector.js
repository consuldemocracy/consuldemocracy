(function() {
  "use strict";
  App.SDGRelatedListSelector = {
    initialize: function() {
      if ($(".sdg-related-list-selector").length) {
        var amsify_suggestags = new AmsifySuggestags($(".sdg-related-list-selector .input"));

        amsify_suggestags._settings({
          suggestions: $(".sdg-related-list-selector .input").data("suggestions-list"),
        });
        amsify_suggestags.classes.focus = ".sdg-related-list-focus";
        amsify_suggestags.classes.sTagsInput = ".sdg-related-list-selector-input";
        amsify_suggestags._init();
      }
    }
  };
}).call(this);
