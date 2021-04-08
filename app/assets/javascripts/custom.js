// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//
//

$(document).ready(function () {

  var theLanguage = $('html').attr('lang');

  if ($(theLanguage) == "en") {
    console.log("EN")
    $(".home-page .jumbo.highlight img.margin").attr("src", '/assets/banner-home-en.png');
  }

});
