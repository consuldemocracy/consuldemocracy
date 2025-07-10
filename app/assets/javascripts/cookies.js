(function() {
  "use strict";
  App.Cookies = {
    saveCookie: function(name, value, days) {
      var date, expires;
      if (days) {
        date = new Date;
        date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
        expires = "; expires=" + date.toGMTString();
      } else {
        expires = "";
      }
      document.cookie = name + "=" + value + expires + "; path=/";
    },
    getCookie: function(name) {
      var c_end, c_start;
      if (document.cookie.length > 0) {
        c_start = document.cookie.indexOf(name + "=");
        if (c_start !== -1) {
          c_start = c_start + name.length + 1;
          c_end = document.cookie.indexOf(";", c_start);
          if (c_end === -1) {
            c_end = document.cookie.length;
          }
          return unescape(document.cookie.substring(c_start, c_end));
        }
      }
      return "";
    }
  };
}).call(this);
