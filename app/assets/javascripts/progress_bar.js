jQuery(document).ready(function($){
  var progressbarNav = $('.progress-bar-nav'),
  progressbarNavTopPosition = progressbarNav.offset().top,
  taglineOffesetTop = $('#investment-projects-main').offset().top + $('#investment-projects-main').height() + parseInt($('#investment-projects-main').css('paddingTop').replace('px', ''));

  $(window).on('scroll', function(){
    if($(window).scrollTop() > progressbarNavTopPosition ) {
      progressbarNav.addClass('is-fixed');
    }
    else {
      progressbarNav.removeClass('is-fixed');
    }
  });
});
