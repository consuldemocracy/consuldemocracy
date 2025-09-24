(function() {
  "use strict";

  App.ExternalLinks = {
    initialize: function() {
      $("body").on("click", "a[href]", function(event) {
        var message, url, link_is_external, link_is_visitable;

        message = document.documentElement.dataset.warningForExternalLinks;

        url = new URL(event.target.closest("a[href]").href);
        link_is_visitable = url.protocol === "http:" || url.protocol === "https:";
        link_is_external = link_is_visitable && url.origin !== window.location.origin;

        return !link_is_external || !message || confirm(message);
      });
    }
  };
}).call(this);
