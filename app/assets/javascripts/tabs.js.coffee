App.Tabs =

  tabDeepLink: (selector) ->
    $(selector).each ->
      $tabs = $(this)
      # match page load anchor
      anchor = window.location.hash
      if anchor.length and $tabs.find('[href="' + anchor + '"]').length
        $tabs.foundation 'selectTab', $(anchor)
        # roll up a little to show the header
        offset = $tabs.offset()
        $(window).load ->
          $('html, body').animate { scrollTop: offset.top }, 300
          return
      # append the hash on click
      $tabs.on 'change.zf.tabs', ->
        `var anchor`
        anchor = $tabs.find('.tabs-title.is-active a').attr('href')
        history.pushState {}, '', anchor
        return
      return
    return

  initialize: ->
    App.Tabs.tabDeepLink('.tabs');
