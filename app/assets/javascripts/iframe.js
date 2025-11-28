document.addEventListener("click", function(element) {
  "use strict";
  if (!element.target.classList.contains("video-accept")) {
    return;
  }

  var stage = element.target.closest(".video-placeholder");
  if (!stage) {
    return;
  }

  stage.innerHTML = '<iframe src="' + stage.dataset.src + '" style="border:0" allowfullscreen title="' +
    stage.dataset.title + '"></iframe>';
});
