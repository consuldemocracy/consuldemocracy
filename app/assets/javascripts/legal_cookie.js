// Legal Cookie 0.1

function getCookie(c_name){
    var c_value = document.cookie;
    var c_start = c_value.indexOf(" " + c_name + "=");
    if (c_start == -1){
        c_start = c_value.indexOf(c_name + "=");
    }
    if (c_start == -1){
        c_value = null;
    }else{
        c_start = c_value.indexOf("=", c_start) + 1;
        var c_end = c_value.indexOf(";", c_start);
        if (c_end == -1){
            c_end = c_value.length;
        }
        c_value = unescape(c_value.substring(c_start,c_end));
    }
    return c_value;
}

function setCookie(c_name,value,exdays){
    var exdate=new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
    document.cookie=c_name + "=" + c_value;
}

$(function() {
  var barra_legal = $('#barra_legal_cookie');
  barra_legal.hide();
  if (getCookie('aviso-legal-cookie-plazapodemos')=="1") {
    barra_legal.show();
  }
  barra_legal.find('.ok').on('click', function(e) {
    e.preventDefault();
    setCookie('aviso-legal-cookie-plazapodemos','1',365);
    barra_legal.fadeOut();    
  });
});
