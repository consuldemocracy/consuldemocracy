window.addEventListener("load", function () {
  const allLinks = document.querySelectorAll("a");
  openInNewTab(allLinks);

  const mutationObserver = new MutationObserver(() => {
    const allLinks = document.querySelectorAll("a");
    openInNewTab(allLinks);
  });

  const html = document.querySelector("html");
  mutationObserver.observe(html, { childList: true, subtree: true });
});

function openInNewTab(links) {
  for (let i = 0; i < links.length; i++) {
    const a = links[i];
    if (a.hostname != location.hostname) {
      a.rel = "noopener noreferrer";
      a.target = "_blank";
    }
  }
}
