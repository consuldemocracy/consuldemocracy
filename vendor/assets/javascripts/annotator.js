(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.annotator = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (global){
"use strict";

// Inject Annotator CSS
// var insertCss = require('insert-css');
// var css = require('./css/annotator.css');
// insertCss(css);

var app = require('./src/app');
var util = require('./src/util');

// Core annotator components
exports.App = app.App;

// Access to libraries (for browser installations)
exports.authz = require('./src/authz');
exports.identity = require('./src/identity');
exports.notification = require('./src/notification');
exports.storage = require('./src/storage');
exports.ui = require('./src/ui');
exports.util = util;

// Ext namespace (for core-provided extension modules)
exports.ext = {};

// If wicked-good-xpath is available, install it. This will not overwrite any
// native XPath functionality.
var wgxpath = global.wgxpath;
if (typeof wgxpath !== "undefined" &&
    wgxpath !== null &&
    typeof wgxpath.install === "function") {
    wgxpath.install();
}

// Store a reference to the current annotator object, if one exists.
var _annotator = global.annotator;

// Restores the Annotator property on the global object to it's
// previous value and returns the Annotator.
exports.noConflict = function noConflict() {
    global.annotator = _annotator;
    return this;
};

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./css/annotator.css":2,"./src/app":22,"./src/authz":23,"./src/identity":24,"./src/notification":25,"./src/storage":27,"./src/ui":28,"./src/util":39,"insert-css":16}],2:[function(require,module,exports){
module.exports = ".annotator-filter *,.annotator-notice,.annotator-widget *{font-family:\"Helvetica Neue\",Arial,Helvetica,sans-serif;font-weight:400;text-align:left;margin:0;padding:0;background:0 0;-webkit-transition:none;-moz-transition:none;-o-transition:none;transition:none;-moz-box-shadow:none;-webkit-box-shadow:none;-o-box-shadow:none;box-shadow:none;color:#909090}.annotator-adder{background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJAAAAAwCAYAAAD+WvNWAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDowMzgwMTE3NDA3MjA2ODExODRCQUU5RDY0RTkyQTJDNiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDowOUY5RUFERDYwOEIxMUUxOTQ1RDkyQzU2OTNEMDZENCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDowOUY5RUFEQzYwOEIxMUUxOTQ1RDkyQzU2OTNEMDZENCIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IE1hY2ludG9zaCI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjA1ODAxMTc0MDcyMDY4MTE5MTA5OUIyNDhFRUQ1QkM4IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjAzODAxMTc0MDcyMDY4MTE4NEJBRTlENjRFOTJBMkM2Ii8+IDwvcmRmOkRlc2NyaXB0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);background-repeat:no-repeat}.annotator-editor a:after,.annotator-filter .annotator-filter-navigation button:after,.annotator-filter .annotator-filter-property .annotator-filter-clear,.annotator-resize,.annotator-viewer .annotator-controls a,.annotator-viewer .annotator-controls button,.annotator-widget:after{background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAEiCAYAAAD0w4JOAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNSBNYWNpbnRvc2giIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RDY0MTMzNTM2QUQzMTFFMUE2REJERDgwQTM3Njg5NTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RDY0MTMzNTQ2QUQzMTFFMUE2REJERDgwQTM3Njg5NTUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo2ODkwQjlFQzZBRDExMUUxQTZEQkREODBBMzc2ODk1NSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpENjQxMzM1MjZBRDMxMUUxQTZEQkREODBBMzc2ODk1NSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PkijPpwAABBRSURBVHja7JsJVBRX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);background-repeat:no-repeat}.annotator-hl{background:#FFFF0A;background:rgba(255,255,10,.3);-ms-filter:\"progid:DXImageTransform.Microsoft.gradient(startColorstr=#4DFFFF0A, endColorstr=#4DFFFF0A)\"}.annotator-hl-temporary{background:#007CFF;background:rgba(0,124,255,.3);-ms-filter:\"progid:DXImageTransform.Microsoft.gradient(startColorstr=#4D007CFF, endColorstr=#4D007CFF)\"}.annotator-wrapper{position:relative}.annotator-adder,.annotator-notice,.annotator-outer{z-index:1020}.annotator-adder,.annotator-notice,.annotator-outer,.annotator-widget{position:absolute;font-size:10px;line-height:1}.annotator-hide{display:none;visibility:hidden}.annotator-adder{margin-top:-48px;margin-left:-24px;width:48px;height:48px;background-position:left top}.annotator-adder:hover{background-position:center top}.annotator-adder:active{background-position:center right}.annotator-adder button{display:block;width:36px;height:41px;margin:0 auto;border:none;background:0 0;text-indent:-999em;cursor:pointer}.annotator-outer{width:0;height:0}.annotator-widget{margin:0;padding:0;bottom:15px;left:-18px;min-width:265px;background-color:#FBFBFB;background-color:rgba(251,251,251,.98);border:1px solid #7A7A7A;border:1px solid rgba(122,122,122,.6);-webkit-border-radius:5px;-moz-border-radius:5px;border-radius:5px;-webkit-box-shadow:0 5px 15px rgba(0,0,0,.2);-moz-box-shadow:0 5px 15px rgba(0,0,0,.2);-o-box-shadow:0 5px 15px rgba(0,0,0,.2);box-shadow:0 5px 15px rgba(0,0,0,.2)}.annotator-invert-x .annotator-widget{left:auto;right:-18px}.annotator-invert-y .annotator-widget{bottom:auto;top:8px}.annotator-widget strong{font-weight:700}.annotator-widget .annotator-item,.annotator-widget .annotator-listing{padding:0;margin:0;list-style:none}.annotator-widget:after{content:\"\";display:block;width:18px;height:10px;background-position:0 0;position:absolute;bottom:-10px;left:8px}.annotator-invert-x .annotator-widget:after{left:auto;right:8px}.annotator-invert-y .annotator-widget:after{background-position:0 -15px;bottom:auto;top:-9px}.annotator-editor .annotator-item input,.annotator-editor .annotator-item textarea,.annotator-widget .annotator-item{position:relative;font-size:12px}.annotator-viewer .annotator-item{border-top:2px solid #7A7A7A;border-top:2px solid rgba(122,122,122,.2)}.annotator-widget .annotator-item:first-child{border-top:none}.annotator-editor .annotator-item,.annotator-viewer div{border-top:1px solid #858585;border-top:1px solid rgba(133,133,133,.11)}.annotator-viewer div{padding:6px}.annotator-viewer .annotator-item ol,.annotator-viewer .annotator-item ul{padding:4px 16px}.annotator-editor .annotator-item:first-child textarea,.annotator-viewer div:first-of-type{padding-top:12px;padding-bottom:12px;color:#3c3c3c;font-size:13px;font-style:italic;line-height:1.3;border-top:none}.annotator-viewer .annotator-controls{position:relative;top:5px;right:5px;padding-left:5px;opacity:0;-webkit-transition:opacity .2s ease-in;-moz-transition:opacity .2s ease-in;-o-transition:opacity .2s ease-in;transition:opacity .2s ease-in;float:right}.annotator-viewer li .annotator-controls.annotator-visible,.annotator-viewer li:hover .annotator-controls{opacity:1}.annotator-viewer .annotator-controls a,.annotator-viewer .annotator-controls button{cursor:pointer;display:inline-block;width:13px;height:13px;margin-left:2px;border:none;opacity:.2;text-indent:-900em;background-color:transparent;outline:0}.annotator-viewer .annotator-controls a:focus,.annotator-viewer .annotator-controls a:hover,.annotator-viewer .annotator-controls button:focus,.annotator-viewer .annotator-controls button:hover{opacity:.9}.annotator-viewer .annotator-controls a:active,.annotator-viewer .annotator-controls button:active{opacity:1}.annotator-viewer .annotator-controls button[disabled]{display:none}.annotator-viewer .annotator-controls .annotator-edit{background-position:0 -60px}.annotator-viewer .annotator-controls .annotator-delete{background-position:0 -75px}.annotator-viewer .annotator-controls .annotator-link{background-position:0 -270px}.annotator-editor .annotator-item{position:relative}.annotator-editor .annotator-item label{top:0;display:inline;cursor:pointer;font-size:12px}.annotator-editor .annotator-item input,.annotator-editor .annotator-item textarea{display:block;min-width:100%;padding:10px 8px;border:none;margin:0;color:#3c3c3c;background:0 0;-webkit-box-sizing:border-box;-moz-box-sizing:border-box;-o-box-sizing:border-box;box-sizing:border-box;resize:none}.annotator-editor .annotator-item textarea::-webkit-scrollbar{height:8px;width:8px}.annotator-editor .annotator-item textarea::-webkit-scrollbar-track-piece{margin:13px 0 3px;background-color:#e5e5e5;-webkit-border-radius:4px}.annotator-editor .annotator-item textarea::-webkit-scrollbar-thumb:vertical{height:25px;background-color:#ccc;-webkit-border-radius:4px;-webkit-box-shadow:0 1px 1px rgba(0,0,0,.1)}.annotator-editor .annotator-item textarea::-webkit-scrollbar-thumb:horizontal{width:25px;background-color:#ccc;-webkit-border-radius:4px}.annotator-editor .annotator-item:first-child textarea{min-height:5.5em;-webkit-border-radius:5px 5px 0 0;-moz-border-radius:5px 5px 0 0;-o-border-radius:5px 5px 0 0;border-radius:5px 5px 0 0}.annotator-editor .annotator-item input:focus,.annotator-editor .annotator-item textarea:focus{background-color:#f3f3f3;outline:0}.annotator-editor .annotator-item input[type=checkbox],.annotator-editor .annotator-item input[type=radio]{width:auto;min-width:0;padding:0;display:inline;margin:0 4px 0 0;cursor:pointer}.annotator-editor .annotator-checkbox{padding:8px 6px}.annotator-editor .annotator-controls,.annotator-filter,.annotator-filter .annotator-filter-navigation button{text-align:right;padding:3px;border-top:1px solid #d4d4d4;background-color:#d4d4d4;background-image:-webkit-gradient(linear,left top,left bottom,from(#f5f5f5),color-stop(.6,#dcdcdc),to(#d2d2d2));background-image:-moz-linear-gradient(to bottom,#f5f5f5,#dcdcdc 60%,#d2d2d2);background-image:-webkit-linear-gradient(to bottom,#f5f5f5,#dcdcdc 60%,#d2d2d2);background-image:linear-gradient(to bottom,#f5f5f5,#dcdcdc 60%,#d2d2d2);-webkit-box-shadow:inset 1px 0 0 rgba(255,255,255,.7),inset -1px 0 0 rgba(255,255,255,.7),inset 0 1px 0 rgba(255,255,255,.7);-moz-box-shadow:inset 1px 0 0 rgba(255,255,255,.7),inset -1px 0 0 rgba(255,255,255,.7),inset 0 1px 0 rgba(255,255,255,.7);-o-box-shadow:inset 1px 0 0 rgba(255,255,255,.7),inset -1px 0 0 rgba(255,255,255,.7),inset 0 1px 0 rgba(255,255,255,.7);box-shadow:inset 1px 0 0 rgba(255,255,255,.7),inset -1px 0 0 rgba(255,255,255,.7),inset 0 1px 0 rgba(255,255,255,.7);-webkit-border-radius:0 0 5px 5px;-moz-border-radius:0 0 5px 5px;-o-border-radius:0 0 5px 5px;border-radius:0 0 5px 5px}.annotator-editor.annotator-invert-y .annotator-controls{border-top:none;border-bottom:1px solid #b4b4b4;-webkit-border-radius:5px 5px 0 0;-moz-border-radius:5px 5px 0 0;-o-border-radius:5px 5px 0 0;border-radius:5px 5px 0 0}.annotator-editor a,.annotator-filter .annotator-filter-property label{position:relative;display:inline-block;padding:0 6px 0 22px;color:#363636;text-shadow:0 1px 0 rgba(255,255,255,.75);text-decoration:none;line-height:24px;font-size:12px;font-weight:700;border:1px solid #a2a2a2;background-color:#d4d4d4;background-image:-webkit-gradient(linear,left top,left bottom,from(#f5f5f5),color-stop(.5,#d2d2d2),color-stop(.5,#bebebe),to(#d2d2d2));background-image:-moz-linear-gradient(to bottom,#f5f5f5,#d2d2d2 50%,#bebebe 50%,#d2d2d2);background-image:-webkit-linear-gradient(to bottom,#f5f5f5,#d2d2d2 50%,#bebebe 50%,#d2d2d2);background-image:linear-gradient(to bottom,#f5f5f5,#d2d2d2 50%,#bebebe 50%,#d2d2d2);-webkit-box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);-moz-box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);-o-box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);-webkit-border-radius:5px;-moz-border-radius:5px;-o-border-radius:5px;border-radius:5px}.annotator-editor a:after{position:absolute;top:50%;left:5px;display:block;content:\"\";width:15px;height:15px;margin-top:-7px;background-position:0 -90px}.annotator-editor a.annotator-focus,.annotator-editor a:focus,.annotator-editor a:hover,.annotator-filter .annotator-filter-active label,.annotator-filter .annotator-filter-navigation button:hover{outline:0;border-color:#435aa0;background-color:#3865f9;background-image:-webkit-gradient(linear,left top,left bottom,from(#7691fb),color-stop(.5,#5075fb),color-stop(.5,#3865f9),to(#3665fa));background-image:-moz-linear-gradient(to bottom,#7691fb,#5075fb 50%,#3865f9 50%,#3665fa);background-image:-webkit-linear-gradient(to bottom,#7691fb,#5075fb 50%,#3865f9 50%,#3665fa);background-image:linear-gradient(to bottom,#7691fb,#5075fb 50%,#3865f9 50%,#3665fa);color:#fff;text-shadow:0 -1px 0 rgba(0,0,0,.42)}.annotator-editor a:focus:after,.annotator-editor a:hover:after{margin-top:-8px;background-position:0 -105px}.annotator-editor a:active,.annotator-filter .annotator-filter-navigation button:active{border-color:#700c49;background-color:#d12e8e;background-image:-webkit-gradient(linear,left top,left bottom,from(#fc7cca),color-stop(.5,#e85db2),color-stop(.5,#d12e8e),to(#ff009c));background-image:-moz-linear-gradient(to bottom,#fc7cca,#e85db2 50%,#d12e8e 50%,#ff009c);background-image:-webkit-linear-gradient(to bottom,#fc7cca,#e85db2 50%,#d12e8e 50%,#ff009c);background-image:linear-gradient(to bottom,#fc7cca,#e85db2 50%,#d12e8e 50%,#ff009c)}.annotator-editor a.annotator-save:after{background-position:0 -120px}.annotator-editor a.annotator-save.annotator-focus:after,.annotator-editor a.annotator-save:focus:after,.annotator-editor a.annotator-save:hover:after{margin-top:-8px;background-position:0 -135px}.annotator-editor .annotator-widget:after{background-position:0 -30px}.annotator-editor.annotator-invert-y .annotator-widget .annotator-controls{background-color:#f2f2f2}.annotator-editor.annotator-invert-y .annotator-widget:after{background-position:0 -45px;height:11px}.annotator-resize{position:absolute;top:0;right:0;width:12px;height:12px;background-position:2px -150px}.annotator-invert-x .annotator-resize{right:auto;left:0;background-position:0 -195px}.annotator-invert-y .annotator-resize{top:auto;bottom:0;background-position:2px -165px}.annotator-invert-y.annotator-invert-x .annotator-resize{background-position:0 -180px}.annotator-notice{color:#fff;position:fixed;top:-54px;left:0;width:100%;font-size:14px;line-height:50px;text-align:center;background:#000;background:rgba(0,0,0,.9);border-bottom:4px solid #d4d4d4;-webkit-transition:top .4s ease-out;-moz-transition:top .4s ease-out;-o-transition:top .4s ease-out;transition:top .4s ease-out}.annotator-notice-success{border-color:#3665f9}.annotator-notice-error{border-color:#ff7e00}.annotator-notice p{margin:0}.annotator-notice a{color:#fff}.annotator-notice-show{top:0}.annotator-tags{margin-bottom:-2px}.annotator-tags .annotator-tag{display:inline-block;padding:0 8px;margin-bottom:2px;line-height:1.6;font-weight:700;background-color:#e6e6e6;-webkit-border-radius:8px;-moz-border-radius:8px;-o-border-radius:8px;border-radius:8px}.annotator-filter{z-index:1010;position:fixed;top:0;right:0;left:0;text-align:left;line-height:0;border:none;border-bottom:1px solid #878787;padding-left:10px;padding-right:10px;-webkit-border-radius:0;-moz-border-radius:0;-o-border-radius:0;border-radius:0;-webkit-box-shadow:inset 0 -1px 0 rgba(255,255,255,.3);-moz-box-shadow:inset 0 -1px 0 rgba(255,255,255,.3);-o-box-shadow:inset 0 -1px 0 rgba(255,255,255,.3);box-shadow:inset 0 -1px 0 rgba(255,255,255,.3)}.annotator-filter strong{font-size:12px;font-weight:700;color:#3c3c3c;text-shadow:0 1px 0 rgba(255,255,255,.7);position:relative;top:-9px}.annotator-filter .annotator-filter-navigation,.annotator-filter .annotator-filter-property{position:relative;display:inline-block;overflow:hidden;line-height:10px;padding:2px 0;margin-right:8px}.annotator-filter .annotator-filter-navigation button,.annotator-filter .annotator-filter-property label{text-align:left;display:block;float:left;line-height:20px;-webkit-border-radius:10px 0 0 10px;-moz-border-radius:10px 0 0 10px;-o-border-radius:10px 0 0 10px;border-radius:10px 0 0 10px}.annotator-filter .annotator-filter-navigation .annotator-filter-next,.annotator-filter .annotator-filter-property input{-webkit-border-radius:0 10px 10px 0;border-radius:0 10px 10px 0;-moz-border-radius:0 10px 10px 0;-o-border-radius:0 10px 10px 0}.annotator-filter .annotator-filter-property label{padding-left:8px}.annotator-filter .annotator-filter-property input{display:block;float:right;-webkit-appearance:none;border:1px solid #878787;border-left:none;padding:2px 4px;line-height:16px;min-height:16px;font-size:12px;width:150px;color:#333;background-color:#f8f8f8;-webkit-box-shadow:inset 0 1px 1px rgba(0,0,0,.2);-moz-box-shadow:inset 0 1px 1px rgba(0,0,0,.2);-o-box-shadow:inset 0 1px 1px rgba(0,0,0,.2);box-shadow:inset 0 1px 1px rgba(0,0,0,.2)}.annotator-filter .annotator-filter-property input:focus{outline:0;background-color:#fff}.annotator-filter .annotator-filter-clear{position:absolute;right:3px;top:6px;border:none;text-indent:-900em;width:15px;height:15px;background-position:0 -90px;opacity:.4}.annotator-filter .annotator-filter-clear:focus,.annotator-filter .annotator-filter-clear:hover{opacity:.8}.annotator-filter .annotator-filter-clear:active{opacity:1}.annotator-filter .annotator-filter-navigation button{border:1px solid #a2a2a2;padding:0;text-indent:-900px;width:20px;min-height:22px;-webkit-box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);-moz-box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);-o-box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8);box-shadow:inset 0 0 5px rgba(255,255,255,.2),inset 0 0 1px rgba(255,255,255,.8)}.annotator-filter .annotator-filter-navigation button,.annotator-filter .annotator-filter-navigation button:focus,.annotator-filter .annotator-filter-navigation button:hover{color:transparent}.annotator-filter .annotator-filter-navigation button:after{position:absolute;top:8px;left:8px;content:\"\";display:block;width:9px;height:9px;background-position:0 -210px}.annotator-filter .annotator-filter-navigation button:hover:after{background-position:0 -225px}.annotator-filter .annotator-filter-navigation .annotator-filter-next{border-left:none}.annotator-filter .annotator-filter-navigation .annotator-filter-next:after{left:auto;right:7px;background-position:0 -240px}.annotator-filter .annotator-filter-navigation .annotator-filter-next:hover:after{background-position:0 -255px}.annotator-hl-active{background:#FFFF0A;background:rgba(255,255,10,.8);-ms-filter:\"progid:DXImageTransform.Microsoft.gradient(startColorstr=#CCFFFF0A, endColorstr=#CCFFFF0A)\"}.annotator-hl-filtered{background-color:transparent}"
},{}],3:[function(require,module,exports){
(function (definition) {
  if (typeof exports === "object") {
    module.exports = definition();
  }
  else if (typeof define === 'function' && define.amd) {
    define(definition);
  }
  else {
    window.BackboneExtend = definition();
  }
})(function () {
  "use strict";

  // mini-underscore
  var _ = {
    has: function (obj, key) {
      return Object.prototype.hasOwnProperty.call(obj, key);
    },

    extend: function(obj) {
      for (var i=1; i<arguments.length; ++i) {
        var source = arguments[i];
        if (source) {
          for (var prop in source) {
            obj[prop] = source[prop];
          }
        }
      }
      return obj;
    }
  };

  /// Following code is pasted from Backbone.js ///

  // Helper function to correctly set up the prototype chain, for subclasses.
  // Similar to `goog.inherits`, but uses a hash of prototype properties and
  // class properties to be extended.
  var extend = function(protoProps, staticProps) {
    var parent = this;
    var child;

    // The constructor function for the new subclass is either defined by you
    // (the "constructor" property in your `extend` definition), or defaulted
    // by us to simply call the parent's constructor.
    if (protoProps && _.has(protoProps, 'constructor')) {
      child = protoProps.constructor;
    } else {
      child = function(){ return parent.apply(this, arguments); };
    }

    // Add static properties to the constructor function, if supplied.
    _.extend(child, parent, staticProps);

    // Set the prototype chain to inherit from `parent`, without calling
    // `parent`'s constructor function.
    var Surrogate = function(){ this.constructor = child; };
    Surrogate.prototype = parent.prototype;
    child.prototype = new Surrogate();

    // Add prototype properties (instance properties) to the subclass,
    // if supplied.
    if (protoProps) _.extend(child.prototype, protoProps);

    // Set a convenience property in case the parent's prototype is needed
    // later.
    child.__super__ = parent.prototype;

    return child;
  };

  // Expose the extend function
  return extend;
});

},{}],4:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};
var queue = [];
var draining = false;

