const all_links = document.querySelectorAll("a");

for (let i = 0; i < all_links.length; i++) {
  const a = all_links[i];
  if (a.hostname != location.hostname) {
    a.rel = "noopener noreferrer";
    a.target = "_blank";
  }
}
