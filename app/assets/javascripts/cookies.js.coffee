"use strict"

App.Cookies =

  saveCookie: (name, value, days) ->
    expires = undefined
    if days
      date = new Date
      date.setTime date.getTime() + days * 24 * 60 * 60 * 1000
      expires = '; expires=' + date.toGMTString()
    else
      expires = ''
    document.cookie = name + '=' + value + expires + '; path=/'
    return

  getCookie: (name) ->
    if document.cookie.length > 0
      c_start = document.cookie.indexOf(name + '=')
      if c_start != -1
        c_start = c_start + name.length + 1
        c_end = document.cookie.indexOf(';', c_start)
        if c_end == -1
          c_end = document.cookie.length
        return unescape(document.cookie.substring(c_start, c_end))
    ''
