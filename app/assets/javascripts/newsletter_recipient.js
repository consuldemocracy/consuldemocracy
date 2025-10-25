document.addEventListener("DOMContentLoaded", function() {
  "use strict";
  var btn = document.getElementById("newsletter-recipient-btn");

  btn.addEventListener("click", function() {
    var currentState = JSON.parse(btn.getAttribute("aria-pressed"));
    var yesText = btn.getAttribute("data-yes");
    var noText = btn.getAttribute("data-no");

    btn.textContent = currentState ? noText : yesText;
  });
});
