/*
 *  getQueryParameters.js
 *  Copyright (c) 2014 Nicholas Ortenzio
 *  The MIT License (MIT)
 *
 */

window.getQueryParameters = function(str) {
  str = (str || document.location.search).replace(/(^\?)/,'');
  if(!str) { return {}; }
  return str.split("&").reduce(function(o,n){n=n.split('=');o[n[0]]=n[1];return o},{});
};
