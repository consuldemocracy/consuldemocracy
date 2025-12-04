var linkoutHandler = null;

function setupExternalLinkWarning() {
  "use strict";
  var message = document.body.dataset.warningForLinkouts;
  var enabled = Boolean(message);
  var currentHost = window.location.host;

  if (!enabled && linkoutHandler) {
    document.removeEventListener("click", linkoutHandler, true);
    linkoutHandler = null;
    return;
  }

  if (!enabled || linkoutHandler) {
    return;
  }

  linkoutHandler = function(event) {
    var link = event.target.closest("a[href]");
    if (!link) {
      return;
    }

    var url = new URL(link.href, window.location.origin);
    if (url.host !== currentHost) {
      if (!confirm(message)) {
        event.preventDefault();
      }
    }
  };
  document.addEventListener("click", linkoutHandler, true);
}

document.addEventListener("DOMContentLoaded", setupExternalLinkWarning);
document.addEventListener("turbolinks:load", setupExternalLinkWarning);
