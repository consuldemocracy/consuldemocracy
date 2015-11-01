// Legal Cookie 0.1

var galleta = {

  nueva: function(name, value, days) {
    var expires = "";
    if (days) {
      var date = new Date();
      date.setTime(date.getTime()+(days*24*60*60*1000));
      expires = "; expires="+date.toGMTString();
    }
    document.cookie = name+"="+value+expires+"; path=/";
  },

  leer: function(name) {
    var nameEQ = name + "="
      , ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') c = c.substring(1,c.length);
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
  },

  borrar: function(name) {
    galleta.nueva(name,"",-1);
  }

};


$(function() {

  var barra = $('#barra_legal_cookie')
    , mi_galleta = galleta.leer('aviso-legal-cookie-plazapodemos');

  if (mi_galleta == 'acepto') {
    $(barra).hide();
  } else {
    $(barra).show();
  }

  $(barra).find('.ok').on('click', function(e) {
    e.preventDefault();
    galleta.nueva('aviso-legal-cookie-plazapodemos', 'acepto', 365);
    $(barra).fadeOut();
  });

});

