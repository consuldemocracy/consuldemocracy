(function() {
  "use strict";
  App.Users = {
    initialize: function() {
      var observer;
      $(".initialjs-avatar").initial();
      observer = new MutationObserver(function(mutations) {
        $.each(mutations, function(index, mutation) {
          $(mutation.addedNodes).find(".initialjs-avatar").initial();
        });
      });
      observer.observe(document.body, { childList: true, subtree: true });
    }
  };
}).call(this);
