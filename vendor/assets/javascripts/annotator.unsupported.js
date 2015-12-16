(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (global){
"use strict";

var annotator = (typeof window !== "undefined" ? window.annotator : typeof global !== "undefined" ? global.annotator : null);
var _t = annotator.util.gettext;

/**
 * function:: checkSupport([scope=window])
 *
 * Examines `scope` (by default the global window object) to determine if
 * Annotator can be used in this environment.
 *
 * :returns Object:
 *   - `supported`: Boolean, whether Annotator can be used in `scope`.
 *   - `details`: Array of String reasons why Annotator cannot be used.
 */
function checkSupport(scope) {
    if (typeof scope === 'undefined' || scope === null) {
        scope = annotator.global;
    }

    var errors = [];

    if (typeof scope.getSelection !== 'function') {
        errors.push(_t("current scope lacks an implementation of the W3C " +
                       "Range API"));
    }

    // We require a working JSON implementation.
    if (typeof scope.JSON === 'undefined' ||
        typeof scope.JSON.parse !== 'function' ||
        typeof scope.JSON.stringify !== 'function') {
        errors.push(_t("current scope lacks a working JSON implementation"));
    }

    return {
        supported: errors.length === 0,
        errors: errors
    };
}


// unsupported serves one very simple purpose. It will display a notification to
// the user if Annotator cannot support their current browser.
function unsupported() {
    // Reference as exports.checkSupport so that we can stub it for testing.
    var result = exports.checkSupport();

    function fallback(message, severity) {
        if (severity === annotator.notification.ERROR) {
            console.error(message);
            return;
        }
        console.log(message);
    }

    function notifyUser(app) {
        if (result.supported) {
            return;
        }
        var notify = app.registry.queryUtility('notifier') || fallback;
        var msg;
        msg = _t("Sorry, Annotator does not currently support your browser! ");
        msg += _t("Errors: ");
        msg += result.errors.join(", ");
        notify(msg);
    }

    return {
        start: notifyUser
    };
}


annotator.ext.unsupported = unsupported;

exports.checkSupport = checkSupport;
exports.unsupported = unsupported;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}]},{},[1]);
