App.TreeNavigator =
  closeNodes: (nodes) ->
    children = nodes.children('ul')

    if(children.length == 0)
      return

    children.each ->
      link = $(this).prev('a')
      $('<span class="closed"></span>').insertBefore(link)
      $(this).hide()
      App.TreeNavigator.closeNodes($(this).children())

  initialize: ->
    elem = $('[data-tree-navigator]')
    if(elem.length == 0)
      return

    ul = elem.find('ul:eq(0)')
    if(ul.length && ul.children().length)
      App.TreeNavigator.closeNodes(ul.children())

    $('[data-tree-navigator] span').on
      click: (e) ->
        elem = $(this)
        if(elem.hasClass('open'))
          elem.removeClass('open').addClass('closed')
          elem.siblings('ul').hide()
        else if(elem.hasClass('closed'))
          elem.removeClass('closed').addClass('open')
          elem.siblings('ul').show()

