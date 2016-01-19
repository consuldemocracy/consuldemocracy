  jQuery(document).ready(function($){
  var articlesWrapper = $('.survey-questions');

  if( articlesWrapper.length > 0 ) {
    // cache jQuery objects
    var windowHeight = $(window).height(),
      articles = articlesWrapper.find('article'),
      aside = $('.survey-timeline'),
      articleSidebarLinks = aside.find('li');
    // initialize variables
    var scrolling = false,
      sidebarAnimation = false,
      resizing = false,
      mq = checkMQ(),
      svgCircleLength = parseInt(Math.PI*(articleSidebarLinks.eq(0).find('circle').attr('r')*2));

    // check media query and bind corresponding events
    if( mq == 'desktop' ) {
      $(window).on('scroll', checkRead);
      $(window).on('scroll', checkSidebar);
    }

    $(window).on('resize', resetScroll);

    updateArticle();
    updateSidebarPosition();

    aside.on('click', 'a', function(event){
      event.preventDefault();
      var selectedArticle = articles.eq($(this).parent('li').index()),
          selectedArticleTop = selectedArticle.offset().top;

      $(window).off('scroll', checkRead);

      $('body,html').animate(
        {'scrollTop': selectedArticleTop + 2},
        300, function(){
          checkRead();
          $(window).on('scroll', checkRead);
        }
      );
      });
  }

  function checkRead() {
    if( !scrolling ) {
      scrolling = true;
      (!window.requestAnimationFrame) ? setTimeout(updateArticle, 300) : window.requestAnimationFrame(updateArticle);
    }
  }

  function checkSidebar() {
    if( !sidebarAnimation ) {
      sidebarAnimation = true;
      (!window.requestAnimationFrame) ? setTimeout(updateSidebarPosition, 300) : window.requestAnimationFrame(updateSidebarPosition);
    }
  }

  function resetScroll() {
    if( !resizing ) {
      resizing = true;
      (!window.requestAnimationFrame) ? setTimeout(updateParams, 300) : window.requestAnimationFrame(updateParams);
    }
  }

  function updateParams() {
    windowHeight = $(window).height();
    mq = checkMQ();
    $(window).off('scroll', checkRead);
    $(window).off('scroll', checkSidebar);

    if( mq == 'desktop') {
      $(window).on('scroll', checkRead);
      $(window).on('scroll', checkSidebar);
    }
    resizing = false;
  }

  function updateArticle() {
    var scrollTop = $(window).scrollTop();

    articles.each(function(){
      var article = $(this),
        articleTop = article.offset().top,
        articleHeight = article.outerHeight(),
        articleSidebarLink = articleSidebarLinks.eq(article.index()).children('a');

      if( article.is(':last-of-type') ) articleHeight = articleHeight - windowHeight;

      if( articleTop > scrollTop) {
        articleSidebarLink.removeClass('read reading');
      } else if( scrollTop >= articleTop && articleTop + articleHeight > scrollTop) {
        var dashoffsetValue = svgCircleLength*( 1 - (scrollTop - articleTop)/articleHeight);
        articleSidebarLink.addClass('reading').removeClass('read').find('circle').attr({ 'stroke-dashoffset': dashoffsetValue });
        changeUrl(articleSidebarLink.attr('href'));
      } else {
        articleSidebarLink.removeClass('reading').addClass('read');
      }
    });
    scrolling = false;
  }

  function updateSidebarPosition() {
    var articlesWrapperTop = articlesWrapper.offset().top,
      articlesWrapperHeight = articlesWrapper.outerHeight(),
      scrollTop = $(window).scrollTop();

    if( scrollTop < articlesWrapperTop) {
      aside.removeClass('fixed').attr('style', '');
    } else if( scrollTop >= articlesWrapperTop && scrollTop < articlesWrapperTop + articlesWrapperHeight - windowHeight) {
      aside.addClass('fixed').attr('style', '');
    } else {
      var articlePaddingTop = Number(articles.eq(1).css('padding-top').replace('px', ''));
      if( aside.hasClass('fixed') ) aside.removeClass('fixed').css('top', articlesWrapperHeight + articlePaddingTop - windowHeight + 'px');
    }
    sidebarAnimation =  false;
  }

  function changeUrl(link) {
    var pageArray = location.pathname.split('/'),
          actualPage = pageArray[pageArray.length - 1] ;
        if( actualPage != link && history.pushState ) window.history.pushState({path: link},'',link);
  }

  function checkMQ() {
    return window.getComputedStyle(articlesWrapper.get(0), '::before').getPropertyValue('content').replace(/'/g, "").replace(/"/g, "");
  }
});
