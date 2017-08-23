App.TreeNavigator =
  setNodes: (nodes) ->
    children = nodes.children('ul')

    if(children.length == 0)
      return

    children.each ->
      link = $(this).prev('a')
      $('<span class="open"></span>').insertBefore(link)
      App.TreeNavigator.setNodes($(this).children())

  initialize: ->
    elem = $('[data-tree-navigator]')
    if(elem.length == 0)
      return

    ul = elem.find('ul:eq(0)')
    if(ul.length && ul.children().length)
      App.TreeNavigator.setNodes(ul.children())

    $('[data-tree-navigator] span').on
      click: (e) ->
        elem = $(this)
        if(elem.hasClass('open'))
          elem.removeClass('open').addClass('closed')
          elem.siblings('ul').hide()
        else if(elem.hasClass('closed'))
          elem.removeClass('closed').addClass('open')
          elem.siblings('ul').show()

    if anchor = $(location).attr('hash')
      if link = elem.find('a[href="' + anchor + '"]')
        link.parents('ul').each ->
          $(this).show()
          $(this).siblings('span').removeClass('closed').addClass('open')

