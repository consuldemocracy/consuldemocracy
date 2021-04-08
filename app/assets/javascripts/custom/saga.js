$(document).ready(function () {

  var theLanguage = $('html').attr('lang');

  if ($(theLanguage) == "en") {
    $(".home-page .jumbo.highlight img.margin").attr("src", 'assets/images/custom/banner-home-en.png');
  }

});
