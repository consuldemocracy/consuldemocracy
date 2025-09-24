let linkoutHandler = null;

function setupExternalLinkWarning() {
  const enabled = document.body.dataset.warningForLinkouts === "true";
  const currentHost = window.location.host;

  if (!enabled && linkoutHandler) {
    document.removeEventListener("click", linkoutHandler, true);
    linkoutHandler = null;
    return;
  }

  if (!enabled || linkoutHandler) return;

  linkoutHandler = function(event) {
    const link = event.target.closest("a[href]");
    if (!link) return;

    const url = new URL(link.href, window.location.origin);
    if (url.host !== currentHost) {
      const message = "By confirming, you agree to leave the website.";
      if (!confirm(message)) {
        event.preventDefault();
      }
    }
  };
  document.addEventListener("click", linkoutHandler, true);
}

document.addEventListener("DOMContentLoaded", setupExternalLinkWarning);
document.addEventListener("turbolinks:load", setupExternalLinkWarning);