function drainQueue() {
    if (draining) {
        return;
    }
    draining = true;
    var currentQueue;
    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        var i = -1;
        while (++i < len) {
            currentQueue[i]();
        }
        len = queue.length;
    }
    draining = false;
}
process.nextTick = function (fun) {
    queue.push(fun);
    if (!draining) {
        setTimeout(drainQueue, 0);
    }
};

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

// TODO(shtylman)
process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],5:[function(require,module,exports){
"use strict";
var Promise = require("./promise/promise").Promise;
var polyfill = require("./promise/polyfill").polyfill;
exports.Promise = Promise;
exports.polyfill = polyfill;
},{"./promise/polyfill":10,"./promise/promise":11}],6:[function(require,module,exports){
"use strict";
/* global toString */

var isArray = require("./utils").isArray;
var isFunction = require("./utils").isFunction;

/**
  Returns a promise that is fulfilled when all the given promises have been
  fulfilled, or rejected if any of them become rejected. The return promise
  is fulfilled with an array that gives all the values in the order they were
  passed in the `promises` array argument.

  Example:

  ```javascript
  var promise1 = RSVP.resolve(1);
  var promise2 = RSVP.resolve(2);
  var promise3 = RSVP.resolve(3);
  var promises = [ promise1, promise2, promise3 ];

  RSVP.all(promises).then(function(array){
    // The array here would be [ 1, 2, 3 ];
  });
  ```

  If any of the `promises` given to `RSVP.all` are rejected, the first promise
  that is rejected will be given as an argument to the returned promises's
  rejection handler. For example:

  Example:

  ```javascript
  var promise1 = RSVP.resolve(1);
  var promise2 = RSVP.reject(new Error("2"));
  var promise3 = RSVP.reject(new Error("3"));
  var promises = [ promise1, promise2, promise3 ];

  RSVP.all(promises).then(function(array){
    // Code here never runs because there are rejected promises!
  }, function(error) {
    // error.message === "2"
  });
  ```

  @method all
  @for RSVP
  @param {Array} promises
  @param {String} label
  @return {Promise} promise that is fulfilled when all `promises` have been
  fulfilled, or rejected if any of them become rejected.
*/
function all(promises) {
  /*jshint validthis:true */
  var Promise = this;

  if (!isArray(promises)) {
    throw new TypeError('You must pass an array to all.');
  }

  return new Promise(function(resolve, reject) {
    var results = [], remaining = promises.length,
    promise;

    if (remaining === 0) {
      resolve([]);
    }

    function resolver(index) {
      return function(value) {
        resolveAll(index, value);
      };
    }

    function resolveAll(index, value) {
      results[index] = value;
      if (--remaining === 0) {
        resolve(results);
      }
    }

    for (var i = 0; i < promises.length; i++) {
      promise = promises[i];

      if (promise && isFunction(promise.then)) {
        promise.then(resolver(i), reject);
      } else {
        resolveAll(i, promise);
      }
    }
  });
}

exports.all = all;
},{"./utils":15}],7:[function(require,module,exports){
(function (process,global){
"use strict";
var browserGlobal = (typeof window !== 'undefined') ? window : {};
var BrowserMutationObserver = browserGlobal.MutationObserver || browserGlobal.WebKitMutationObserver;
var local = (typeof global !== 'undefined') ? global : (this === undefined? window:this);

// node
function useNextTick() {
  return function() {
    process.nextTick(flush);
  };
}

function useMutationObserver() {
  var iterations = 0;
  var observer = new BrowserMutationObserver(flush);
  var node = document.createTextNode('');
  observer.observe(node, { characterData: true });

  return function() {
    node.data = (iterations = ++iterations % 2);
  };
}

function useSetTimeout() {
  return function() {
    local.setTimeout(flush, 1);
  };
}

var queue = [];
function flush() {
  for (var i = 0; i < queue.length; i++) {
    var tuple = queue[i];
    var callback = tuple[0], arg = tuple[1];
    callback(arg);
  }
  queue = [];
}

var scheduleFlush;

// Decide what async method to use to triggering processing of queued callbacks:
if (typeof process !== 'undefined' && {}.toString.call(process) === '[object process]') {
  scheduleFlush = useNextTick();
} else if (BrowserMutationObserver) {
  scheduleFlush = useMutationObserver();
} else {
  scheduleFlush = useSetTimeout();
}

function asap(callback, arg) {
  var length = queue.push([callback, arg]);
  if (length === 1) {
    // If length is 1, that means that we need to schedule an async flush.
    // If additional callbacks are queued before the queue is flushed, they
    // will be processed by this flush that we are scheduling.
    scheduleFlush();
  }
}

exports.asap = asap;
}).call(this,require('_process'),typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"_process":4}],8:[function(require,module,exports){
"use strict";
/**
  `RSVP.Promise.cast` returns the same promise if that promise shares a constructor
  with the promise being casted.

  Example:

  ```javascript
  var promise = RSVP.resolve(1);
  var casted = RSVP.Promise.cast(promise);

  console.log(promise === casted); // true
  ```

  In the case of a promise whose constructor does not match, it is assimilated.
  The resulting promise will fulfill or reject based on the outcome of the
  promise being casted.

  In the case of a non-promise, a promise which will fulfill with that value is
  returned.

  Example:

  ```javascript
  var value = 1; // could be a number, boolean, string, undefined...
  var casted = RSVP.Promise.cast(value);

  console.log(value === casted); // false
  console.log(casted instanceof RSVP.Promise) // true

  casted.then(function(val) {
    val === value // => true
  });
  ```

  `RSVP.Promise.cast` is similar to `RSVP.resolve`, but `RSVP.Promise.cast` differs in the
  following ways:
  * `RSVP.Promise.cast` serves as a memory-efficient way of getting a promise, when you
  have something that could either be a promise or a value. RSVP.resolve
  will have the same effect but will create a new promise wrapper if the
  argument is a promise.
  * `RSVP.Promise.cast` is a way of casting incoming thenables or promise subclasses to
  promises of the exact class specified, so that the resulting object's `then` is
  ensured to have the behavior of the constructor you are calling cast on (i.e., RSVP.Promise).

  @method cast
  @for RSVP
  @param {Object} object to be casted
  @return {Promise} promise that is fulfilled when all properties of `promises`
  have been fulfilled, or rejected if any of them become rejected.
*/


function cast(object) {
  /*jshint validthis:true */
  if (object && typeof object === 'object' && object.constructor === this) {
    return object;
  }

  var Promise = this;

  return new Promise(function(resolve) {
    resolve(object);
  });
}

exports.cast = cast;
},{}],9:[function(require,module,exports){
"use strict";
var config = {
  instrument: false
};

function configure(name, value) {
  if (arguments.length === 2) {
    config[name] = value;
  } else {
    return config[name];
  }
}

exports.config = config;
exports.configure = configure;
},{}],10:[function(require,module,exports){
(function (global){
"use strict";
/*global self*/
var RSVPPromise = require("./promise").Promise;
var isFunction = require("./utils").isFunction;

function polyfill() {
  var local;

  if (typeof global !== 'undefined') {
    local = global;
  } else if (typeof window !== 'undefined' && window.document) {
    local = window;
  } else {
    local = self;
  }

  var es6PromiseSupport =
    "Promise" in local &&
    // Some of these methods are missing from
    // Firefox/Chrome experimental implementations
    "cast" in local.Promise &&
    "resolve" in local.Promise &&
    "reject" in local.Promise &&
    "all" in local.Promise &&
    "race" in local.Promise &&
    // Older version of the spec had a resolver object
    // as the arg rather than a function
    (function() {
      var resolve;
      new local.Promise(function(r) { resolve = r; });
      return isFunction(resolve);
    }());

  if (!es6PromiseSupport) {
    local.Promise = RSVPPromise;
  }
}

exports.polyfill = polyfill;
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./promise":11,"./utils":15}],11:[function(require,module,exports){
"use strict";
var config = require("./config").config;
var configure = require("./config").configure;
var objectOrFunction = require("./utils").objectOrFunction;
var isFunction = require("./utils").isFunction;
var now = require("./utils").now;
var cast = require("./cast").cast;
var all = require("./all").all;
var race = require("./race").race;
var staticResolve = require("./resolve").resolve;
var staticReject = require("./reject").reject;
var asap = require("./asap").asap;

var counter = 0;

config.async = asap; // default async is asap;

function Promise(resolver) {
  if (!isFunction(resolver)) {
    throw new TypeError('You must pass a resolver function as the first argument to the promise constructor');
  }

  if (!(this instanceof Promise)) {
    throw new TypeError("Failed to construct 'Promise': Please use the 'new' operator, this object constructor cannot be called as a function.");
  }

  this._subscribers = [];

  invokeResolver(resolver, this);
}

function invokeResolver(resolver, promise) {
  function resolvePromise(value) {
    resolve(promise, value);
  }

  function rejectPromise(reason) {
    reject(promise, reason);
  }

  try {
    resolver(resolvePromise, rejectPromise);
  } catch(e) {
    rejectPromise(e);
  }
}

function invokeCallback(settled, promise, callback, detail) {
  var hasCallback = isFunction(callback),
      value, error, succeeded, failed;

  if (hasCallback) {
    try {
      value = callback(detail);
      succeeded = true;
    } catch(e) {
      failed = true;
      error = e;
    }
  } else {
    value = detail;
    succeeded = true;
  }

  if (handleThenable(promise, value)) {
    return;
  } else if (hasCallback && succeeded) {
    resolve(promise, value);
  } else if (failed) {
    reject(promise, error);
  } else if (settled === FULFILLED) {
    resolve(promise, value);
  } else if (settled === REJECTED) {
    reject(promise, value);
  }
}

var PENDING   = void 0;
var SEALED    = 0;
var FULFILLED = 1;
var REJECTED  = 2;

function subscribe(parent, child, onFulfillment, onRejection) {
  var subscribers = parent._subscribers;
  var length = subscribers.length;

  subscribers[length] = child;
  subscribers[length + FULFILLED] = onFulfillment;
  subscribers[length + REJECTED]  = onRejection;
}

function publish(promise, settled) {
  var child, callback, subscribers = promise._subscribers, detail = promise._detail;

  for (var i = 0; i < subscribers.length; i += 3) {
    child = subscribers[i];
    callback = subscribers[i + settled];

    invokeCallback(settled, child, callback, detail);
  }

  promise._subscribers = null;
}

Promise.prototype = {
  constructor: Promise,

  _state: undefined,
  _detail: undefined,
  _subscribers: undefined,

  then: function(onFulfillment, onRejection) {
    var promise = this;

    var thenPromise = new this.constructor(function() {});

    if (this._state) {
      var callbacks = arguments;
      config.async(function invokePromiseCallback() {
        invokeCallback(promise._state, thenPromise, callbacks[promise._state - 1], promise._detail);
      });
    } else {
      subscribe(this, thenPromise, onFulfillment, onRejection);
    }

    return thenPromise;
  },

  'catch': function(onRejection) {
    return this.then(null, onRejection);
  }
};

Promise.all = all;
Promise.cast = cast;
Promise.race = race;
Promise.resolve = staticResolve;
Promise.reject = staticReject;

function handleThenable(promise, value) {
  var then = null,
  resolved;

  try {
    if (promise === value) {
      throw new TypeError("A promises callback cannot return that same promise.");
    }

    if (objectOrFunction(value)) {
      then = value.then;

      if (isFunction(then)) {
        then.call(value, function(val) {
          if (resolved) { return true; }
          resolved = true;

          if (value !== val) {
            resolve(promise, val);
          } else {
            fulfill(promise, val);
          }
        }, function(val) {
          if (resolved) { return true; }
          resolved = true;

          reject(promise, val);
        });

        return true;
      }
    }
  } catch (error) {
    if (resolved) { return true; }
    reject(promise, error);
    return true;
  }

  return false;
}

function resolve(promise, value) {
  if (promise === value) {
    fulfill(promise, value);
  } else if (!handleThenable(promise, value)) {
    fulfill(promise, value);
  }
}

function fulfill(promise, value) {
  if (promise._state !== PENDING) { return; }
  promise._state = SEALED;
  promise._detail = value;

  config.async(publishFulfillment, promise);
}

function reject(promise, reason) {
  if (promise._state !== PENDING) { return; }
  promise._state = SEALED;
  promise._detail = reason;

  config.async(publishRejection, promise);
}

function publishFulfillment(promise) {
  publish(promise, promise._state = FULFILLED);
}

function publishRejection(promise) {
  publish(promise, promise._state = REJECTED);
}

exports.Promise = Promise;
},{"./all":6,"./asap":7,"./cast":8,"./config":9,"./race":12,"./reject":13,"./resolve":14,"./utils":15}],12:[function(require,module,exports){
"use strict";
/* global toString */
var isArray = require("./utils").isArray;

/**
  `RSVP.race` allows you to watch a series of promises and act as soon as the
  first promise given to the `promises` argument fulfills or rejects.

  Example:

  ```javascript
  var promise1 = new RSVP.Promise(function(resolve, reject){
    setTimeout(function(){
      resolve("promise 1");
    }, 200);
  });

  var promise2 = new RSVP.Promise(function(resolve, reject){
    setTimeout(function(){
      resolve("promise 2");
    }, 100);
  });

  RSVP.race([promise1, promise2]).then(function(result){
    // result === "promise 2" because it was resolved before promise1
    // was resolved.
  });
  ```

  `RSVP.race` is deterministic in that only the state of the first completed
  promise matters. For example, even if other promises given to the `promises`
  array argument are resolved, but the first completed promise has become
  rejected before the other promises became fulfilled, the returned promise
  will become rejected:

  ```javascript
  var promise1 = new RSVP.Promise(function(resolve, reject){
    setTimeout(function(){
      resolve("promise 1");
    }, 200);
  });

  var promise2 = new RSVP.Promise(function(resolve, reject){
    setTimeout(function(){
      reject(new Error("promise 2"));
    }, 100);
  });

  RSVP.race([promise1, promise2]).then(function(result){
    // Code here never runs because there are rejected promises!
  }, function(reason){
    // reason.message === "promise2" because promise 2 became rejected before
    // promise 1 became fulfilled
  });
  ```

  @method race
  @for RSVP
  @param {Array} promises array of promises to observe
  @param {String} label optional string for describing the promise returned.
  Useful for tooling.
  @return {Promise} a promise that becomes fulfilled with the value the first
  completed promises is resolved with if the first completed promise was
  fulfilled, or rejected with the reason that the first completed promise
  was rejected with.
*/
function race(promises) {
  /*jshint validthis:true */
  var Promise = this;

  if (!isArray(promises)) {
    throw new TypeError('You must pass an array to race.');
  }
  return new Promise(function(resolve, reject) {
    var results = [], promise;

    for (var i = 0; i < promises.length; i++) {
      promise = promises[i];

      if (promise && typeof promise.then === 'function') {
        promise.then(resolve, reject);
      } else {
        resolve(promise);
      }
    }
  });
}

exports.race = race;
},{"./utils":15}],13:[function(require,module,exports){
"use strict";
/**
  `RSVP.reject` returns a promise that will become rejected with the passed
  `reason`. `RSVP.reject` is essentially shorthand for the following:

  ```javascript
  var promise = new RSVP.Promise(function(resolve, reject){
    reject(new Error('WHOOPS'));
  });

  promise.then(function(value){
    // Code here doesn't run because the promise is rejected!
  }, function(reason){
    // reason.message === 'WHOOPS'
  });
  ```

  Instead of writing the above, your code now simply becomes the following:

  ```javascript
  var promise = RSVP.reject(new Error('WHOOPS'));

  promise.then(function(value){
    // Code here doesn't run because the promise is rejected!
  }, function(reason){
    // reason.message === 'WHOOPS'
  });
  ```

  @method reject
  @for RSVP
  @param {Any} reason value that the returned promise will be rejected with.
  @param {String} label optional string for identifying the returned promise.
  Useful for tooling.
  @return {Promise} a promise that will become rejected with the given
  `reason`.
*/
function reject(reason) {
  /*jshint validthis:true */
  var Promise = this;

  return new Promise(function (resolve, reject) {
    reject(reason);
  });
}

exports.reject = reject;
},{}],14:[function(require,module,exports){
"use strict";
/**
  `RSVP.resolve` returns a promise that will become fulfilled with the passed
  `value`. `RSVP.resolve` is essentially shorthand for the following:

  ```javascript
  var promise = new RSVP.Promise(function(resolve, reject){
    resolve(1);
  });

  promise.then(function(value){
    // value === 1
  });
  ```

  Instead of writing the above, your code now simply becomes the following:

  ```javascript
  var promise = RSVP.resolve(1);

  promise.then(function(value){
    // value === 1
  });
  ```

  @method resolve
  @for RSVP
  @param {Any} value value that the returned promise will be resolved with
  @param {String} label optional string for identifying the returned promise.
  Useful for tooling.
  @return {Promise} a promise that will become fulfilled with the given
  `value`
*/
function resolve(value) {
  /*jshint validthis:true */
  var Promise = this;
  return new Promise(function(resolve, reject) {
    resolve(value);
  });
}

exports.resolve = resolve;
},{}],15:[function(require,module,exports){
"use strict";
function objectOrFunction(x) {
  return isFunction(x) || (typeof x === "object" && x !== null);
}

function isFunction(x) {
  return typeof x === "function";
}

function isArray(x) {
  return Object.prototype.toString.call(x) === "[object Array]";
}

// Date.now is not available in browsers < IE9
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/now#Compatibility
var now = Date.now || function() { return new Date().getTime(); };


exports.objectOrFunction = objectOrFunction;
exports.isFunction = isFunction;
exports.isArray = isArray;
exports.now = now;
},{}],16:[function(require,module,exports){
var inserted = {};

module.exports = function (css, options) {
    if (inserted[css]) return;
    inserted[css] = true;

    var elem = document.createElement('style');
    elem.setAttribute('type', 'text/css');

    if ('textContent' in elem) {
      elem.textContent = css;
    } else {
      elem.styleSheet.cssText = css;
    }

    var head = document.getElementsByTagName('head')[0];
    if (options && options.prepend) {
        head.insertBefore(elem, head.childNodes[0]);
    } else {
        head.appendChild(elem);
    }
};

},{}],17:[function(require,module,exports){
},{}],18:[function(require,module,exports){
// Generated by CoffeeScript 1.7.1
(function() {
  module.exports = {
    xpath: require("./xpath"),
    Range: require("./range")
  };

}).call(this);

},{"./range":19,"./xpath":21}],19:[function(require,module,exports){
// Generated by CoffeeScript 1.7.1
(function() {
  var Range, Util, xpath,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  xpath = require('./xpath');

  Util = require('./util');

  Range = {};

  Range.sniff = function(r) {
    if (r.commonAncestorContainer != null) {
      return new Range.BrowserRange(r);
    } else if (typeof r.start === "string") {
      return new Range.SerializedRange(r);
    } else if (r.start && typeof r.start === "object") {
      return new Range.NormalizedRange(r);
    } else {
      console.error("Could not sniff range type");
      return false;
    }
  };

  Range.RangeError = (function(_super) {
    __extends(RangeError, _super);

    function RangeError(type, message, parent) {
      this.type = type;
      this.message = message;
      this.parent = parent != null ? parent : null;
      RangeError.__super__.constructor.call(this, this.message);
    }

    return RangeError;

  })(Error);

  Range.BrowserRange = (function() {
    function BrowserRange(obj) {
      this.commonAncestorContainer = obj.commonAncestorContainer;
      this.startContainer = obj.startContainer;
      this.startOffset = obj.startOffset;
      this.endContainer = obj.endContainer;
      this.endOffset = obj.endOffset;
    }

    BrowserRange.prototype.normalize = function(root) {
      var nr, r;
      if (this.tainted) {
        console.error("You may only call normalize() once on a BrowserRange!");
        return false;
      } else {
        this.tainted = true;
      }
      r = {};
      this._normalizeStart(r);
      this._normalizeEnd(r);
      nr = {};
      if (r.startOffset > 0) {
        if (r.start.nodeValue.length > r.startOffset) {
          nr.start = r.start.splitText(r.startOffset);
        } else {
          nr.start = r.start.nextSibling;
        }
      } else {
        nr.start = r.start;
      }
      if (r.start === r.end) {
        if (nr.start.nodeValue.length > (r.endOffset - r.startOffset)) {
          nr.start.splitText(r.endOffset - r.startOffset);
        }
        nr.end = nr.start;
      } else {
        if (r.end.nodeValue.length > r.endOffset) {
          r.end.splitText(r.endOffset);
        }
        nr.end = r.end;
      }
      nr.commonAncestor = this.commonAncestorContainer;
      while (nr.commonAncestor.nodeType !== Util.NodeTypes.ELEMENT_NODE) {
        nr.commonAncestor = nr.commonAncestor.parentNode;
      }
      return new Range.NormalizedRange(nr);
    };

    BrowserRange.prototype._normalizeStart = function(r) {
      if (this.startContainer.nodeType === Util.NodeTypes.ELEMENT_NODE) {
        r.start = Util.getFirstTextNodeNotBefore(this.startContainer.childNodes[this.startOffset]);
        return r.startOffset = 0;
      } else {
        r.start = this.startContainer;
        return r.startOffset = this.startOffset;
      }
    };

    BrowserRange.prototype._normalizeEnd = function(r) {
      var n, node;
      if (this.endContainer.nodeType === Util.NodeTypes.ELEMENT_NODE) {
        node = this.endContainer.childNodes[this.endOffset];
        if (node != null) {
          n = node;
          while ((n != null) && (n.nodeType !== Util.NodeTypes.TEXT_NODE)) {
            n = n.firstChild;
          }
          if (n != null) {
            r.end = n;
            r.endOffset = 0;
          }
        }
        if (r.end == null) {
          if (this.endOffset) {
            node = this.endContainer.childNodes[this.endOffset - 1];
          } else {
            node = this.endContainer.previousSibling;
          }
          r.end = Util.getLastTextNodeUpTo(node);
          return r.endOffset = r.end.nodeValue.length;
        }
      } else {
        r.end = this.endContainer;
        return r.endOffset = this.endOffset;
      }
    };

    BrowserRange.prototype.serialize = function(root, ignoreSelector) {
      return this.normalize(root).serialize(root, ignoreSelector);
    };

    return BrowserRange;

  })();

  Range.NormalizedRange = (function() {
    function NormalizedRange(obj) {
      this.commonAncestor = obj.commonAncestor;
      this.start = obj.start;
      this.end = obj.end;
    }

    NormalizedRange.prototype.normalize = function(root) {
      return this;
    };

    NormalizedRange.prototype.limit = function(bounds) {
      var nodes, parent, startParents, _i, _len, _ref;
      nodes = $.grep(this.textNodes(), function(node) {
        return node.parentNode === bounds || $.contains(bounds, node.parentNode);
      });
      if (!nodes.length) {
        return null;
      }
      this.start = nodes[0];
      this.end = nodes[nodes.length - 1];
      startParents = $(this.start).parents();
      _ref = $(this.end).parents();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        parent = _ref[_i];
        if (startParents.index(parent) !== -1) {
          this.commonAncestor = parent;
          break;
        }
      }
      return this;
    };

    NormalizedRange.prototype.serialize = function(root, ignoreSelector) {
      var end, serialization, start;
      serialization = function(node, isEnd) {
        var n, nodes, offset, origParent, path, textNodes, _i, _len;
        if (ignoreSelector) {
          origParent = $(node).parents(":not(" + ignoreSelector + ")").eq(0);
        } else {
          origParent = $(node).parent();
        }
        path = xpath.fromNode(origParent, root)[0];
        textNodes = Util.getTextNodes(origParent);
        nodes = textNodes.slice(0, textNodes.index(node));
        offset = 0;
        for (_i = 0, _len = nodes.length; _i < _len; _i++) {
          n = nodes[_i];
          offset += n.nodeValue.length;
        }
        if (isEnd) {
          return [path, offset + node.nodeValue.length];
        } else {
          return [path, offset];
        }
      };
      start = serialization(this.start);
      end = serialization(this.end, true);
      return new Range.SerializedRange({
        start: start[0],
        end: end[0],
        startOffset: start[1],
        endOffset: end[1]
      });
    };

    NormalizedRange.prototype.text = function() {
      var node;
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = this.textNodes();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          _results.push(node.nodeValue);
        }
        return _results;
      }).call(this)).join('');
    };

    NormalizedRange.prototype.textNodes = function() {
      var end, start, textNodes, _ref;
      textNodes = Util.getTextNodes($(this.commonAncestor));
      _ref = [textNodes.index(this.start), textNodes.index(this.end)], start = _ref[0], end = _ref[1];
      return $.makeArray(textNodes.slice(start, +end + 1 || 9e9));
    };

    return NormalizedRange;

  })();

  Range.SerializedRange = (function() {
    function SerializedRange(obj) {
      this.start = obj.start;
      this.startOffset = obj.startOffset;
      this.end = obj.end;
      this.endOffset = obj.endOffset;
    }

    SerializedRange.prototype.normalize = function(root) {
      var contains, e, length, node, p, range, targetOffset, tn, _i, _j, _len, _len1, _ref, _ref1;
      range = {};
      _ref = ['start', 'end'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        try {
          node = xpath.toNode(this[p], root);
        } catch (_error) {
          e = _error;
          throw new Range.RangeError(p, ("Error while finding " + p + " node: " + this[p] + ": ") + e, e);
        }
        if (!node) {
          throw new Range.RangeError(p, "Couldn't find " + p + " node: " + this[p]);
        }
        length = 0;
        targetOffset = this[p + 'Offset'];
        if (p === 'end') {
          targetOffset -= 1;
        }
        _ref1 = Util.getTextNodes($(node));
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          tn = _ref1[_j];
          if (length + tn.nodeValue.length > targetOffset) {
            range[p + 'Container'] = tn;
            range[p + 'Offset'] = this[p + 'Offset'] - length;
            break;
          } else {
            length += tn.nodeValue.length;
          }
        }
        if (range[p + 'Offset'] == null) {
          throw new Range.RangeError("" + p + "offset", "Couldn't find offset " + this[p + 'Offset'] + " in element " + this[p]);
        }
      }
      contains = document.compareDocumentPosition != null ? function(a, b) {
        return a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_CONTAINED_BY;
      } : function(a, b) {
        return a.contains(b);
      };
      $(range.startContainer).parents().each(function() {
        var endContainer;
        if (range.endContainer.nodeType === Util.NodeTypes.TEXT_NODE) {
          endContainer = range.endContainer.parentNode;
        } else {
          endContainer = range.endContainer;
        }
        if (contains(this, endContainer)) {
          range.commonAncestorContainer = this;
          return false;
        }
      });
      return new Range.BrowserRange(range).normalize(root);
    };

    SerializedRange.prototype.serialize = function(root, ignoreSelector) {
      return this.normalize(root).serialize(root, ignoreSelector);
    };

    SerializedRange.prototype.toObject = function() {
      return {
        start: this.start,
        startOffset: this.startOffset,
        end: this.end,
        endOffset: this.endOffset
      };
    };

    return SerializedRange;

  })();

  module.exports = Range;

}).call(this);

},{"./util":20,"./xpath":21,"jquery":17}],20:[function(require,module,exports){
// Generated by CoffeeScript 1.7.1
(function() {
  var Util;

  Util = {};

  Util.NodeTypes = {
    ELEMENT_NODE: 1,
    ATTRIBUTE_NODE: 2,
    TEXT_NODE: 3,
    CDATA_SECTION_NODE: 4,
    ENTITY_REFERENCE_NODE: 5,
    ENTITY_NODE: 6,
    PROCESSING_INSTRUCTION_NODE: 7,
    COMMENT_NODE: 8,
    DOCUMENT_NODE: 9,
    DOCUMENT_TYPE_NODE: 10,
    DOCUMENT_FRAGMENT_NODE: 11,
    NOTATION_NODE: 12
  };

  Util.getFirstTextNodeNotBefore = function(n) {
    var result;
    switch (n.nodeType) {
      case Util.NodeTypes.TEXT_NODE:
        return n;
      case Util.NodeTypes.ELEMENT_NODE:
        if (n.firstChild != null) {
          result = Util.getFirstTextNodeNotBefore(n.firstChild);
          if (result != null) {
            return result;
          }
        }
        break;
    }
    n = n.nextSibling;
    if (n != null) {
      return Util.getFirstTextNodeNotBefore(n);
    } else {
      return null;
    }
  };

  Util.getLastTextNodeUpTo = function(n) {
    var result;
    switch (n.nodeType) {
      case Util.NodeTypes.TEXT_NODE:
        return n;
      case Util.NodeTypes.ELEMENT_NODE:
        if (n.lastChild != null) {
          result = Util.getLastTextNodeUpTo(n.lastChild);
          if (result != null) {
            return result;
          }
        }
        break;
    }
    n = n.previousSibling;
    if (n != null) {
      return Util.getLastTextNodeUpTo(n);
    } else {
      return null;
    }
  };

  Util.getTextNodes = function(jq) {
    var getTextNodes;
    getTextNodes = function(node) {
      var nodes;
      if (node && node.nodeType !== Util.NodeTypes.TEXT_NODE) {
        nodes = [];
        if (node.nodeType !== Util.NodeTypes.COMMENT_NODE) {
          node = node.lastChild;
          while (node) {
            nodes.push(getTextNodes(node));
            node = node.previousSibling;
          }
        }
        return nodes.reverse();
      } else {
        return node;
      }
    };
    return jq.map(function() {
      return Util.flatten(getTextNodes(this));
    });
  };

  Util.getGlobal = function() {
    return (function() {
      return this;
    })();
  };

  Util.contains = function(parent, child) {
    var node;
    node = child;
    while (node != null) {
      if (node === parent) {
        return true;
      }
      node = node.parentNode;
    }
    return false;
  };

  Util.flatten = function(array) {
    var flatten;
    flatten = function(ary) {
      var el, flat, _i, _len;
      flat = [];
      for (_i = 0, _len = ary.length; _i < _len; _i++) {
        el = ary[_i];
        flat = flat.concat(el && $.isArray(el) ? flatten(el) : el);
      }
      return flat;
    };
    return flatten(array);
  };

  module.exports = Util;

}).call(this);

},{"jquery":17}],21:[function(require,module,exports){
// Generated by CoffeeScript 1.7.1
(function() {
  var Util, evaluateXPath, findChild, fromNode, getNodeName, getNodePosition, simpleXPathJQuery, simpleXPathPure, toNode;

  Util = require('./util');

  evaluateXPath = function(xp, root, nsResolver) {
    var exception, idx, name, node, step, steps, _i, _len, _ref;
    if (root == null) {
      root = document;
    }
    if (nsResolver == null) {
      nsResolver = null;
    }
    try {
      return document.evaluate('.' + xp, root, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    } catch (_error) {
      exception = _error;
      console.log("XPath evaluation failed.");
      console.log("Trying fallback...");
      steps = xp.substring(1).split("/");
      node = root;
      for (_i = 0, _len = steps.length; _i < _len; _i++) {
        step = steps[_i];
        _ref = step.split("["), name = _ref[0], idx = _ref[1];
        idx = idx != null ? parseInt((idx != null ? idx.split("]") : void 0)[0]) : 1;
        node = findChild(node, name.toLowerCase(), idx);
      }
      return node;
    }
  };

  simpleXPathJQuery = function($el, relativeRoot) {
    var jq;
    jq = $el.map(function() {
      var elem, idx, path, tagName;
      path = '';
      elem = this;
      while ((elem != null ? elem.nodeType : void 0) === Util.NodeTypes.ELEMENT_NODE && elem !== relativeRoot) {
        tagName = elem.tagName.replace(":", "\\:");
        idx = $(elem.parentNode).children(tagName).index(elem) + 1;
        idx = "[" + idx + "]";
        path = "/" + elem.tagName.toLowerCase() + idx + path;
        elem = elem.parentNode;
      }
      return path;
    });
    return jq.get();
  };

  simpleXPathPure = function($el, relativeRoot) {
    var getPathSegment, getPathTo, jq, rootNode;
    getPathSegment = function(node) {
      var name, pos;
      name = getNodeName(node);
      pos = getNodePosition(node);
      return "" + name + "[" + pos + "]";
    };
    rootNode = relativeRoot;
    getPathTo = function(node) {
      var xpath;
      xpath = '';
      while (node !== rootNode) {
        if (node == null) {
          throw new Error("Called getPathTo on a node which was not a descendant of @rootNode. " + rootNode);
        }
        xpath = (getPathSegment(node)) + '/' + xpath;
        node = node.parentNode;
      }
      xpath = '/' + xpath;
      xpath = xpath.replace(/\/$/, '');
      return xpath;
    };
    jq = $el.map(function() {
      var path;
      path = getPathTo(this);
      return path;
    });
    return jq.get();
  };

  findChild = function(node, type, index) {
    var child, children, found, name, _i, _len;
    if (!node.hasChildNodes()) {
      throw new Error("XPath error: node has no children!");
    }
    children = node.childNodes;
    found = 0;
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      child = children[_i];
      name = getNodeName(child);
      if (name === type) {
        found += 1;
        if (found === index) {
          return child;
        }
      }
    }
    throw new Error("XPath error: wanted child not found.");
  };

  getNodeName = function(node) {
    var nodeName;
    nodeName = node.nodeName.toLowerCase();
    switch (nodeName) {
      case "#text":
        return "text()";
      case "#comment":
        return "comment()";
      case "#cdata-section":
        return "cdata-section()";
      default:
        return nodeName;
    }
  };

  getNodePosition = function(node) {
    var pos, tmp;
    pos = 0;
    tmp = node;
    while (tmp) {
      if (tmp.nodeName === node.nodeName) {
        pos += 1;
      }
      tmp = tmp.previousSibling;
    }
    return pos;
  };

  fromNode = function($el, relativeRoot) {
    var exception, result;
    try {
      result = simpleXPathJQuery($el, relativeRoot);
    } catch (_error) {
      exception = _error;
      console.log("jQuery-based XPath construction failed! Falling back to manual.");
      result = simpleXPathPure($el, relativeRoot);
    }
    return result;
  };

  toNode = function(path, root) {
    var customResolver, namespace, node, segment;
    if (root == null) {
      root = document;
    }
    if (!$.isXMLDoc(document.documentElement)) {
      return evaluateXPath(path, root);
    } else {
      customResolver = document.createNSResolver(document.ownerDocument === null ? document.documentElement : document.ownerDocument.documentElement);
      node = evaluateXPath(path, root, customResolver);
      if (!node) {
        path = ((function() {
          var _i, _len, _ref, _results;
          _ref = path.split('/');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            segment = _ref[_i];
            if (segment && segment.indexOf(':') === -1) {
              _results.push(segment.replace(/^([a-z]+)/, 'xhtml:$1'));
            } else {
              _results.push(segment);
            }
          }
          return _results;
        })()).join('/');
        namespace = document.lookupNamespaceURI(null);
        customResolver = function(ns) {
          if (ns === 'xhtml') {
            return namespace;
          } else {
            return document.documentElement.getAttribute('xmlns:' + ns);
          }
        };
        node = evaluateXPath(path, root, customResolver);
      }
      return node;
    }
  };

  module.exports = {
    fromNode: fromNode,
    toNode: toNode
  };

}).call(this);

},{"./util":20,"jquery":17}],22:[function(require,module,exports){
/*package annotator */

"use strict";

var extend = require('backbone-extend-standalone');
var Promise = require('es6-promise').Promise;

var authz = require('./authz');
var identity = require('./identity');
var notification = require('./notification');
var registry = require('./registry');
var storage = require('./storage');

/**
 * class:: App()
 *
 * App is the coordination point for all annotation functionality. App instances
 * manage the configuration of a particular annotation application, and are the
 * starting point for most deployments of Annotator.
 */
function App() {
    this.modules = [];
    this.registry = new registry.Registry();

    this._started = false;

    // Register a bunch of default utilities
    this.registry.registerUtility(notification.defaultNotifier,
                                  'notifier');

    // And set up default components.
    this.include(authz.acl);
    this.include(identity.simple);
    this.include(storage.noop);
}


/**
 * function:: App.prototype.include(module[, options])
 *
 * Include an extension module. If an `options` object is supplied, it will be
 * passed to the module at initialisation.
 *
 * If the returned module instance has a `configure` function, this will be
 * called with the application registry as a parameter.
 *
 * :param Object module:
 * :param Object options:
 * :returns: Itself.
 * :rtype: App
 */
App.prototype.include = function (module, options) {
    var mod = module(options);
    if (typeof mod.configure === 'function') {
        mod.configure(this.registry);
    }
    this.modules.push(mod);
    return this;
};


/**
 * function:: App.prototype.start()
 *
 * Tell the app that configuration is complete. This binds the various
 * components passed to the registry to their canonical names so they can be
 * used by the rest of the application.
 *
 * Runs the 'start' module hook.
 *
 * :returns: A promise, resolved when all module 'start' hooks have completed.
 * :rtype: Promise
 */
App.prototype.start = function () {
    if (this._started) {
        return;
    }
    this._started = true;

    var self = this;
    var reg = this.registry;

    this.authz = reg.getUtility('authorizationPolicy');
    this.ident = reg.getUtility('identityPolicy');
    this.notify = reg.getUtility('notifier');

    this.annotations = new storage.StorageAdapter(
        reg.getUtility('storage'),
        function () {
            return self.runHook.apply(self, arguments);
        }
    );

    return this.runHook('start', [this]);
};


/**
 * function:: App.prototype.destroy()
 *
 * Destroy the App. Unbinds all event handlers and runs the 'destroy' module
 * hook.
 *
 * :returns: A promise, resolved when destroyed.
 * :rtype: Promise
 */
App.prototype.destroy = function () {
    return this.runHook('destroy');
};


/**
 * function:: App.prototype.runHook(name[, args])
 *
 * Run the named module hook and return a promise of the results of all the hook
 * functions. You won't usually need to run this yourself unless you are
 * extending the base functionality of App.
 *
 * Optionally accepts an array of argument (`args`) to pass to each hook
 * function.
 *
 * :returns: A promise, resolved when all hooks are complete.
 * :rtype: Promise
 */
App.prototype.runHook = function (name, args) {
    var results = [];
    for (var i = 0, len = this.modules.length; i < len; i++) {
        var mod = this.modules[i];
        if (typeof mod[name] === 'function') {
            results.push(mod[name].apply(mod, args));
        }
    }
    return Promise.all(results);
};


/**
 * function:: App.extend(object)
 *
 * Create a new object that inherits from the App class.
 *
 * For example, here we create a ``CustomApp`` that will include the
 * hypothetical ``mymodules.foo.bar`` module depending on the options object
 * passed into the constructor::
 *
 *     var CustomApp = annotator.App.extend({
 *         constructor: function (options) {
 *             App.apply(this);
 *             if (options.foo === 'bar') {
 *                 this.include(mymodules.foo.bar);
 *             }
 *         }
 *     });
 *
 *     var app = new CustomApp({foo: 'bar'});
 *
 * :returns: The subclass constructor.
 * :rtype: Function
 */
App.extend = extend;


exports.App = App;

},{"./authz":23,"./identity":24,"./notification":25,"./registry":26,"./storage":27,"backbone-extend-standalone":3,"es6-promise":5}],23:[function(require,module,exports){
/*package annotator.authz */

"use strict";

var AclAuthzPolicy;


/**
 * function:: acl()
 *
 * A module that configures and registers an instance of
 * :class:`annotator.authz.AclAuthzPolicy`.
 *
 */
exports.acl = function acl() {
    var authorization = new AclAuthzPolicy();

    return {
        configure: function (registry) {
            registry.registerUtility(authorization, 'authorizationPolicy');
        }
    };
};


/**
 * class:: AclAuthzPolicy()
 *
 * An authorization policy that permits actions based on access control lists.
 *
 */
AclAuthzPolicy = exports.AclAuthzPolicy = function AclAuthzPolicy() {
};


/**
 * function:: AclAuthzPolicy.prototype.permits(action, context, identity)
 *
 * Determines whether the user identified by `identity` is permitted to
 * perform the specified action in the given context.
 *
 * If the context has a "permissions" object property, then actions will
 * be permitted if either of the following are true:
 *
 *   a) permissions[action] is undefined or null,
 *   b) permissions[action] is an Array containing the authorized userid
 *      for the given identity.
 *
 * If the context has no permissions associated with it then all actions
 * will be permitted.
 *
 * If the annotation has a "user" property, then actions will be permitted
 * only if `identity` matches this "user" property.
 *
 * If the annotation has neither a "permissions" property nor a "user"
 * property, then all actions will be permitted.
 *
 * :param String action: The action to perform.
 * :param context: The permissions context for the authorization check.
 * :param identity: The identity whose authorization is being checked.
 *
 * :returns Boolean: Whether the action is permitted in this context for this
 * identity.
 */
AclAuthzPolicy.prototype.permits = function (action, context, identity) {
    var userid = this.authorizedUserId(identity);
    var permissions = context.permissions;

    if (permissions) {
        // Fine-grained authorization on permissions field
        var tokens = permissions[action];

        if (typeof tokens === 'undefined' || tokens === null) {
            // Missing tokens array for this action: anyone can perform
            // action.
            return true;
        }

        for (var i = 0, len = tokens.length; i < len; i++) {
            if (userid === tokens[i]) {
                return true;
            }
        }

        // No tokens matched: action should not be performed.
        return false;
    } else if (context.user) {
        // Coarse-grained authorization
        return userid === context.user;
    }

    // No authorization info on context: free-for-all!
    return true;
};


/**
 * function:: AclAuthzPolicy.prototype.authorizedUserId(identity)
 *
 * Returns the authorized userid for the user identified by `identity`.
 */
AclAuthzPolicy.prototype.authorizedUserId = function (identity) {
    return identity;
};

},{}],24:[function(require,module,exports){
/*package annotator.identity */

"use strict";


var SimpleIdentityPolicy;


/**
 * function:: simple()
 *
 * A module that configures and registers an instance of
 * :class:`annotator.identity.SimpleIdentityPolicy`.
 */
exports.simple = function simple() {
    var identity = new SimpleIdentityPolicy();

    return {
        configure: function (registry) {
            registry.registerUtility(identity, 'identityPolicy');
        }
    };
};


/**
 * class:: SimpleIdentityPolicy
 *
 * A simple identity policy that considers the identity to be an opaque
 * identifier.
 */
SimpleIdentityPolicy = function SimpleIdentityPolicy() {
    /**
     * data:: SimpleIdentityPolicy.identity
     *
     * Default identity. Defaults to `null`, which disables identity-related
     * functionality.
     *
     * This is not part of the identity policy public interface, but provides a
     * simple way for you to set a fixed current user::
     *
     *     app.ident.identity = 'bob';
     */
    this.identity = null;
};
exports.SimpleIdentityPolicy = SimpleIdentityPolicy;


/**
 * function:: SimpleIdentityPolicy.prototype.who()
 *
 * Returns the current user identity.
 */
SimpleIdentityPolicy.prototype.who = function () {
    return this.identity;
};

},{}],25:[function(require,module,exports){
(function (global){
/*package annotator.notifier */

"use strict";

var util = require('./util');
var $ = util.$;

var INFO = 'info',
    SUCCESS = 'success',
    ERROR = 'error';

var bannerTemplate = "<div class='annotator-notice'></div>";
var bannerClasses = {
    show: "annotator-notice-show",
    info: "annotator-notice-info",
    success: "annotator-notice-success",
    error: "annotator-notice-error"
};


/**
 * function:: banner(message[, severity=notification.INFO])
 *
 * Creates a user-visible banner notification that can be used to display
 * information, warnings and errors to the user.
 *
 * :param String message: The notice message text.
 * :param severity:
 *    The severity of the notice (one of `notification.INFO`,
 *    `notification.SUCCESS`, or `notification.ERROR`)
 *
 * :returns:
 *   An object with a `close` method that can be used to close the banner.
 */
function banner(message, severity) {
    if (typeof severity === 'undefined' || severity === null) {
        severity = INFO;
    }

    var element = $(bannerTemplate)[0];
    var closed = false;

    var close = function () {
        if (closed) { return; }

        closed = true;

        $(element)
            .removeClass(bannerClasses.show)
            .removeClass(bannerClasses[severity]);

        // The removal of the above classes triggers a 400ms ease-out
        // transition, so we can dispose the element from the DOM after
        // 500ms.
        setTimeout(function () {
            $(element).remove();
        }, 500);
    };

    $(element)
        .addClass(bannerClasses.show)
        .addClass(bannerClasses[severity])
        .html(util.escapeHtml(message || ""))
        .appendTo(global.document.body);

    $(element).on('click', close);

    // Hide the notifier after 5s
    setTimeout(close, 5000);

    return {
        close: close
    };
}


exports.banner = banner;
exports.defaultNotifier = banner;

exports.INFO = INFO;
exports.SUCCESS = SUCCESS;
exports.ERROR = ERROR;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./util":39}],26:[function(require,module,exports){
/*package annotator.registry */

"use strict";

/**
 * class:: Registry()
 *
 * `Registry` is an application registry. It serves as a place to register and
 * find shared components in a running :class:`annotator.App`.
 *
 * You won't usually create your own `Registry` -- one will be created for you
 * by the :class:`~annotator.App`. If you are writing an Annotator module, you
 * can use the registry to provide or override a component of the Annotator
 * application.
 *
 * For example, if you are writing a module that overrides the "storage"
 * component, you will use the registry in your module's `configure` function to
 * register your component::
 *
 *     function myStorage () {
 *         return {
 *             configure: function (registry) {
 *                 registry.registerUtility(this, 'storage');
 *             },
 *             ...
 *         };
 *     }
 */
function Registry() {
    this.utilities = {};
}

/**
 * function:: Registry.prototype.registerUtility(component, iface)
 *
 * Register component `component` as an implementer of interface `iface`.
 *
 * :param component: The component to register.
 * :param string iface: The name of the interface.
 */
Registry.prototype.registerUtility = function (component, iface) {
    this.utilities[iface] = component;
};

/**
 * function:: Registry.prototype.getUtility(iface)
 *
 * Get component implementing interface `iface`.
 *
 * :param string iface: The name of the interface.
 * :returns: Component matching `iface`.
 * :throws LookupError: If no component is found for interface `iface`.
 */
Registry.prototype.getUtility = function (iface) {
    var component = this.queryUtility(iface);
    if (component === null) {
        throw new LookupError(iface);
    }
    return component;
};

/**
 * function:: Registry.prototype.queryUtility(iface)
 *
 * Get component implementing interface `iface`. Returns `null` if no matching
 * component is found.
 *
 * :param string iface: The name of the interface.
 * :returns: Component matching `iface`, if found; `null` otherwise.
 */
Registry.prototype.queryUtility = function (iface) {
    var component = this.utilities[iface];
    if (typeof component === 'undefined' || component === null) {
        return null;
    }
    return component;
};


/**
 * class:: LookupError(iface)
 *
 * The error thrown when a registry component lookup fails.
 */
function LookupError(iface) {
    this.name = 'LookupError';
    this.message = 'No utility registered for interface "' + iface + '".';
}
LookupError.prototype = Object.create(Error.prototype);
LookupError.prototype.constructor = LookupError;

exports.LookupError = LookupError;
exports.Registry = Registry;

},{}],27:[function(require,module,exports){
/*package annotator.storage */

"use strict";

var util = require('./util');
var $ = util.$;
var _t = util.gettext;
var Promise = util.Promise;


// id returns an identifier unique within this session
var id = (function () {
    var counter;
    counter = -1;
    return function () {
        return counter += 1;
    };
}());


/**
 * function:: debug()
 *
 * A storage component that can be used to print details of the annotation
 * persistence processes to the console when developing other parts of
 * Annotator.
 *
 * Use as an extension module::
 *
 *     app.include(annotator.storage.debug);
 *
 */
exports.debug = function () {
    function trace(action, annotation) {
        var copyAnno = JSON.parse(JSON.stringify(annotation));
        console.debug("annotator.storage.debug: " + action, copyAnno);
    }

    return {
        create: function (annotation) {
            annotation.id = id();
            trace('create', annotation);
            return annotation;
        },

        update: function (annotation) {
            trace('update', annotation);
            return annotation;
        },

        'delete': function (annotation) {
            trace('destroy', annotation);
            return annotation;
        },

        query: function (queryObj) {
            trace('query', queryObj);
            return {results: [], meta: {total: 0}};
        },

        configure: function (registry) {
            registry.registerUtility(this, 'storage');
        }
    };
};


/**
 * function:: noop()
 *
 * A no-op storage component. It swallows all calls and does the bare minimum
 * needed. Needless to say, it does not provide any real persistence.
 *
 * Use as a extension module::
 *
 *     app.include(annotator.storage.noop);
 *
 */
exports.noop = function () {
    return {
        create: function (annotation) {
            if (typeof annotation.id === 'undefined' ||
                annotation.id === null) {
                annotation.id = id();
            }
            return annotation;
        },

        update: function (annotation) {
            return annotation;
        },

        'delete': function (annotation) {
            return annotation;
        },

        query: function () {
            return {results: []};
        },

        configure: function (registry) {
            registry.registerUtility(this, 'storage');
        }
    };
};


var HttpStorage;


/**
 * function:: http([options])
 *
 * A module which configures an instance of
 * :class:`annotator.storage.HttpStorage` as the storage component.
 *
 * :param Object options:
 *   Configuration options. For available options see
 *   :attr:`~annotator.storage.HttpStorage.options`.
 */
exports.http = function http(options) {
    // This gets overridden on app start
    var notify = function () {};

    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    // Use the notifier unless an onError handler has been set.
    options.onError = options.onError || function (msg, xhr) {
        console.error(msg, xhr);
        notify(msg, 'error');
    };

    var storage = new HttpStorage(options);

    return {
        configure: function (registry) {
            registry.registerUtility(storage, 'storage');
        },

        start: function (app) {
            notify = app.notify;
        }
    };
};


/**
 * class:: HttpStorage([options])
 *
 * HttpStorage is a storage component that talks to a remote JSON + HTTP API
 * that should be relatively easy to implement with any web application
 * framework.
 *
 * :param Object options: See :attr:`~annotator.storage.HttpStorage.options`.
 */
HttpStorage = exports.HttpStorage = function HttpStorage(options) {
    this.options = $.extend(true, {}, HttpStorage.options, options);
    this.onError = this.options.onError;
};

/**
 * function:: HttpStorage.prototype.create(annotation)
 *
 * Create an annotation.
 *
 * **Examples**::
 *
 *     store.create({text: "my new annotation comment"})
 *     // => Results in an HTTP POST request to the server containing the
 *     //    annotation as serialised JSON.
 *
 * :param Object annotation: An annotation.
 * :returns: The request object.
 * :rtype: Promise
 */
HttpStorage.prototype.create = function (annotation) {
    return this._apiRequest('create', annotation);
};

/**
 * function:: HttpStorage.prototype.update(annotation)
 *
 * Update an annotation.
 *
 * **Examples**::
 *
 *     store.update({id: "blah", text: "updated annotation comment"})
 *     // => Results in an HTTP PUT request to the server containing the
 *     //    annotation as serialised JSON.
 *
 * :param Object annotation: An annotation. Must contain an `id`.
 * :returns: The request object.
 * :rtype: Promise
 */
HttpStorage.prototype.update = function (annotation) {
    return this._apiRequest('update', annotation);
};

/**
 * function:: HttpStorage.prototype.delete(annotation)
 *
 * Delete an annotation.
 *
 * **Examples**::
 *
 *     store.delete({id: "blah"})
 *     // => Results in an HTTP DELETE request to the server.
 *
 * :param Object annotation: An annotation. Must contain an `id`.
 * :returns: The request object.
 * :rtype: Promise
 */
HttpStorage.prototype['delete'] = function (annotation) {
    return this._apiRequest('destroy', annotation);
};

/**
 * function:: HttpStorage.prototype.query(queryObj)
 *
 * Searches for annotations matching the specified query.
 *
 * :param Object queryObj: An object describing the query.
 * :returns:
 *   A promise, resolves to an object containing query `results` and `meta`.
 * :rtype: Promise
 */
HttpStorage.prototype.query = function (queryObj) {
    return this._apiRequest('search', queryObj)
    .then(function (obj) {
        var rows = obj.rows;
        delete obj.rows;
        return {results: rows, meta: obj};
    });
};

/**
 * function:: HttpStorage.prototype.setHeader(name, value)
 *
 * Set a custom HTTP header to be sent with every request.
 *
 * **Examples**::
 *
 *     store.setHeader('X-My-Custom-Header', 'MyCustomValue')
 *
 * :param string name: The header name.
 * :param string value: The header value.
 */
HttpStorage.prototype.setHeader = function (key, value) {
    this.options.headers[key] = value;
};

/*
 * Helper method to build an XHR request for a specified action and
 * object.
 *
 * :param String action: The action: "search", "create", "update" or "destroy".
 * :param obj: The data to be sent, either annotation object or query string.
 *
 * :returns: The request object.
 * :rtype: jqXHR
 */
HttpStorage.prototype._apiRequest = function (action, obj) {
    var id = obj && obj.id;
    var url = this._urlFor(action, id);
    var options = this._apiRequestOptions(action, obj);

    var request = $.ajax(url, options);

    // Append the id and action to the request object
    // for use in the error callback.
    request._id = id;
    request._action = action;
    return request;
};

/*
 * Builds an options object suitable for use in a jQuery.ajax() call.
 *
 * :param String action: The action: "search", "create", "update" or "destroy".
 * :param obj: The data to be sent, either annotation object or query string.
 *
 * :returns: $.ajax() options.
 * :rtype: Object
 */
HttpStorage.prototype._apiRequestOptions = function (action, obj) {
    var method = this._methodFor(action);
    var self = this;

    var opts = {
        type: method,
        dataType: "json",
        error: function () { self._onError.apply(self, arguments); },
        headers: this.options.headers
    };

    // If emulateHTTP is enabled, we send a POST and put the real method in an
    // HTTP request header.
    if (this.options.emulateHTTP && (method === 'PUT' || method === 'DELETE')) {
        opts.headers = $.extend(opts.headers, {
            'X-HTTP-Method-Override': method
        });
        opts.type = 'POST';
    }

    // Don't JSONify obj if making search request.
    if (action === "search") {
        opts = $.extend(opts, {data: obj});
        return opts;
    }

    var data = obj && JSON.stringify(obj);

    // If emulateJSON is enabled, we send a form request (the correct
    // contentType will be set automatically by jQuery), and put the
    // JSON-encoded payload in the "json" key.
    if (this.options.emulateJSON) {
        opts.data = {json: data};
        if (this.options.emulateHTTP) {
            opts.data._method = method;
        }
        return opts;
    }

    opts = $.extend(opts, {
        data: data,
        contentType: "application/json; charset=utf-8"
    });
    return opts;
};

/*
 * Builds the appropriate URL from the options for the action provided.
 *
 * :param String action:
 * :param id: The annotation id as a String or Number.
 *
 * :returns String: URL for the request.
 */
HttpStorage.prototype._urlFor = function (action, id) {
    if (typeof id === 'undefined' || id === null) {
        id = '';
    }

    var url = '';
    if (typeof this.options.prefix !== 'undefined' &&
        this.options.prefix !== null) {
        url = this.options.prefix;
    }

    url += this.options.urls[action];
    // If there's an '{id}' in the URL, then fill in the ID.
    url = url.replace(/\{id\}/, id);
    return url;
};

/*
 * Maps an action to an HTTP method.
 *
 * :param String action:
 * :returns String: Method for the request.
 */
HttpStorage.prototype._methodFor = function (action) {
    var table = {
        create: 'POST',
        update: 'PUT',
        destroy: 'DELETE',
        search: 'GET'
    };

    return table[action];
};

/*
 * jQuery.ajax() callback. Displays an error notification to the user if
 * the request failed.
 *
 * :param jqXHR: The jqXMLHttpRequest object.
 */
HttpStorage.prototype._onError = function (xhr) {
    if (typeof this.onError !== 'function') {
        return;
    }

    var message;
    if (xhr.status === 400) {
        message = _t("The annotation store did not understand the request! " +
                     "(Error 400)");
    } else if (xhr.status === 401) {
        message = _t("You must be logged in to perform this operation! " +
                     "(Error 401)");
    } else if (xhr.status === 403) {
        message = _t("You don't have permission to perform this operation! " +
                     "(Error 403)");
    } else if (xhr.status === 404) {
        message = _t("Could not connect to the annotation store! " +
                     "(Error 404)");
    } else if (xhr.status === 500) {
        message = _t("Internal error in annotation store! " +
                     "(Error 500)");
    } else {
        message = _t("Unknown error while speaking to annotation store!");
    }
    this.onError(message, xhr);
};

/**
 * attribute:: HttpStorage.options
 *
 * Available configuration options for HttpStorage. See below.
 */
HttpStorage.options = {
    /**
     * attribute:: HttpStorage.options.emulateHTTP
     *
     * Should the storage emulate HTTP methods like PUT and DELETE for
     * interaction with legacy web servers? Setting this to `true` will fake
     * HTTP `PUT` and `DELETE` requests with an HTTP `POST`, and will set the
     * request header `X-HTTP-Method-Override` with the name of the desired
     * method.
     *
     * **Default**: ``false``
     */
    emulateHTTP: false,

    /**
     * attribute:: HttpStorage.options.emulateJSON
     *
     * Should the storage emulate JSON POST/PUT payloads by sending its requests
     * as application/x-www-form-urlencoded with a single key, "json"
     *
     * **Default**: ``false``
     */
    emulateJSON: false,

    /**
     * attribute:: HttpStorage.options.headers
     *
     * A set of custom headers that will be sent with every request. See also
     * the setHeader method.
     *
     * **Default**: ``{}``
     */
    headers: {},

    /**
     * attribute:: HttpStorage.options.onError
     *
     * Callback, called if a remote request throws an error.
     */
    onError: function (message) {
        console.error("API request failed: " + message);
    },

    /**
     * attribute:: HttpStorage.options.prefix
     *
     * This is the API endpoint. If the server supports Cross Origin Resource
     * Sharing (CORS) a full URL can be used here.
     *
     * **Default**: ``'/store'``
     */
    prefix: '/store',

    /**
     * attribute:: HttpStorage.options.urls
     *
     * The server URLs for each available action. These URLs can be anything but
     * must respond to the appropriate HTTP method. The URLs are Level 1 URI
     * Templates as defined in RFC6570:
     *
     *    http://tools.ietf.org/html/rfc6570#section-1.2
     *
     *  **Default**::
     *
     *      {
     *          create: '/annotations',
     *          update: '/annotations/{id}',
     *          destroy: '/annotations/{id}',
     *          search: '/search'
     *      }
     */
    urls: {
        create: '/annotations',
        update: '/annotations/{id}',
        destroy: '/annotations/{id}',
        search: '/search'
    }
};


/**
 * class:: StorageAdapter(store, runHook)
 *
 * StorageAdapter wraps a concrete implementation of the Storage interface, and
 * ensures that the appropriate hooks are fired when annotations are created,
 * updated, deleted, etc.
 *
 * :param store: The Store implementation which manages persistence
 * :param Function runHook: A function which can be used to run lifecycle hooks
 */
function StorageAdapter(store, runHook) {
    this.store = store;
    this.runHook = runHook;
}

/**
 * function:: StorageAdapter.prototype.create(obj)
 *
 * Creates and returns a new annotation object.
 *
 * Runs the 'beforeAnnotationCreated' hook to allow the new annotation to be
 * initialized or its creation prevented.
 *
 * Runs the 'annotationCreated' hook when the new annotation has been created
 * by the store.
 *
 * **Examples**:
 *
 * ::
 *
 *     registry.on('beforeAnnotationCreated', function (annotation) {
 *         annotation.myProperty = 'This is a custom property';
 *     });
 *     registry.create({}); // Resolves to {myProperty: "This is a…"}
 *
 *
 * :param Object annotation: An object from which to create an annotation.
 * :returns Promise: Resolves to annotation object when stored.
 */
StorageAdapter.prototype.create = function (obj) {
    if (typeof obj === 'undefined' || obj === null) {
        obj = {};
    }
    return this._cycle(
        obj,
        'create',
        'beforeAnnotationCreated',
        'annotationCreated'
    );
};

/**
 * function:: StorageAdapter.prototype.update(obj)
 *
 * Updates an annotation.
 *
 * Runs the 'beforeAnnotationUpdated' hook to allow an annotation to be
 * modified before being passed to the store, or for an update to be prevented.
 *
 * Runs the 'annotationUpdated' hook when the annotation has been updated by
 * the store.
 *
 * **Examples**:
 *
 * ::
 *
 *     annotation = {tags: 'apples oranges pears'};
 *     registry.on('beforeAnnotationUpdated', function (annotation) {
 *         // validate or modify a property.
 *         annotation.tags = annotation.tags.split(' ')
 *     });
 *     registry.update(annotation)
 *     // => Resolves to {tags: ["apples", "oranges", "pears"]}
 *
 * :param Object annotation: An annotation object to update.
 * :returns Promise: Resolves to annotation object when stored.
 */
StorageAdapter.prototype.update = function (obj) {
    if (typeof obj.id === 'undefined' || obj.id === null) {
        throw new TypeError("annotation must have an id for update()");
    }
    return this._cycle(
        obj,
        'update',
        'beforeAnnotationUpdated',
        'annotationUpdated'
    );
};

/**
 * function:: StorageAdapter.prototype.delete(obj)
 *
 * Deletes the annotation.
 *
 * Runs the 'beforeAnnotationDeleted' hook to allow an annotation to be
 * modified before being passed to the store, or for the a deletion to be
 * prevented.
 *
 * Runs the 'annotationDeleted' hook when the annotation has been deleted by
 * the store.
 *
 * :param Object annotation: An annotation object to delete.
 * :returns Promise: Resolves to annotation object when deleted.
 */
StorageAdapter.prototype['delete'] = function (obj) {
    if (typeof obj.id === 'undefined' || obj.id === null) {
        throw new TypeError("annotation must have an id for delete()");
    }
    return this._cycle(
        obj,
        'delete',
        'beforeAnnotationDeleted',
        'annotationDeleted'
    );
};

/**
 * function:: StorageAdapter.prototype.query(query)
 *
 * Queries the store
 *
 * :param Object query:
 *   A query. This may be interpreted differently by different stores.
 *
 * :returns Promise: Resolves to the store return value.
 */
StorageAdapter.prototype.query = function (query) {
    return Promise.resolve(this.store.query(query));
};

/**
 * function:: StorageAdapter.prototype.load(query)
 *
 * Load and draw annotations from a given query.
 *
 * Runs the 'load' hook to allow modules to respond to annotations being loaded.
 *
 * :param Object query:
 *   A query. This may be interpreted differently by different stores.
 *
 * :returns Promise: Resolves when loading is complete.
 */
StorageAdapter.prototype.load = function (query) {
    var self = this;
    return this.query(query)
        .then(function (data) {
            self.runHook('annotationsLoaded', [data.results]);
        });
};

// Cycle a store event, keeping track of the annotation object and updating it
// as necessary.
StorageAdapter.prototype._cycle = function (
    obj,
    storeFunc,
    beforeEvent,
    afterEvent
) {
    var self = this;
    return this.runHook(beforeEvent, [obj])
        .then(function () {
            var safeCopy = $.extend(true, {}, obj);
            delete safeCopy._local;

            // We use Promise.resolve() to coerce the result of the store
            // function, which can be either a value or a promise, to a promise.
            var result = self.store[storeFunc](safeCopy);
            return Promise.resolve(result);
        })
        .then(function (ret) {
            // Empty obj without changing identity
            for (var k in obj) {
                if (obj.hasOwnProperty(k)) {
                    if (k !== '_local') {
                        delete obj[k];
                    }
                }
            }

            // Update with store return value
            $.extend(obj, ret);
            self.runHook(afterEvent, [obj]);
            return obj;
        });
};

exports.StorageAdapter = StorageAdapter;

},{"./util":39}],28:[function(require,module,exports){
// Main module: default UI
exports.main = require('./ui/main').main;

// Export submodules for browser environments
exports.adder = require('./ui/adder');
exports.editor = require('./ui/editor');
exports.filter = require('./ui/filter');
exports.highlighter = require('./ui/highlighter');
exports.markdown = require('./ui/markdown');
exports.tags = require('./ui/tags');
exports.textselector = require('./ui/textselector');
exports.viewer = require('./ui/viewer');
exports.widget = require('./ui/widget');

},{"./ui/adder":29,"./ui/editor":30,"./ui/filter":31,"./ui/highlighter":32,"./ui/main":33,"./ui/markdown":34,"./ui/tags":35,"./ui/textselector":36,"./ui/viewer":37,"./ui/widget":38}],29:[function(require,module,exports){
"use strict";

var Widget = require('./widget').Widget,
    util = require('../util');

var $ = util.$;
var _t = util.gettext;

var NS = 'annotator-adder';


// Adder shows and hides an annotation adder button that can be clicked on to
// create an annotation.
var Adder = Widget.extend({

    constructor: function (options) {
        Widget.call(this, options);

        this.ignoreMouseup = false;
        this.annotation = null;

        this.onCreate = this.options.onCreate;

        var self = this;
        this.element
            .on("click." + NS, 'button', function (e) {
                self._onClick(e);
            })
            .on("mousedown." + NS, 'button', function (e) {
                self._onMousedown(e);
            });

        this.document = this.element[0].ownerDocument;
        $(this.document.body).on("mouseup." + NS, function (e) {
            self._onMouseup(e);
        });
    },

    destroy: function () {
        this.element.off("." + NS);
        $(this.document.body).off("." + NS);
        Widget.prototype.destroy.call(this);
    },

    // Public: Load an annotation and show the adder.
    //
    // annotation - An annotation Object to load.
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // If the user clicks on the adder with an annotation loaded, the onCreate
    // handler will be called. In this way, the adder can serve as an
    // intermediary step between making a selection and creating an annotation.
    //
    // Returns nothing.
    load: function (annotation, position) {
        this.annotation = annotation;
        this.show(position);
    },

    // Public: Show the adder.
    //
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Examples
    //
    //   adder.show()
    //   adder.hide()
    //   adder.show({top: '100px', left: '80px'})
    //
    // Returns nothing.
    show: function (position) {
        if (typeof position !== 'undefined' && position !== null) {
            this.element.css({
                top: position.top,
                left: position.left
            });
        }
        Widget.prototype.show.call(this);
    },

    // Event callback: called when the mouse button is depressed on the adder.
    //
    // event - A mousedown Event object
    //
    // Returns nothing.
    _onMousedown: function (event) {
        // Do nothing for right-clicks, middle-clicks, etc.
        if (event.which > 1) {
            return;
        }

        event.preventDefault();
        // Prevent the selection code from firing when the mouse button is
        // released
        this.ignoreMouseup = true;
    },

    // Event callback: called when the mouse button is released
    //
    // event - A mouseup Event object
    //
    // Returns nothing.
    _onMouseup: function (event) {
        // Do nothing for right-clicks, middle-clicks, etc.
        if (event.which > 1) {
            return;
        }

        // Prevent the selection code from firing when the ignoreMouseup flag is
        // set
        if (this.ignoreMouseup) {
            event.stopImmediatePropagation();
        }
    },

    // Event callback: called when the adder is clicked. The click event is used
    // as well as the mousedown so that we get the :active state on the adder
    // when clicked.
    //
    // event - A mousedown Event object
    //
    // Returns nothing.
    _onClick: function (event) {
        // Do nothing for right-clicks, middle-clicks, etc.
        if (event.which > 1) {
            return;
        }

        event.preventDefault();

        // Hide the adder
        this.hide();
        this.ignoreMouseup = false;

        // Create a new annotation
        if (this.annotation !== null && typeof this.onCreate === 'function') {
            this.onCreate(this.annotation, event);
        }
    }
});

Adder.template = [
    '<div class="annotator-adder annotator-hide">',
    '  <button type="button">' + _t('Annotate') + '</button>',
    '</div>'
].join('\n');

// Configuration options
Adder.options = {
    // Callback, called when the user clicks the adder when an
    // annotation is loaded.
    onCreate: null
};


exports.Adder = Adder;

},{"../util":39,"./widget":38}],30:[function(require,module,exports){
"use strict";

var Widget = require('./widget').Widget,
    util = require('../util');

var $ = util.$;
var _t = util.gettext;
var Promise = util.Promise;

var NS = "annotator-editor";


// id returns an identifier unique within this session
var id = (function () {
    var counter;
    counter = -1;
    return function () {
        return counter += 1;
    };
}());


// preventEventDefault prevents an event's default, but handles the condition
// that the event is null or doesn't have a preventDefault function.
function preventEventDefault(event) {
    if (typeof event !== 'undefined' &&
        event !== null &&
        typeof event.preventDefault === 'function') {
        event.preventDefault();
    }
}


// dragTracker is a function which allows a callback to track changes made to
// the position of a draggable "handle" element.
//
// handle - A DOM element to make draggable
// callback - Callback function
//
// Callback arguments:
//
// delta - An Object with two properties, "x" and "y", denoting the amount the
//         mouse has moved since the last (tracked) call.
//
// Callback returns: Boolean indicating whether to track the last movement. If
// the movement is not tracked, then the amount the mouse has moved will be
// accumulated and passed to the next mousemove event.
//
var dragTracker = exports.dragTracker = function dragTracker(handle, callback) {
    var lastPos = null,
        throttled = false;

    // Event handler for mousemove
    function mouseMove(e) {
        if (throttled || lastPos === null) {
            return;
        }

        var delta = {
            y: e.pageY - lastPos.top,
            x: e.pageX - lastPos.left
        };

        var trackLastMove = true;
        // The callback function can return false to indicate that the tracker
        // shouldn't keep updating the last position. This can be used to
        // implement "walls" beyond which (for example) resizing has no effect.
        if (typeof callback === 'function') {
            trackLastMove = callback(delta);
        }

        if (trackLastMove !== false) {
            lastPos = {
                top: e.pageY,
                left: e.pageX
            };
        }

        // Throttle repeated mousemove events
        throttled = true;
        setTimeout(function () { throttled = false; }, 1000 / 60);
    }

    // Event handler for mouseup
    function mouseUp() {
        lastPos = null;
        $(handle.ownerDocument)
            .off('mouseup', mouseUp)
            .off('mousemove', mouseMove);
    }

    // Event handler for mousedown -- starts drag tracking
    function mouseDown(e) {
        if (e.target !== handle) {
            return;
        }

        lastPos = {
            top: e.pageY,
            left: e.pageX
        };

        $(handle.ownerDocument)
            .on('mouseup', mouseUp)
            .on('mousemove', mouseMove);

        e.preventDefault();
    }

    // Public: turn off drag tracking for this dragTracker object.
    function destroy() {
        $(handle).off('mousedown', mouseDown);
    }

    $(handle).on('mousedown', mouseDown);

    return {destroy: destroy};
};


// resizer is a component that uses a dragTracker under the hood to track the
// dragging of a handle element, using that motion to resize another element.
//
// element - DOM Element to resize
// handle - DOM Element to use as a resize handle
// options - Object of options.
//
// Available options:
//
// invertedX - If this option is defined as a function, and that function
//             returns a truthy value, the horizontal sense of the drag will be
//             inverted. Useful if the drag handle is at the left of the
//             element, and so dragging left means "grow the element"
// invertedY - If this option is defined as a function, and that function
//             returns a truthy value, the vertical sense of the drag will be
//             inverted. Useful if the drag handle is at the bottom of the
//             element, and so dragging down means "grow the element"
var resizer = exports.resizer = function resizer(element, handle, options) {
    var $el = $(element);
    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    // Translate the delta supplied by dragTracker into a delta that takes
    // account of the invertedX and invertedY callbacks if defined.
    function translate(delta) {
        var directionX = 1,
            directionY = -1;

        if (typeof options.invertedX === 'function' && options.invertedX()) {
            directionX = -1;
        }
        if (typeof options.invertedY === 'function' && options.invertedY()) {
            directionY = 1;
        }

        return {
            x: delta.x * directionX,
            y: delta.y * directionY
        };
    }

    // Callback for dragTracker
    function resize(delta) {
        var height = $el.height(),
            width = $el.width(),
            translated = translate(delta);

        if (Math.abs(translated.x) > 0) {
            $el.width(width + translated.x);
        }
        if (Math.abs(translated.y) > 0) {
            $el.height(height + translated.y);
        }

        // Did the element dimensions actually change? If not, then we've
        // reached the minimum size, and we shouldn't track
        var didChange = ($el.height() !== height || $el.width() !== width);
        return didChange;
    }

    // We return the dragTracker object in order to expose its methods.
    return dragTracker(handle, resize);
};


// mover is a component that uses a dragTracker under the hood to track the
// dragging of a handle element, using that motion to move another element.
//
// element - DOM Element to move
// handle - DOM Element to use as a move handle
//
var mover = exports.mover = function mover(element, handle) {
    function move(delta) {
        $(element).css({
            top: parseInt($(element).css('top'), 10) + delta.y,
            left: parseInt($(element).css('left'), 10) + delta.x
        });
    }

    // We return the dragTracker object in order to expose its methods.
    return dragTracker(handle, move);
};


// Public: Creates an element for editing annotations.
var Editor = exports.Editor = Widget.extend({
    // Public: Creates an instance of the Editor object.
    //
    // options - An Object literal containing options.
    //
    // Examples
    //
    //   # Creates a new editor, adds a custom field and
    //   # loads an annotation for editing.
    //   editor = new Annotator.Editor
    //   editor.addField({
    //     label: 'My custom input field',
    //     type:  'textarea'
    //     load:  someLoadCallback
    //     save:  someSaveCallback
    //   })
    //   editor.load(annotation)
    //
    // Returns a new Editor instance.
    constructor: function (options) {
        Widget.call(this, options);

        this.fields = [];
        this.annotation = {};

        if (this.options.defaultFields) {
            this.addField({
                type: 'textarea',
                label: _t('Comments') + '\u2026',
                load: function (field, annotation) {
                    $(field).find('textarea').val(annotation.text || '');
                },
                submit: function (field, annotation) {
                    annotation.text = $(field).find('textarea').val();
                }
            });
        }

        var self = this;

        this.element
            .on("submit." + NS, 'form', function (e) {
                self._onFormSubmit(e);
            })
            .on("click." + NS, '.annotator-save', function (e) {
                self._onSaveClick(e);
            })
            .on("click." + NS, '.annotator-cancel', function (e) {
                self._onCancelClick(e);
            })
            .on("mouseover." + NS, '.annotator-cancel', function (e) {
                self._onCancelMouseover(e);
            })
            .on("keydown." + NS, 'textarea', function (e) {
                self._onTextareaKeydown(e);
            });
    },

    destroy: function () {
        this.element.off("." + NS);
        Widget.prototype.destroy.call(this);
    },

    // Public: Show the editor.
    //
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Examples
    //
    //   editor.show()
    //   editor.hide()
    //   editor.show({top: '100px', left: '80px'})
    //
    // Returns nothing.
    show: function (position) {
        if (typeof position !== 'undefined' && position !== null) {
            this.element.css({
                top: position.top,
                left: position.left
            });
        }

        this.element
            .find('.annotator-save')
            .addClass(this.classes.focus);

        Widget.prototype.show.call(this);

        // give main textarea focus
        this.element.find(":input:first").focus();

        this._setupDraggables();
    },

    // Public: Load an annotation into the editor and display it.
    //
    // annotation - An annotation Object to display for editing.
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Returns a Promise that is resolved when the editor is submitted, or
    // rejected if editing is cancelled.
    load: function (annotation, position) {
        this.annotation = annotation;

        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];
            field.load(field.element, this.annotation);
        }

        var self = this;
        return new Promise(function (resolve, reject) {
            self.dfd = {resolve: resolve, reject: reject};
            self.show(position);
        });
    },

    // Public: Submits the editor and saves any changes made to the annotation.
    //
    // Returns nothing.
    submit: function () {
        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];
            field.submit(field.element, this.annotation);
        }
        if (typeof this.dfd !== 'undefined' && this.dfd !== null) {
            this.dfd.resolve();
        }
        this.hide();
    },

    // Public: Cancels the editing process, discarding any edits made to the
    // annotation.
    //
    // Returns itself.
    cancel: function () {
        if (typeof this.dfd !== 'undefined' && this.dfd !== null) {
            this.dfd.reject('editing cancelled');
        }
        this.hide();
    },

    // Public: Adds an addional form field to the editor. Callbacks can be
    // provided to update the view and anotations on load and submission.
    //
    // options - An options Object. Options are as follows:
    //           id     - A unique id for the form element will also be set as
    //                    the "for" attrubute of a label if there is one.
    //                    (default: "annotator-field-{number}")
    //           type   - Input type String. One of "input", "textarea",
    //                    "checkbox", "select" (default: "input")
    //           label  - Label to display either in a label Element or as
    //                    placeholder text depending on the type. (default: "")
    //           load   - Callback Function called when the editor is loaded
    //                    with a new annotation. Receives the field <li> element
    //                    and the annotation to be loaded.
    //           submit - Callback Function called when the editor is submitted.
    //                    Receives the field <li> element and the annotation to
    //                    be updated.
    //
    // Examples
    //
    //   # Add a new input element.
    //   editor.addField({
    //     label: "Tags",
    //
    //     # This is called when the editor is loaded use it to update your
    //     # input.
    //     load: (field, annotation) ->
    //       # Do something with the annotation.
    //       value = getTagString(annotation.tags)
    //       $(field).find('input').val(value)
    //
    //     # This is called when the editor is submitted use it to retrieve data
    //     # from your input and save it to the annotation.
    //     submit: (field, annotation) ->
    //       value = $(field).find('input').val()
    //       annotation.tags = getTagsFromString(value)
    //   })
    //
    //   # Add a new checkbox element.
    //   editor.addField({
    //     type: 'checkbox',
    //     id: 'annotator-field-my-checkbox',
    //     label: 'Allow anyone to see this annotation',
    //     load: (field, annotation) ->
    //       # Check what state of input should be.
    //       if checked
    //         $(field).find('input').attr('checked', 'checked')
    //       else
    //         $(field).find('input').removeAttr('checked')

    //     submit: (field, annotation) ->
    //       checked = $(field).find('input').is(':checked')
    //       # Do something.
    //   })
    //
    // Returns the created <li> Element.
    addField: function (options) {
        var field = $.extend({
            id: 'annotator-field-' + id(),
            type: 'input',
            label: '',
            load: function () {},
            submit: function () {}
        }, options);

        var input = null,
            element = $('<li class="annotator-item" />');

        field.element = element[0];

        if (field.type === 'textarea') {
            input = $('<textarea />');
        } else if (field.type === 'checkbox') {
            input = $('<input type="checkbox" />');
        } else if (field.type === 'input') {
            input = $('<input />');
        } else if (field.type === 'select') {
            input = $('<select />');
        }

        element.append(input);

        input.attr({
            id: field.id,
            placeholder: field.label
        });

        if (field.type === 'checkbox') {
            element.addClass('annotator-checkbox');
            element.append($('<label />', {
                'for': field.id,
                'html': field.label
            }));
        }

        this.element.find('ul:first').append(element);
        this.fields.push(field);

        return field.element;
    },

    checkOrientation: function () {
        Widget.prototype.checkOrientation.call(this);

        var list = this.element.find('ul').first(),
            controls = this.element.find('.annotator-controls');

        if (this.element.hasClass(this.classes.invert.y)) {
            controls.insertBefore(list);
        } else if (controls.is(':first-child')) {
            controls.insertAfter(list);
        }

        return this;
    },

    // Event callback: called when a user clicks the editor form (by pressing
    // return, for example).
    //
    // Returns nothing
    _onFormSubmit: function (event) {
        preventEventDefault(event);
        this.submit();
    },

    // Event callback: called when a user clicks the editor's save button.
    //
    // Returns nothing
    _onSaveClick: function (event) {
        preventEventDefault(event);
        this.submit();
    },

    // Event callback: called when a user clicks the editor's cancel button.
    //
    // Returns nothing
    _onCancelClick: function (event) {
        preventEventDefault(event);
        this.cancel();
    },

    // Event callback: called when a user mouses over the editor's cancel
    // button.
    //
    // Returns nothing
    _onCancelMouseover: function () {
        this.element
            .find('.' + this.classes.focus)
            .removeClass(this.classes.focus);
    },

    // Event callback: listens for the following special keypresses.
    // - escape: Hides the editor
    // - enter:  Submits the editor
    //
    // event - A keydown Event object.
    //
    // Returns nothing
    _onTextareaKeydown: function (event) {
        if (event.which === 27) {
            // "Escape" key => abort.
            this.cancel();
        } else if (event.which === 13 && !event.shiftKey) {
            // If "return" was pressed without the shift key, we're done.
            this.submit();
        }
    },

    // Sets up mouse events for resizing and dragging the editor window.
    //
    // Returns nothing.
    _setupDraggables: function () {
        if (typeof this._resizer !== 'undefined' && this._resizer !== null) {
            this._resizer.destroy();
        }
        if (typeof this._mover !== 'undefined' && this._mover !== null) {
            this._mover.destroy();
        }

        this.element.find('.annotator-resize').remove();

        // Find the first/last item element depending on orientation
        var cornerItem;
        if (this.element.hasClass(this.classes.invert.y)) {
            cornerItem = this.element.find('.annotator-item:last');
        } else {
            cornerItem = this.element.find('.annotator-item:first');
        }

        if (cornerItem) {
            $('<span class="annotator-resize"></span>').appendTo(cornerItem);
        }

        var controls = this.element.find('.annotator-controls')[0],
            textarea = this.element.find('textarea:first')[0],
            resizeHandle = this.element.find('.annotator-resize')[0],
            self = this;

        this._resizer = resizer(textarea, resizeHandle, {
            invertedX: function () {
                return self.element.hasClass(self.classes.invert.x);
            },
            invertedY: function () {
                return self.element.hasClass(self.classes.invert.y);
            }
        });

        this._mover = mover(this.element[0], controls);
    }
});

