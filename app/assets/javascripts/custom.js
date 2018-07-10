// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//
//

function initCustomModules(){
  $('#js-proposal-change-suggest').click(function(){
    $('#js-suggest-notice').removeClass('hide');
  });
}

$(function(){

  $(document).ready(initCustomModules);
  $(document).on('page:load', initCustomModules);
  $(document).on('ajax:complete', initCustomModules);
});