// Classes to toggle state.
Editor.classes = {
    hide: 'annotator-hide',
    focus: 'annotator-focus'
};

// HTML template for this.element.
Editor.template = [
    '<div class="annotator-outer annotator-editor annotator-hide">',
    '  <form class="annotator-widget">',
    '    <ul class="annotator-listing"></ul>',
    '    <div class="annotator-controls">',
    '     <a href="#cancel" class="annotator-cancel">' + _t('Cancel') + '</a>',
    '      <a href="#save"',
    '         class="annotator-save annotator-focus">' + _t('Save') + '</a>',
    '    </div>',
    '  </form>',
    '</div>'
].join('\n');

// Configuration options
Editor.options = {
    // Add the default field(s) to the editor.
    defaultFields: true
};

// standalone is a module that uses the Editor to display an editor widget
// allowing the user to provide a note (and other data) before an annotation is
// created or updated.
exports.standalone = function standalone(options) {
    var widget = new exports.Editor(options);

    return {
        destroy: function () { widget.destroy(); },
        beforeAnnotationCreated: function (annotation) {
            return widget.load(annotation);
        },
        beforeAnnotationUpdated: function (annotation) {
            return widget.load(annotation);
        }
    };
};

},{"../util":39,"./widget":38}],31:[function(require,module,exports){
"use strict";

var util = require('../util');

var $ = util.$;
var _t = util.gettext;

var NS = 'annotator-filter';


// Public: Creates a new instance of the Filter.
//
// options - An Object literal of options.
//
// Returns a new instance of the Filter.
var Filter = exports.Filter = function Filter(options) {
    this.options = $.extend(true, {}, Filter.options, options);
    this.classes = $.extend(true, {}, Filter.classes);
    this.element = $(Filter.html.element).appendTo(this.options.appendTo);

    this.filter  = $(Filter.html.filter);
    this.filters = [];
    this.current  = 0;

    for (var i = 0, len = this.options.filters.length; i < len; i++) {
        var filter = this.options.filters[i];
        this.addFilter(filter);
    }

    this.updateHighlights();

    var filterInput = '.annotator-filter-property input',
        self = this;
    this.element
        .on("focus." + NS, filterInput, function (e) {
            self._onFilterFocus(e);
        })
        .on("blur." + NS, filterInput, function (e) {
            self._onFilterBlur(e);
        })
        .on("keyup." + NS, filterInput, function (e) {
            self._onFilterKeyup(e);
        })
        .on("click." + NS, '.annotator-filter-previous', function (e) {
            self._onPreviousClick(e);
        })
        .on("click." + NS, '.annotator-filter-next', function (e) {
            self._onNextClick(e);
        })
        .on("click." + NS, '.annotator-filter-clear', function (e) {
            self._onClearClick(e);
        });

    this._insertSpacer();

    if (this.options.addAnnotationFilter) {
        this.addFilter({label: _t('Annotation'), property: 'text'});
    }
};

// Public: remove the filter instance and unbind events.
//
// Returns nothing.
Filter.prototype.destroy = function () {
    var html = $('html'),
        currentMargin = parseInt(html.css('padding-top'), 10) || 0;
    html.css('padding-top', currentMargin - this.element.outerHeight());
    this.element.off("." + NS);
    this.element.remove();
};

// Adds margin to the current document to ensure that the annotation toolbar
// doesn't cover the page when not scrolled.
//
// Returns itself
Filter.prototype._insertSpacer = function () {
    var html = $('html'),
        currentMargin = parseInt(html.css('padding-top'), 10) || 0;
    html.css('padding-top', currentMargin + this.element.outerHeight());
    return this;
};

// Public: Adds a filter to the toolbar. The filter must have both a label
// and a property of an annotation object to filter on.
//
// options - An Object literal containing the filters options.
//           label      - A public facing String to represent the filter.
//           property   - An annotation property String to filter on.
//           isFiltered - A callback Function that recieves the field input
//                        value and the annotation property value. See
//                        this.options.isFiltered() for details.
//
// Examples
//
//   # Set up a filter to filter on the annotation.user property.
//   filter.addFilter({
//     label: User,
//     property: 'user'
//   })
//
// Returns itself to allow chaining.
Filter.prototype.addFilter = function (options) {
    var filter = $.extend({
        label: '',
        property: '',
        isFiltered: this.options.isFiltered
    }, options);

    // Skip if a filter for this property has been loaded.
    var hasFilterForProp = false;
    for (var i = 0, len = this.filters.length; i < len; i++) {
        var f = this.filters[i];
        if (f.property === filter.property) {
            hasFilterForProp = true;
            break;
        }
    }
    if (!hasFilterForProp) {
        filter.id = 'annotator-filter-' + filter.property;
        filter.annotations = [];
        filter.element = this.filter.clone().appendTo(this.element);
        filter.element.find('label')
            .html(filter.label)
            .attr('for', filter.id);
        filter.element.find('input')
            .attr({
                id: filter.id,
                placeholder: _t('Filter by ') + filter.label + '\u2026'
            });
        filter.element.find('button').hide();

        // Add the filter to the elements data store.
        filter.element.data('filter', filter);

        this.filters.push(filter);
    }

    return this;
};

// Public: Updates the filter.annotations property. Then updates the state
// of the elements in the DOM. Calls the filter.isFiltered() method to
// determine if the annotation should remain.
//
// filter - A filter Object from this.filters
//
// Examples
//
//   filter.updateFilter(myFilter)
//
// Returns itself for chaining
Filter.prototype.updateFilter = function (filter) {
    filter.annotations = [];

    this.updateHighlights();
    this.resetHighlights();
    var input = $.trim(filter.element.find('input').val());

    if (!input) {
        return;
    }

    var annotations = this.highlights.map(function () {
        return $(this).data('annotation');
    });
    annotations = $.makeArray(annotations);

    for (var i = 0, len = annotations.length; i < len; i++) {
        var annotation = annotations[i],
            property = annotation[filter.property];

        if (filter.isFiltered(input, property)) {
            filter.annotations.push(annotation);
        }
    }

    this.filterHighlights();
};

// Public: Updates the this.highlights property with the latest highlight
// elements in the DOM.
//
// Returns a jQuery collection of the highlight elements.
Filter.prototype.updateHighlights = function () {
    // Ignore any hidden highlights.
    this.highlights = $(this.options.filterElement)
        .find('.annotator-hl:visible');
    this.filtered = this.highlights.not(this.classes.hl.hide);
};

// Public: Runs through each of the filters and removes all highlights not
// currently in scope.
//
// Returns itself for chaining.
Filter.prototype.filterHighlights = function () {
    var activeFilters = $.grep(this.filters, function (filter) {
        return Boolean(filter.annotations.length);
    });

    var filtered = [];
    if (activeFilters.length > 0) {
        filtered = activeFilters[0].annotations;
    }
    if (activeFilters.length > 1) {
        // If there are more than one filter then only annotations matched in
        // every filter should remain.
        var annotations = [];

        $.each(activeFilters, function () {
            $.merge(annotations, this.annotations);
        });

        var uniques = [];
        filtered = [];
        $.each(annotations, function () {
            if ($.inArray(this, uniques) === -1) {
                uniques.push(this);
            } else {
                filtered.push(this);
            }
        });
    }

    var highlights = this.highlights;
    for (var i = 0, len = filtered.length; i < len; i++) {
        highlights = highlights.not(filtered[i]._local.highlights);
    }
    highlights.addClass(this.classes.hl.hide);
    this.filtered = this.highlights.not(this.classes.hl.hide);

    return this;
};

// Public: Removes hidden class from all annotations.
//
// Returns itself for chaining.
Filter.prototype.resetHighlights = function () {
    this.highlights.removeClass(this.classes.hl.hide);
    this.filtered = this.highlights;
    return this;
};

// Updates the filter field on focus.
//
// event - A focus Event object.
//
// Returns nothing
Filter.prototype._onFilterFocus = function (event) {
    var input = $(event.target);
    input.parent().addClass(this.classes.active);
    input.next('button').show();
};

// Updates the filter field on blur.
//
// event - A blur Event object.
//
// Returns nothing.
Filter.prototype._onFilterBlur = function (event) {
    if (!event.target.value) {
        var input = $(event.target);
        input.parent().removeClass(this.classes.active);
        input.next('button').hide();
    }
};

// Updates the filter based on the id of the filter element.
//
// event - A keyup Event
//
// Returns nothing.
Filter.prototype._onFilterKeyup = function (event) {
    var filter = $(event.target).parent().data('filter');
    if (filter) {
        this.updateFilter(filter);
    }
};

// Locates the next/previous highlighted element in this.highlights from the
// current one or goes to the very first/last element respectively.
//
// previous - If true finds the previously highlighted element.
//
// Returns itself.
Filter.prototype._findNextHighlight = function (previous) {
    if (this.highlights.length === 0) {
        return this;
    }

    var offset = -1,
        resetOffset = 0,
        operator = 'gt';

    if (previous) {
        offset = 0;
        resetOffset = -1;
        operator = 'lt';
    }

    var active = this.highlights.not('.' + this.classes.hl.hide),
        current = active.filter('.' + this.classes.hl.active);

    if (current.length === 0) {
        current = active.eq(offset);
    }

    var annotation = current.data('annotation');

    var index = active.index(current[0]),
        next = active.filter(":" + operator + "(" + index + ")")
            .not(annotation._local.highlights)
            .eq(resetOffset);

    if (next.length === 0) {
        next = active.eq(resetOffset);
    }

    this._scrollToHighlight(next.data('annotation')._local.highlights);
};

// Locates the next highlighted element in this.highlights from the current one
// or goes to the very first element.
//
// event - A click Event.
//
// Returns nothing
Filter.prototype._onNextClick = function () {
    this._findNextHighlight();
};

// Locates the previous highlighted element in this.highlights from the current
// one or goes to the very last element.
//
// event - A click Event.
//
// Returns nothing
Filter.prototype._onPreviousClick = function () {
    this._findNextHighlight(true);
};

// Scrolls to the highlight provided. An adds an active class to it.
//
// highlight - Either highlight Element or an Array of elements. This value
//             is usually retrieved from annotation._local.highlights.
//
// Returns nothing.
Filter.prototype._scrollToHighlight = function (highlight) {
    highlight = $(highlight);

    this.highlights.removeClass(this.classes.hl.active);
    highlight.addClass(this.classes.hl.active);

    $('html, body').animate({
        scrollTop: highlight.offset().top - (this.element.height() + 20)
    }, 150);
};

// Clears the relevant input when the clear button is clicked.
//
// event - A click Event object.
//
// Returns nothing.
Filter.prototype._onClearClick = function (event) {
    $(event.target).prev('input').val('').keyup().blur();
};

// Common classes used to change filter state.
Filter.classes = {
    active: 'annotator-filter-active',
    hl: {
        hide: 'annotator-hl-filtered',
        active: 'annotator-hl-active'
    }
};

// HTML templates for the filter UI.
Filter.html = {
    element: [
        '<div class="annotator-filter">',
        '  <strong>' + _t('Navigate:') + '</strong>',
        '  <span class="annotator-filter-navigation">',
        '    <button type="button"',
        '            class="annotator-filter-previous">' +
            _t('Previous') +
            '</button>',
        '    <button type="button"',
        '            class="annotator-filter-next">' + _t('Next') + '</button>',
        '  </span>',
        '  <strong>' + _t('Filter by:') + '</strong>',
        '</div>'
    ].join('\n'),

    filter: [
        '<span class="annotator-filter-property">',
        '  <label></label>',
        '  <input/>',
        '  <button type="button"',
        '          class="annotator-filter-clear">' + _t('Clear') + '</button>',
        '</span>'
    ].join('\n')
};

// Default options for Filter.
Filter.options = {
    // A CSS selector or Element to append the filter toolbar to.
    appendTo: 'body',

    // A CSS selector or Element to find and filter highlights in.
    filterElement: 'body',

    // An array of filters can be provided on initialisation.
    filters: [],

    // Adds a default filter on annotations.
    addAnnotationFilter: true,

    // Public: Determines if the property is contained within the provided
    // annotation property. Default is to split the string on spaces and only
    // return true if all keywords are contained in the string. This method
    // can be overridden by the user when initialising the filter.
    //
    // string   - An input String from the fitler.
    // property - The annotation propery to query.
    //
    // Examples
    //
    //   filter.option.getKeywords('hello', 'hello world how are you?')
    //   # => Returns true
    //
    //   plugin.option.getKeywords('hello bill', 'hello world how are you?')
    //   # => Returns false
    //
    // Returns an Array of keyword Strings.
    isFiltered: function (input, property) {
        if (!(input && property)) {
            return false;
        }

        var keywords = input.split(/\s+/);
        for (var i = 0, len = keywords.length; i < len; i++) {
            if (property.indexOf(keywords[i]) === -1) {
                return false;
            }
        }

        return true;
    }
};


// standalone is a module that uses the Filter component to display a filter bar
// to allow browsing and searching of annotations on the current page.
exports.standalone = function (options) {
    var widget = new exports.Filter(options);

    return {
        destroy: function () { widget.destroy(); },

        annotationsLoaded: function () { widget.updateHighlights(); },
        annotationCreated: function () { widget.updateHighlights(); },
        annotationUpdated: function () { widget.updateHighlights(); },
        annotationDeleted: function () { widget.updateHighlights(); }
    };
};

},{"../util":39}],32:[function(require,module,exports){
(function (global){
"use strict";

var Range = require('xpath-range').Range;

var util = require('../util');

var $ = util.$;
var Promise = util.Promise;


// highlightRange wraps the DOM Nodes within the provided range with a highlight
// element of the specified class and returns the highlight Elements.
//
// normedRange - A NormalizedRange to be highlighted.
// cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
//
// Returns an array of highlight Elements.
function highlightRange(normedRange, cssClass) {
    if (typeof cssClass === 'undefined' || cssClass === null) {
        cssClass = 'annotator-hl';
    }
    var white = /^\s*$/;

    // Ignore text nodes that contain only whitespace characters. This prevents
    // spans being injected between elements that can only contain a restricted
    // subset of nodes such as table rows and lists. This does mean that there
    // may be the odd abandoned whitespace node in a paragraph that is skipped
    // but better than breaking table layouts.
    var nodes = normedRange.textNodes(),
        results = [];
    for (var i = 0, len = nodes.length; i < len; i++) {
        var node = nodes[i];
        if (!white.test(node.nodeValue)) {
            var hl = global.document.createElement('span');
            hl.className = cssClass;
            node.parentNode.replaceChild(hl, node);
            hl.appendChild(node);
            results.push(hl);
        }
    }
    return results;
}


// reanchorRange will attempt to normalize a range, swallowing Range.RangeErrors
// for those ranges which are not reanchorable in the current document.
function reanchorRange(range, rootElement) {
    try {
        return Range.sniff(range).normalize(rootElement);
    } catch (e) {
        if (!(e instanceof Range.RangeError)) {
            // Oh Javascript, why you so crap? This will lose the traceback.
            throw(e);
        }
        // Otherwise, we simply swallow the error. Callers are responsible
        // for only trying to draw valid annotations.
    }
    return null;
}


// Highlighter provides a simple way to draw highlighted <span> tags over
// annotated ranges within a document.
//
// element - The root Element on which to dereference annotation ranges and
//           draw highlights.
// options - An options Object containing configuration options for the plugin.
//           See `Highlighter.options` for available options.
//
var Highlighter = exports.Highlighter = function Highlighter(element, options) {
    this.element = element;
    this.options = $.extend(true, {}, Highlighter.options, options);
};

Highlighter.prototype.destroy = function () {
    $(this.element)
        .find("." + this.options.highlightClass)
        .each(function (_, el) {
            $(el).contents().insertBefore(el);
            $(el).remove();
        });
};

// Public: Draw highlights for all the given annotations
//
// annotations - An Array of annotation Objects for which to draw highlights.
//
// Returns nothing.
Highlighter.prototype.drawAll = function (annotations) {
    var self = this;

    var p = new Promise(function (resolve) {
        var highlights = [];

        function loader(annList) {
            if (typeof annList === 'undefined' || annList === null) {
                annList = [];
            }

            var now = annList.splice(0, self.options.chunkSize);
            for (var i = 0, len = now.length; i < len; i++) {
                highlights = highlights.concat(self.draw(now[i]));
            }

            // If there are more to do, do them after a delay
            if (annList.length > 0) {
                setTimeout(function () {
                    loader(annList);
                }, self.options.chunkDelay);
            } else {
                resolve(highlights);
            }
        }

        var clone = annotations.slice();
        loader(clone);
    });

    return p;
};

// Public: Draw highlights for the annotation.
//
// annotation - An annotation Object for which to draw highlights.
//
// Returns an Array of drawn highlight elements.
Highlighter.prototype.draw = function (annotation) {
    var normedRanges = [];

    for (var i = 0, ilen = annotation.ranges.length; i < ilen; i++) {
        var r = reanchorRange(annotation.ranges[i], this.element);
        if (r !== null) {
            normedRanges.push(r);
        }
    }

    var hasLocal = (typeof annotation._local !== 'undefined' &&
                    annotation._local !== null);
    if (!hasLocal) {
        annotation._local = {};
    }
    var hasHighlights = (typeof annotation._local.highlights !== 'undefined' &&
                         annotation._local.highlights === null);
    if (!hasHighlights) {
        annotation._local.highlights = [];
    }

    for (var j = 0, jlen = normedRanges.length; j < jlen; j++) {
        var normed = normedRanges[j];
        $.merge(
            annotation._local.highlights,
            highlightRange(normed, this.options.highlightClass)
        );
    }

    // Save the annotation data on each highlighter element.
    $(annotation._local.highlights).data('annotation', annotation);

    // Add a data attribute for annotation id if the annotation has one
    if (typeof annotation.id !== 'undefined' && annotation.id !== null) {
        $(annotation._local.highlights)
            .attr('data-annotation-id', annotation.id);
    }

    return annotation._local.highlights;
};

// Public: Remove the drawn highlights for the given annotation.
//
// annotation - An annotation Object for which to purge highlights.
//
// Returns nothing.
Highlighter.prototype.undraw = function (annotation) {
    var hasHighlights = (typeof annotation._local !== 'undefined' &&
                         annotation._local !== null &&
                         typeof annotation._local.highlights !== 'undefined' &&
                         annotation._local.highlights !== null);

    if (!hasHighlights) {
        return;
    }

    for (var i = 0, len = annotation._local.highlights.length; i < len; i++) {
        var h = annotation._local.highlights[i];
        if (h.parentNode !== null) {
            $(h).replaceWith(h.childNodes);
        }
    }
    delete annotation._local.highlights;
};

// Public: Redraw the highlights for the given annotation.
//
// annotation - An annotation Object for which to redraw highlights.
//
// Returns the list of newly-drawn highlights.
Highlighter.prototype.redraw = function (annotation) {
    this.undraw(annotation);
    return this.draw(annotation);
};

Highlighter.options = {
    // The CSS class to apply to drawn highlights
    highlightClass: 'annotator-hl',
    // Number of annotations to draw at once
    chunkSize: 10,
    // Time (in ms) to pause between drawing chunks of annotations
    chunkDelay: 10
};


// standalone is a module that uses the Highlighter to draw/undraw highlights
// automatically when annotations are created and removed.
exports.standalone = function standalone(element, options) {
    var widget = exports.Highlighter(element, options);

    return {
        destroy: function () { widget.destroy(); },
        annotationsLoaded: function (anns) { widget.drawAll(anns); },
        annotationCreated: function (ann) { widget.draw(ann); },
        annotationDeleted: function (ann) { widget.undraw(ann); },
        annotationUpdated: function (ann) { widget.redraw(ann); }
    };
};

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"../util":39,"xpath-range":18}],33:[function(require,module,exports){
(function (global){
/*package annotator.ui */
"use strict";

var util = require('../util');

var adder = require('./adder');
var editor = require('./editor');
var highlighter = require('./highlighter');
var textselector = require('./textselector');
var viewer = require('./viewer');

var _t = util.gettext;


// trim strips whitespace from either end of a string.
//
// This usually exists in native code, but not in IE8.
function trim(s) {
    if (typeof String.prototype.trim === 'function') {
        return String.prototype.trim.call(s);
    } else {
        return s.replace(/^[\s\xA0]+|[\s\xA0]+$/g, '');
    }
}


// annotationFactory returns a function that can be used to construct an
// annotation from a list of selected ranges.
function annotationFactory(contextEl, ignoreSelector) {
    return function (ranges) {
        var text = [],
            serializedRanges = [];

        for (var i = 0, len = ranges.length; i < len; i++) {
            var r = ranges[i];
            text.push(trim(r.text()));
            serializedRanges.push(r.serialize(contextEl, ignoreSelector));
        }

        return {
            quote: text.join(' / '),
            ranges: serializedRanges
        };
    };
}


// maxZIndex returns the maximum z-index of all elements in the provided set.
function maxZIndex(elements) {
    var max = -1;
    for (var i = 0, len = elements.length; i < len; i++) {
        var $el = util.$(elements[i]);
        if ($el.css('position') !== 'static') {
            // Use parseFloat since we may get scientific notation for large
            // values.
            var zIndex = parseFloat($el.css('z-index'));
            if (zIndex > max) {
                max = zIndex;
            }
        }
    }
    return max;
}


// Helper function to inject CSS into the page that ensures Annotator elements
// are displayed with the highest z-index.
function injectDynamicStyle() {
    util.$('#annotator-dynamic-style').remove();

    var sel = '*' +
              ':not(annotator-adder)' +
              ':not(annotator-outer)' +
              ':not(annotator-notice)' +
              ':not(annotator-filter)';

    // use the maximum z-index in the page
    var max = maxZIndex(util.$(global.document.body).find(sel).get());

    // but don't go smaller than 1010, because this isn't bulletproof --
    // dynamic elements in the page (notifications, dialogs, etc.) may well
    // have high z-indices that we can't catch using the above method.
    max = Math.max(max, 1000);

    var rules = [
        ".annotator-adder, .annotator-outer, .annotator-notice {",
        "  z-index: " + (max + 20) + ";",
        "}",
        ".annotator-filter {",
        "  z-index: " + (max + 10) + ";",
        "}"
    ].join("\n");

    util.$('<style>' + rules + '</style>')
        .attr('id', 'annotator-dynamic-style')
        .attr('type', 'text/css')
        .appendTo('head');
}


// Helper function to remove dynamic stylesheets
function removeDynamicStyle() {
    util.$('#annotator-dynamic-style').remove();
}


// Helper function to add permissions checkboxes to the editor
function addPermissionsCheckboxes(editor, ident, authz) {
    function createLoadCallback(action) {
        return function loadCallback(field, annotation) {
            field = util.$(field).show();

            var u = ident.who();
            var input = field.find('input');

            // Do not show field if no user is set
            if (typeof u === 'undefined' || u === null) {
                field.hide();
            }

            // Do not show field if current user is not admin.
            if (!(authz.permits('admin', annotation, u))) {
                field.hide();
            }

            // See if we can authorise without a user.
            if (authz.permits(action, annotation, null)) {
                input.attr('checked', 'checked');
            } else {
                input.removeAttr('checked');
            }
        };
    }

    function createSubmitCallback(action) {
        return function submitCallback(field, annotation) {
            var u = ident.who();

            // Don't do anything if no user is set
            if (typeof u === 'undefined' || u === null) {
                return;
            }

            if (!annotation.permissions) {
                annotation.permissions = {};
            }
            if (util.$(field).find('input').is(':checked')) {
                delete annotation.permissions[action];
            } else {
                // While the permissions model allows for more complex entries
                // than this, our UI presents a checkbox, so we can only
                // interpret "prevent others from viewing" as meaning "allow
                // only me to view". This may want changing in the future.
                annotation.permissions[action] = [
                    authz.authorizedUserId(u)
                ];
            }
        };
    }

    editor.addField({
        type: 'checkbox',
        label: _t('Allow anyone to <strong>view</strong> this annotation'),
        load: createLoadCallback('read'),
        submit: createSubmitCallback('read')
    });

    editor.addField({
        type: 'checkbox',
        label: _t('Allow anyone to <strong>edit</strong> this annotation'),
        load: createLoadCallback('update'),
        submit: createSubmitCallback('update')
    });
}


/**
 * function:: main([options])
 *
 * A module that provides a default user interface for Annotator that allows
 * users to create annotations by selecting text within (a part of) the
 * document.
 *
 * Example::
 *
 *     app.include(annotator.ui.main);
 *
 * :param Object options:
 *
 *   .. attribute:: options.element
 *
 *      A DOM element to which event listeners are bound. Defaults to
 *      ``document.body``, allowing annotation of the whole document.
 *
 *   .. attribute:: options.editorExtensions
 *
 *      An array of editor extensions. See the
 *      :class:`~annotator.ui.editor.Editor` documentation for details of editor
 *      extensions.
 *
 *   .. attribute:: options.viewerExtensions
 *
 *      An array of viewer extensions. See the
 *      :class:`~annotator.ui.viewer.Viewer` documentation for details of viewer
 *      extensions.
 *
 */
function main(options) {
    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    options.element = options.element || global.document.body;
    options.editorExtensions = options.editorExtensions || [];
    options.viewerExtensions = options.viewerExtensions || [];

    // Local helpers
    var makeAnnotation = annotationFactory(options.element, '.annotator-hl');

    // Object to hold local state
    var s = {
        interactionPoint: null
    };

    function start(app) {
        var ident = app.registry.getUtility('identityPolicy');
        var authz = app.registry.getUtility('authorizationPolicy');

        s.adder = new adder.Adder({
            onCreate: function (ann) {
                app.annotations.create(ann);
            }
        });
        s.adder.attach();

        s.editor = new editor.Editor({
            extensions: options.editorExtensions
        });
        s.editor.attach();

        addPermissionsCheckboxes(s.editor, ident, authz);

        s.highlighter = new highlighter.Highlighter(options.element);

        s.textselector = new textselector.TextSelector(options.element, {
            onSelection: function (ranges, event) {
                if (ranges.length > 0) {
                    var annotation = makeAnnotation(ranges);
                    s.interactionPoint = util.mousePosition(event);
                    s.adder.load(annotation, s.interactionPoint);
                } else {
                    s.adder.hide();
                }
            }
        });

        s.viewer = new viewer.Viewer({
            onEdit: function (ann) {
                // Copy the interaction point from the shown viewer:
                s.interactionPoint = util.$(s.viewer.element)
                                         .css(['top', 'left']);

                app.annotations.update(ann);
            },
            onDelete: function (ann) {
                app.annotations['delete'](ann);
            },
            permitEdit: function (ann) {
                return authz.permits('update', ann, ident.who());
            },
            permitDelete: function (ann) {
                return authz.permits('delete', ann, ident.who());
            },
            autoViewHighlights: options.element,
            extensions: options.viewerExtensions
        });
        s.viewer.attach();

        injectDynamicStyle();
    }

    return {
        start: start,

        destroy: function () {
            s.adder.destroy();
            s.editor.destroy();
            s.highlighter.destroy();
            s.textselector.destroy();
            s.viewer.destroy();
            removeDynamicStyle();
        },

        annotationsLoaded: function (anns) { s.highlighter.drawAll(anns); },
        annotationCreated: function (ann) { s.highlighter.draw(ann); },
        annotationDeleted: function (ann) { s.highlighter.undraw(ann); },
        annotationUpdated: function (ann) { s.highlighter.redraw(ann); },

        beforeAnnotationCreated: function (annotation) {
            // Editor#load returns a promise that is resolved if editing
            // completes, and rejected if editing is cancelled. We return it
            // here to "stall" the annotation process until the editing is
            // done.
            return s.editor.load(annotation, s.interactionPoint);
        },

        beforeAnnotationUpdated: function (annotation) {
            return s.editor.load(annotation, s.interactionPoint);
        }
    };
}


exports.main = main;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"../util":39,"./adder":29,"./editor":30,"./highlighter":32,"./textselector":36,"./viewer":37}],34:[function(require,module,exports){
(function (global){
/*package annotator.ui.markdown */
"use strict";

var util = require('../util');

var _t = util.gettext;


/**
 * function:: render(annotation)
 *
 * Render an annotation to HTML, converting annotation text from Markdown if
 * Showdown is available in the page.
 *
 * :returns: Rendered HTML.
 * :rtype: String
 */
var render = exports.render = function render(annotation) {
    var convert = util.escapeHtml;

    if (global.showdown && typeof global.showdown.Converter === 'function') {
        convert = new global.showdown.Converter().makeHtml;
    }

    if (annotation.text) {
        return convert(annotation.text);
    } else {
        return "<i>" + _t('No comment') + "</i>";
    }
};


/**
 * function:: viewerExtension(viewer)
 *
 * An extension for the :class:`~annotator.ui.viewer.Viewer`. Allows the viewer
 * to interpret annotation text as `Markdown`_ and uses the `Showdown`_ library
 * if present in the page to render annotations with Markdown text as HTML.
 *
 * .. _Markdown: https://daringfireball.net/projects/markdown/
 * .. _Showdown: https://github.com/showdownjs/showdown
 *
 * **Usage**::
 *
 *     app.include(annotator.ui.main, {
 *         viewerExtensions: [annotator.ui.markdown.viewerExtension]
 *     });
 */
exports.viewerExtension = function viewerExtension(viewer) {
    if (!global.showdown || typeof global.showdown.Converter !== 'function') {
        console.warn(_t("To use the Markdown plugin, you must " +
                        "include Showdown into the page first."));
    }

    viewer.setRenderer(render);
};

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"../util":39}],35:[function(require,module,exports){
/*package annotator.ui.tags */
"use strict";

var util = require('../util');

var $ = util.$;
var _t = util.gettext;

// Take an array of tags and turn it into a string suitable for display in the
// viewer.
function stringifyTags(array) {
    return array.join(" ");
}

// Take a string from the tags input as an argument, and return an array of
// tags.
function parseTags(string) {
    string = $.trim(string);
    var tags = [];

    if (string) {
        tags = string.split(/\s+/);
    }

    return tags;
}


/**
 * function:: viewerExtension(viewer)
 *
 * An extension for the :class:`~annotator.ui.viewer.Viewer` that displays any
 * tags stored as an array of strings in the annotation's ``tags`` property.
 *
 * **Usage**::
 *
 *     app.include(annotator.ui.main, {
 *         viewerExtensions: [annotator.ui.tags.viewerExtension]
 *     })
 */
exports.viewerExtension = function viewerExtension(v) {
    function updateViewer(field, annotation) {
        field = $(field);
        if (annotation.tags &&
            $.isArray(annotation.tags) &&
            annotation.tags.length) {
            field.addClass('annotator-tags').html(function () {
                return $.map(annotation.tags, function (tag) {
                    return '<span class="annotator-tag">' +
                        util.escapeHtml(tag) +
                        '</span>';
                }).join(' ');
            });
        } else {
            field.remove();
        }
    }

    v.addField({
        load: updateViewer
    });
};


/**
 * function:: editorExtension(editor)
 *
 * An extension for the :class:`~annotator.ui.editor.Editor` that allows
 * editing a set of space-delimited tags, retrieved from and saved to the
 * annotation's ``tags`` property.
 *
 * **Usage**::
 *
 *     app.include(annotator.ui.main, {
 *         viewerExtensions: [annotator.ui.tags.viewerExtension]
 *     })
 */
exports.editorExtension = function editorExtension(e) {
    // The input element added to the Annotator.Editor wrapped in jQuery.
    // Cached to save having to recreate it everytime the editor is displayed.
    var field = null;
    var input = null;

    function updateField(field, annotation) {
        var value = '';
        if (annotation.tags) {
            value = stringifyTags(annotation.tags);
        }
        input.val(value);
    }

    function setAnnotationTags(field, annotation) {
        annotation.tags = parseTags(input.val());
    }

    field = e.addField({
        label: _t('Add some tags here') + '\u2026',
        load: updateField,
        submit: setAnnotationTags
    });

    input = $(field).find(':input');
};

},{"../util":39}],36:[function(require,module,exports){
(function (global){
"use strict";

var Range = require('xpath-range').Range;

var util = require('../util');

var $ = util.$;

var TEXTSELECTOR_NS = 'annotator-textselector';

// isAnnotator determines if the provided element is part of Annotator. Useful
// for ignoring mouse actions on the annotator elements.
//
// element - An Element or TextNode to check.
//
// Returns true if the element is a child of an annotator element.
function isAnnotator(element) {
    var elAndParents = $(element).parents().addBack();
    return (elAndParents.filter('[class^=annotator-]').length !== 0);
}


// TextSelector monitors a document (or a specific element) for text selections
// and can notify another object of a selection event
function TextSelector(element, options) {
    this.element = element;
    this.options = $.extend(true, {}, TextSelector.options, options);
    this.onSelection = this.options.onSelection;

    if (typeof this.element.ownerDocument !== 'undefined' &&
        this.element.ownerDocument !== null) {
        var self = this;
        this.document = this.element.ownerDocument;

        $(this.document.body)
            .on("mouseup." + TEXTSELECTOR_NS, function (e) {
                self._checkForEndSelection(e);
            });
    } else {
        console.warn("You created an instance of the TextSelector on an " +
                     "element that doesn't have an ownerDocument. This won't " +
                     "work! Please ensure the element is added to the DOM " +
                     "before the plugin is configured:", this.element);
    }
}

TextSelector.prototype.destroy = function () {
    if (this.document) {
        $(this.document.body).off("." + TEXTSELECTOR_NS);
    }
};

// Public: capture the current selection from the document, excluding any nodes
// that fall outside of the adder's `element`.
//
// Returns an Array of NormalizedRange instances.
TextSelector.prototype.captureDocumentSelection = function () {
    var i,
        len,
        ranges = [],
        rangesToIgnore = [],
        selection = global.getSelection();

    if (selection.isCollapsed) {
        return [];
    }

    for (i = 0; i < selection.rangeCount; i++) {
        var r = selection.getRangeAt(i),
            browserRange = new Range.BrowserRange(r),
            normedRange = browserRange.normalize().limit(this.element);

        // If the new range falls fully outside our this.element, we should
        // add it back to the document but not return it from this method.
        if (normedRange === null) {
            rangesToIgnore.push(r);
        } else {
            ranges.push(normedRange);
        }
    }

    // BrowserRange#normalize() modifies the DOM structure and deselects the
    // underlying text as a result. So here we remove the selected ranges and
    // reapply the new ones.
    selection.removeAllRanges();

    for (i = 0, len = rangesToIgnore.length; i < len; i++) {
        selection.addRange(rangesToIgnore[i]);
    }

    // Add normed ranges back to the selection
    for (i = 0, len = ranges.length; i < len; i++) {
        var range = ranges[i],
            drange = this.document.createRange();
        drange.setStartBefore(range.start);
        drange.setEndAfter(range.end);
        selection.addRange(drange);
    }


    return ranges;
};

// Event callback: called when the mouse button is released. Checks to see if a
// selection has been made and if so displays the adder.
//
// event - A mouseup Event object.
//
// Returns nothing.
TextSelector.prototype._checkForEndSelection = function (event) {
    var self = this;

    var _nullSelection = function () {
        if (typeof self.onSelection === 'function') {
            self.onSelection([], event);
        }
    };

    // Get the currently selected ranges.
    var selectedRanges = this.captureDocumentSelection();

    if (selectedRanges.length === 0) {
        _nullSelection();
        return;
    }

    // Don't show the adder if the selection was of a part of Annotator itself.
    for (var i = 0, len = selectedRanges.length; i < len; i++) {
        var container = selectedRanges[i].commonAncestor;
        if ($(container).hasClass('annotator-hl')) {
            container = $(container).parents('[class!=annotator-hl]')[0];
        }
        if (isAnnotator(container)) {
            _nullSelection();
            return;
        }
    }

    if (typeof this.onSelection === 'function') {
        this.onSelection(selectedRanges, event);
    }
};


// Configuration options
TextSelector.options = {
    // Callback, called when the user makes a selection.
    // Receives the list of selected ranges (may be empty) and  the DOM Event
    // that was detected as a selection.
    onSelection: null
};


exports.TextSelector = TextSelector;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"../util":39,"xpath-range":18}],37:[function(require,module,exports){
"use strict";

var Widget = require('./widget').Widget,
    util = require('../util');

var $ = util.$,
    _t = util.gettext;

var NS = 'annotator-viewer';


// Private: simple parser for hypermedia link structure
//
// Examples:
//
//   links = [
//     {
//       rel: 'alternate',
//       href: 'http://example.com/pages/14.json',
//       type: 'application/json'
//     },
//     {
//       rel: 'prev':
//       href: 'http://example.com/pages/13'
//     }
//   ]
//
//   parseLinks(links, 'alternate')
//   # => [{rel: 'alternate', href: 'http://...', ... }]
//   parseLinks(links, 'alternate', {type: 'text/html'})
//   # => []
//
function parseLinks(data, rel, cond) {
    cond = $.extend({}, cond, {rel: rel});

    var results = [];
    for (var i = 0, len = data.length; i < len; i++) {
        var d = data[i],
            match = true;

        for (var k in cond) {
            if (cond.hasOwnProperty(k) && d[k] !== cond[k]) {
                match = false;
                break;
            }
        }

        if (match) {
            results.push(d);
        }
    }

    return results;
}


// Public: Creates an element for viewing annotations.
var Viewer = exports.Viewer = Widget.extend({

    // Public: Creates an instance of the Viewer object.
    //
    // options - An Object containing options.
    //
    // Examples
    //
    //   # Creates a new viewer, adds a custom field and displays an annotation.
    //   viewer = new Viewer()
    //   viewer.addField({
    //     load: someLoadCallback
    //   })
    //   viewer.load(annotation)
    //
    // Returns a new Viewer instance.
    constructor: function (options) {
        Widget.call(this, options);

        this.itemTemplate = Viewer.itemTemplate;
        this.fields = [];
        this.annotations = [];
        this.hideTimer = null;
        this.hideTimerDfd = null;
        this.hideTimerActivity = null;
        this.mouseDown = false;
        this.render = function (annotation) {
            if (annotation.text) {
                return util.escapeHtml(annotation.text);
            } else {
                return "<i>" + _t('No comment') + "</i>";
            }
        };

        var self = this;

        if (this.options.defaultFields) {
            this.addField({
                load: function (field, annotation) {
                    $(field).html(self.render(annotation));
                }
            });
        }

        if (typeof this.options.onEdit !== 'function') {
            throw new TypeError("onEdit callback must be a function");
        }
        if (typeof this.options.onDelete !== 'function') {
            throw new TypeError("onDelete callback must be a function");
        }
        if (typeof this.options.permitEdit !== 'function') {
            throw new TypeError("permitEdit callback must be a function");
        }
        if (typeof this.options.permitDelete !== 'function') {
            throw new TypeError("permitDelete callback must be a function");
        }

        if (this.options.autoViewHighlights) {
            this.document = this.options.autoViewHighlights.ownerDocument;

            $(this.options.autoViewHighlights)
                .on("mouseover." + NS, '.annotator-hl', function (event) {
                    // If there are many overlapping highlights, still only
                    // call _onHighlightMouseover once.
                    if (event.target === this) {
                        self._onHighlightMouseover(event);
                    }
                })
                .on("mouseleave." + NS, '.annotator-hl', function () {
                    self._startHideTimer();
                });

            $(this.document.body)
                .on("mousedown." + NS, function (e) {
                    if (e.which === 1) {
                        self.mouseDown = true;
                    }
                })
                .on("mouseup." + NS, function (e) {
                    if (e.which === 1) {
                        self.mouseDown = false;
                    }
                });
        }

        this.element
            .on("click." + NS, '.annotator-edit', function (e) {
                self._onEditClick(e);
            })
            .on("click." + NS, '.annotator-delete', function (e) {
                self._onDeleteClick(e);
            })
            .on("mouseenter." + NS, function () {
                self._clearHideTimer();
            })
            .on("mouseleave." + NS, function () {
                self._startHideTimer();
            });
    },

    destroy: function () {
        if (this.options.autoViewHighlights) {
            $(this.options.autoViewHighlights).off("." + NS);
            $(this.document.body).off("." + NS);
        }
        this.element.off("." + NS);
        Widget.prototype.destroy.call(this);
    },

    // Public: Show the viewer.
    //
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Examples
    //
    //   viewer.show()
    //   viewer.hide()
    //   viewer.show({top: '100px', left: '80px'})
    //
    // Returns nothing.
    show: function (position) {
        if (typeof position !== 'undefined' && position !== null) {
            this.element.css({
                top: position.top,
                left: position.left
            });
        }

        var controls = this.element
            .find('.annotator-controls')
            .addClass(this.classes.showControls);

        var self = this;
        setTimeout(function () {
            controls.removeClass(self.classes.showControls);
        }, 500);

        Widget.prototype.show.call(this);
    },

    // Public: Load annotations into the viewer and show it.
    //
    // annotation - An Array of annotations.
    //
    // Examples
    //
    //   viewer.load([annotation1, annotation2, annotation3])
    //
    // Returns nothing.
    load: function (annotations, position) {
        this.annotations = annotations || [];

        var list = this.element.find('ul:first').empty();

        for (var i = 0, len = this.annotations.length; i < len; i++) {
            var annotation = this.annotations[i];
            this._annotationItem(annotation)
              .appendTo(list)
              .data('annotation', annotation);
        }

        this.show(position);
    },

    // Public: Set the annotation renderer.
    //
    // renderer - A function that accepts an annotation and returns HTML.
    //
    // Returns nothing.
    setRenderer: function (renderer) {
        this.render = renderer;
    },

    // Private: create the list item for a single annotation
    _annotationItem: function (annotation) {
        var item = $(this.itemTemplate).clone();

        var controls = item.find('.annotator-controls'),
            link = controls.find('.annotator-link'),
            edit = controls.find('.annotator-edit'),
            del  = controls.find('.annotator-delete');

        var links = parseLinks(
            annotation.links || [],
            'alternate',
            {'type': 'text/html'}
        );
        var hasValidLink = (links.length > 0 &&
                            typeof links[0].href !== 'undefined' &&
                            links[0].href !== null);

        if (hasValidLink) {
            link.attr('href', links[0].href);
        } else {
            link.remove();
        }

        var controller = {};
        if (this.options.permitEdit(annotation)) {
            controller.showEdit = function () {
                edit.removeAttr('disabled');
            };
            controller.hideEdit = function () {
                edit.attr('disabled', 'disabled');
            };
        } else {
            edit.remove();
        }
        if (this.options.permitDelete(annotation)) {
            controller.showDelete = function () {
                del.removeAttr('disabled');
            };
            controller.hideDelete = function () {
                del.attr('disabled', 'disabled');
            };
        } else {
            del.remove();
        }

        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];
            var element = $(field.element).clone().appendTo(item)[0];
            field.load(element, annotation, controller);
        }

        return item;
    },

    // Public: Adds an addional field to an annotation view. A callback can be
    // provided to update the view on load.
    //
    // options - An options Object. Options are as follows:
    //           load - Callback Function called when the view is loaded with an
    //                  annotation. Recieves a newly created clone of an item
    //                  and the annotation to be displayed (it will be called
    //                  once for each annotation being loaded).
    //
    // Examples
    //
    //   # Display a user name.
    //   viewer.addField({
    //     # This is called when the viewer is loaded.
    //     load: (field, annotation) ->
    //       field = $(field)
    //
    //       if annotation.user
    //         field.text(annotation.user) # Display the user
    //       else
    //         field.remove()              # Do not display the field.
    //   })
    //
    // Returns itself.
    addField: function (options) {
        var field = $.extend({
            load: function () {}
        }, options);

        field.element = $('<div />')[0];
        this.fields.push(field);
        return this;
    },

    // Event callback: called when the edit button is clicked.
    //
    // event - An Event object.
    //
    // Returns nothing.
    _onEditClick: function (event) {
        var item = $(event.target)
            .parents('.annotator-annotation')
            .data('annotation');
        this.hide();
        this.options.onEdit(item);
    },

    // Event callback: called when the delete button is clicked.
    //
    // event - An Event object.
    //
    // Returns nothing.
    _onDeleteClick: function (event) {
        var item = $(event.target)
            .parents('.annotator-annotation')
            .data('annotation');
        this.hide();
        this.options.onDelete(item);
    },

    // Event callback: called when a user triggers `mouseover` on a highlight
    // element.
    //
    // event - An Event object.
    //
    // Returns nothing.
    _onHighlightMouseover: function (event) {
        // If the mouse button is currently depressed, we're probably trying to
        // make a selection, so we shouldn't show the viewer.
        if (this.mouseDown) {
            return;
        }

        var self = this;
        this._startHideTimer(true)
            .done(function () {
                var annotations = $(event.target)
                    .parents('.annotator-hl')
                    .addBack()
                    .map(function (_, elem) {
                        return $(elem).data("annotation");
                    })
                    .toArray();

                // Now show the viewer with the wanted annotations
                self.load(annotations, util.mousePosition(event));
            });
    },

    // Starts the hide timer. This returns a promise that is resolved when the
    // viewer has been hidden. If the viewer is already hidden, the promise will
    // be resolved instantly.
    //
    // activity - A boolean indicating whether the need to hide is due to a user
    //            actively indicating a desire to view another annotation (as
    //            opposed to merely mousing off the current one). Default: false
    //
    // Returns a Promise.
    _startHideTimer: function (activity) {
        if (typeof activity === 'undefined' || activity === null) {
            activity = false;
        }

        // If timer has already been set, use that one.
        if (this.hideTimer) {
            if (activity === false || this.hideTimerActivity === activity) {
                return this.hideTimerDfd;
            } else {
                // The pending timeout is an inactivity timeout, so likely to be
                // too slow. Clear the pending timeout and start a new (shorter)
                // one!
                this._clearHideTimer();
            }
        }

        var timeout;
        if (activity) {
            timeout = this.options.activityDelay;
        } else {
            timeout = this.options.inactivityDelay;
        }

        this.hideTimerDfd = $.Deferred();

        if (!this.isShown()) {
            this.hideTimer = null;
            this.hideTimerDfd.resolve();
            this.hideTimerActivity = null;
        } else {
            var self = this;
            this.hideTimer = setTimeout(function () {
                self.hide();
                self.hideTimerDfd.resolve();
                self.hideTimer = null;
            }, timeout);
            this.hideTimerActivity = Boolean(activity);
        }

        return this.hideTimerDfd.promise();
    },

    // Clears the hide timer. Also rejects any promise returned by a previous
    // call to _startHideTimer.
    //
    // Returns nothing.
    _clearHideTimer: function () {
        clearTimeout(this.hideTimer);
        this.hideTimer = null;
        this.hideTimerDfd.reject();
        this.hideTimerActivity = null;
    }
});

// Classes for toggling annotator state.
Viewer.classes = {
    showControls: 'annotator-visible'
};

// HTML templates for this.widget and this.item properties.
Viewer.template = [
    '<div class="annotator-outer annotator-viewer annotator-hide">',
    '  <ul class="annotator-widget annotator-listing"></ul>',
    '</div>'
].join('\n');

Viewer.itemTemplate = [
    '<li class="annotator-annotation annotator-item">',
    '  <span class="annotator-controls">',
    '    <a href="#"',
    '       title="' + _t('View as webpage') + '"',
    '       class="annotator-link">' + _t('View as webpage') + '</a>',
    '    <button type="button"',
    '            title="' + _t('Edit') + '"',
    '            class="annotator-edit">' + _t('Edit') + '</button>',
    '    <button type="button"',
    '            title="' + _t('Delete') + '"',
    '            class="annotator-delete">' + _t('Delete') + '</button>',
    '  </span>',
    '</li>'
].join('\n');

// Configuration options
Viewer.options = {
    // Add the default field(s) to the viewer.
    defaultFields: true,

    // Time, in milliseconds, before the viewer is hidden when a user mouses off
    // the viewer.
    inactivityDelay: 500,

    // Time, in milliseconds, before the viewer is updated when a user mouses
    // over another annotation.
    activityDelay: 100,

    // Hook, passed an annotation, which determines if the viewer's "edit"
    // button is shown. If it is not a function, the button will not be shown.
    permitEdit: function () { return false; },

    // Hook, passed an annotation, which determines if the viewer's "delete"
    // button is shown. If it is not a function, the button will not be shown.
    permitDelete: function () { return false; },

    // If set to a DOM Element, will set up the viewer to automatically display
    // when the user hovers over Annotator highlights within that element.
    autoViewHighlights: null,

    // Callback, called when the user clicks the edit button for an annotation.
    onEdit: function () {},

    // Callback, called when the user clicks the delete button for an
    // annotation.
    onDelete: function () {}
};


// standalone is a module that uses the Viewer to display an viewer widget in
// response to some viewer action (such as mousing over an annotator highlight
// element).
exports.standalone = function standalone(options) {
    var widget;

    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    return {
        start: function (app) {
            var ident = app.registry.getUtility('identityPolicy');
            var authz = app.registry.getUtility('authorizationPolicy');

            // Set default handlers for what happens when the user clicks the
            // edit and delete buttons:
            if (typeof options.onEdit === 'undefined') {
                options.onEdit = function (annotation) {
                    app.annotations.update(annotation);
                };
            }
            if (typeof options.onDelete === 'undefined') {
                options.onDelete = function (annotation) {
                    app.annotations['delete'](annotation);
                };
            }

            // Set default handlers that determine whether the edit and delete
            // buttons are shown in the viewer:
            if (typeof options.permitEdit === 'undefined') {
                options.permitEdit = function (annotation) {
                    return authz.permits('update', annotation, ident.who());
                };
            }
            if (typeof options.permitDelete === 'undefined') {
                options.permitDelete = function (annotation) {
                    return authz.permits('delete', annotation, ident.who());
                };
            }

            widget = new exports.Viewer(options);
        },

        destroy: function () { widget.destroy(); }
    };
};

},{"../util":39,"./widget":38}],38:[function(require,module,exports){
(function (global){
"use strict";

var extend = require('backbone-extend-standalone');

var util = require('../util');
var $ = util.$;


// Public: Base class for the Editor and Viewer elements. Contains methods that
// are shared between the two.
function Widget(options) {
    this.element = $(this.constructor.template);
    this.classes = $.extend({}, Widget.classes, this.constructor.classes);
    this.options = $.extend(
      {},
      Widget.options,
      this.constructor.options,
      options
    );
    this.extensionsInstalled = false;
}

// Public: Destroy the Widget, unbinding all events and removing the element.
//
// Returns nothing.
Widget.prototype.destroy = function () {
    this.element.remove();
};

// Executes all given widget-extensions
Widget.prototype.installExtensions = function () {
    if (this.options.extensions) {
        for (var i = 0, len = this.options.extensions.length; i < len; i++) {
            var extension = this.options.extensions[i];
            extension(this);
        }
    }
};

Widget.prototype._maybeInstallExtensions = function () {
    if (!this.extensionsInstalled) {
        this.extensionsInstalled = true;
        this.installExtensions();
    }
};

// Public: Attach the widget to a css selector or element
// Plus do any post-construction install
Widget.prototype.attach = function () {
    this.element.appendTo(this.options.appendTo);
    this._maybeInstallExtensions();
};

// Public: Show the widget.
//
// Returns nothing.
Widget.prototype.show = function () {
    this.element.removeClass(this.classes.hide);

    // invert if necessary
    this.checkOrientation();
};

// Public: Hide the widget.
//
// Returns nothing.
Widget.prototype.hide = function () {
    $(this.element).addClass(this.classes.hide);
};

// Public: Returns true if the widget is currently displayed, false otherwise.
//
// Examples
//
//   widget.show()
//   widget.isShown() # => true
//
//   widget.hide()
//   widget.isShown() # => false
//
// Returns true if the widget is visible.
Widget.prototype.isShown = function () {
    return !$(this.element).hasClass(this.classes.hide);
};

Widget.prototype.checkOrientation = function () {
    this.resetOrientation();

    var $win = $(global),
        $widget = this.element.children(":first"),
        offset = $widget.offset(),
        viewport = {
            top: $win.scrollTop(),
            right: $win.width() + $win.scrollLeft()
        },
        current = {
            top: offset.top,
            right: offset.left + $widget.width()
        };

    if ((current.top - viewport.top) < 0) {
        this.invertY();
    }

    if ((current.right - viewport.right) > 0) {
        this.invertX();
    }

    return this;
};

// Public: Resets orientation of widget on the X & Y axis.
//
// Examples
//
//   widget.resetOrientation() # Widget is original way up.
//
// Returns itself for chaining.
Widget.prototype.resetOrientation = function () {
    this.element
        .removeClass(this.classes.invert.x)
        .removeClass(this.classes.invert.y);
    return this;
};

// Public: Inverts the widget on the X axis.
//
// Examples
//
//   widget.invertX() # Widget is now right aligned.
//
// Returns itself for chaining.
Widget.prototype.invertX = function () {
    this.element.addClass(this.classes.invert.x);
    return this;
};

// Public: Inverts the widget on the Y axis.
//
// Examples
//
//   widget.invertY() # Widget is now upside down.
//
// Returns itself for chaining.
Widget.prototype.invertY = function () {
    this.element.addClass(this.classes.invert.y);
    return this;
};

// Public: Find out whether or not the widget is currently upside down
//
// Returns a boolean: true if the widget is upside down
Widget.prototype.isInvertedY = function () {
    return this.element.hasClass(this.classes.invert.y);
};

// Public: Find out whether or not the widget is currently right aligned
//
// Returns a boolean: true if the widget is right aligned
Widget.prototype.isInvertedX = function () {
    return this.element.hasClass(this.classes.invert.x);
};

// Classes used to alter the widgets state.
Widget.classes = {
    hide: 'annotator-hide',
    invert: {
        x: 'annotator-invert-x',
        y: 'annotator-invert-y'
    }
};

Widget.template = "<div></div>";

// Default options for the widget.
Widget.options = {
    // A CSS selector or Element to append the Widget to.
    appendTo: 'body'
};

Widget.extend = extend;


exports.Widget = Widget;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"../util":39,"backbone-extend-standalone":3}],39:[function(require,module,exports){
(function (global){
"use strict";

var Promise = require('es6-promise').Promise;

var ESCAPE_MAP = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
    "/": "&#47;"
};


// escapeHtml sanitizes special characters in text that could be interpreted as
// HTML.
function escapeHtml(string) {
    return String(string).replace(/[&<>"'\/]/g, function (c) {
        return ESCAPE_MAP[c];
    });
}


// I18N
var gettext = (function () {
    if (typeof global.Gettext === 'function') {
        var _gettext = new global.Gettext({domain: "annotator"});
        return function (msgid) { return _gettext.gettext(msgid); };
    }

    return function (msgid) { return msgid; };
}());


// Returns the absolute position of the mouse relative to the top-left rendered
// corner of the page (taking into account padding/margin/border on the body
// element as necessary).
function mousePosition(event) {
    var body = global.document.body;
    var offset = {top: 0, left: 0};

    if ($(body).css('position') !== "static") {
        offset = $(body).offset();
    }

    return {
        top: event.pageY - offset.top,
        left: event.pageX - offset.left
    };
}


exports.$ = $;
exports.Promise = Promise;
exports.gettext = gettext;
exports.escapeHtml = escapeHtml;
exports.mousePosition = mousePosition;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"es6-promise":5,"jquery":17}]},{},[1])(1)
});
