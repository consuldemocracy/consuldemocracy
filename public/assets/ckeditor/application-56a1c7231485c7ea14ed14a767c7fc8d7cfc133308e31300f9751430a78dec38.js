/*
 * jQuery Templates Plugin 1.0.0pre
 * http://github.com/jquery/jquery-tmpl
 * Requires jQuery 1.4.2
 *
 * Copyright Software Freedom Conservancy, Inc.
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 */

(function(a){var r=a.fn.domManip,d="_tmplitem",q=/^[^<]*(<[\w\W]+>)[^>]*$|\{\{\! /,b={},f={},e,p={key:0,data:{}},i=0,c=0,l=[];function g(g,d,h,e){var c={data:e||(e===0||e===false)?e:d?d.data:{},_wrap:d?d._wrap:null,tmpl:null,parent:d||null,nodes:[],calls:u,nest:w,wrap:x,html:v,update:t};g&&a.extend(c,g,{nodes:[],parent:d});if(h){c.tmpl=h;c._ctnt=c._ctnt||c.tmpl(a,c);c.key=++i;(l.length?f:b)[i]=c}return c}a.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(f,d){a.fn[f]=function(n){var g=[],i=a(n),k,h,m,l,j=this.length===1&&this[0].parentNode;e=b||{};if(j&&j.nodeType===11&&j.childNodes.length===1&&i.length===1){i[d](this[0]);g=this}else{for(h=0,m=i.length;h<m;h++){c=h;k=(h>0?this.clone(true):this).get();a(i[h])[d](k);g=g.concat(k)}c=0;g=this.pushStack(g,f,i.selector)}l=e;e=null;a.tmpl.complete(l);return g}});a.fn.extend({tmpl:function(d,c,b){return a.tmpl(this[0],d,c,b)},tmplItem:function(){return a.tmplItem(this[0])},template:function(b){return a.template(b,this[0])},domManip:function(d,m,k){if(d[0]&&a.isArray(d[0])){var g=a.makeArray(arguments),h=d[0],j=h.length,i=0,f;while(i<j&&!(f=a.data(h[i++],"tmplItem")));if(f&&c)g[2]=function(b){a.tmpl.afterManip(this,b,k)};r.apply(this,g)}else r.apply(this,arguments);c=0;!e&&a.tmpl.complete(b);return this}});a.extend({tmpl:function(d,h,e,c){var i,k=!c;if(k){c=p;d=a.template[d]||a.template(null,d);f={}}else if(!d){d=c.tmpl;b[c.key]=c;c.nodes=[];c.wrapped&&n(c,c.wrapped);return a(j(c,null,c.tmpl(a,c)))}if(!d)return[];if(typeof h==="function")h=h.call(c||{});e&&e.wrapped&&n(e,e.wrapped);i=a.isArray(h)?a.map(h,function(a){return a?g(e,c,d,a):null}):[g(e,c,d,h)];return k?a(j(c,null,i)):i},tmplItem:function(b){var c;if(b instanceof a)b=b[0];while(b&&b.nodeType===1&&!(c=a.data(b,"tmplItem"))&&(b=b.parentNode));return c||p},template:function(c,b){if(b){if(typeof b==="string")b=o(b);else if(b instanceof a)b=b[0]||{};if(b.nodeType)b=a.data(b,"tmpl")||a.data(b,"tmpl",o(b.innerHTML));return typeof c==="string"?(a.template[c]=b):b}return c?typeof c!=="string"?a.template(null,c):a.template[c]||a.template(null,q.test(c)?c:a(c)):null},encode:function(a){return(""+a).split("<").join("&lt;").split(">").join("&gt;").split('"').join("&#34;").split("'").join("&#39;")}});a.extend(a.tmpl,{tag:{tmpl:{_default:{$2:"null"},open:"if($notnull_1){__=__.concat($item.nest($1,$2));}"},wrap:{_default:{$2:"null"},open:"$item.calls(__,$1,$2);__=[];",close:"call=$item.calls();__=call._.concat($item.wrap(call,__));"},each:{_default:{$2:"$index, $value"},open:"if($notnull_1){$.each($1a,function($2){with(this){",close:"}});}"},"if":{open:"if(($notnull_1) && $1a){",close:"}"},"else":{_default:{$1:"true"},open:"}else if(($notnull_1) && $1a){"},html:{open:"if($notnull_1){__.push($1a);}"},"=":{_default:{$1:"$data"},open:"if($notnull_1){__.push($.encode($1a));}"},"!":{open:""}},complete:function(){b={}},afterManip:function(f,b,d){var e=b.nodeType===11?a.makeArray(b.childNodes):b.nodeType===1?[b]:[];d.call(f,b);m(e);c++}});function j(e,g,f){var b,c=f?a.map(f,function(a){return typeof a==="string"?e.key?a.replace(/(<\w+)(?=[\s>])(?![^>]*_tmplitem)([^>]*)/g,"$1 "+d+'="'+e.key+'" $2'):a:j(a,e,a._ctnt)}):e;if(g)return c;c=c.join("");c.replace(/^\s*([^<\s][^<]*)?(<[\w\W]+>)([^>]*[^>\s])?\s*$/,function(f,c,e,d){b=a(e).get();m(b);if(c)b=k(c).concat(b);if(d)b=b.concat(k(d))});return b?b:k(c)}function k(c){var b=document.createElement("div");b.innerHTML=c;return a.makeArray(b.childNodes)}function o(b){return new Function("jQuery","$item","var $=jQuery,call,__=[],$data=$item.data;with($data){__.push('"+a.trim(b).replace(/([\\'])/g,"\\$1").replace(/[\r\t\n]/g," ").replace(/\$\{([^\}]*)\}/g,"{{= $1}}").replace(/\{\{(\/?)(\w+|.)(?:\(((?:[^\}]|\}(?!\}))*?)?\))?(?:\s+(.*?)?)?(\(((?:[^\}]|\}(?!\}))*?)\))?\s*\}\}/g,function(m,l,k,g,b,c,d){var j=a.tmpl.tag[k],i,e,f;if(!j)throw"Unknown template tag: "+k;i=j._default||[];if(c&&!/\w$/.test(b)){b+=c;c=""}if(b){b=h(b);d=d?","+h(d)+")":c?")":"";e=c?b.indexOf(".")>-1?b+h(c):"("+b+").call($item"+d:b;f=c?e:"(typeof("+b+")==='function'?("+b+").call($item):("+b+"))"}else f=e=i.$1||"null";g=h(g);return"');"+j[l?"close":"open"].split("$notnull_1").join(b?"typeof("+b+")!=='undefined' && ("+b+")!=null":"true").split("$1a").join(f).split("$1").join(e).split("$2").join(g||i.$2||"")+"__.push('"})+"');}return __;")}function n(c,b){c._wrap=j(c,true,a.isArray(b)?b:[q.test(b)?b:a(b).html()]).join("")}function h(a){return a?a.replace(/\\'/g,"'").replace(/\\\\/g,"\\"):null}function s(b){var a=document.createElement("div");a.appendChild(b.cloneNode(true));return a.innerHTML}function m(o){var n="_"+c,k,j,l={},e,p,h;for(e=0,p=o.length;e<p;e++){if((k=o[e]).nodeType!==1)continue;j=k.getElementsByTagName("*");for(h=j.length-1;h>=0;h--)m(j[h]);m(k)}function m(j){var p,h=j,k,e,m;if(m=j.getAttribute(d)){while(h.parentNode&&(h=h.parentNode).nodeType===1&&!(p=h.getAttribute(d)));if(p!==m){h=h.parentNode?h.nodeType===11?0:h.getAttribute(d)||0:0;if(!(e=b[m])){e=f[m];e=g(e,b[h]||f[h]);e.key=++i;b[i]=e}c&&o(m)}j.removeAttribute(d)}else if(c&&(e=a.data(j,"tmplItem"))){o(e.key);b[e.key]=e;h=a.data(j.parentNode,"tmplItem");h=h?h.key:0}if(e){k=e;while(k&&k.key!=h){k.nodes.push(j);k=k.parent}delete e._ctnt;delete e._wrap;a.data(j,"tmplItem",e)}function o(a){a=a+n;e=l[a]=l[a]||g(e,b[e.parent.key+n]||e.parent)}}}function u(a,d,c,b){if(!a)return l.pop();l.push({_:a,tmpl:d,item:this,data:c,options:b})}function w(d,c,b){return a.tmpl(a.template(d),c,b,this)}function x(b,d){var c=b.options||{};c.wrapped=d;return a.tmpl(a.template(b.tmpl),b.data,c,b.item)}function v(d,c){var b=this._wrap;return a.map(a(a.isArray(b)?b.join(""):b).filter(d||"*"),function(a){return c?a.innerText||a.textContent:a.outerHTML||s(a)})}function t(){var b=this.nodes;a.tmpl(null,null,null,this).insertBefore(b[0]);a(b).remove()}})(jQuery);
/**
 * http://github.com/valums/file-uploader
 * 
 * Multiple file upload component with progress-bar, drag-and-drop. 
 * © 2010 Andrew Valums ( andrew(at)valums.com ) 
 * 
 * Licensed under GNU GPL 2 or later, see license.txt.
 */    

//
// Helper functions
//

var qq = qq || {};

/**
 * Adds all missing properties from second obj to first obj
 */ 
qq.extend = function(first, second){
    for (var prop in second){
        first[prop] = second[prop];
    }
};  

/**
 * Searches for a given element in the array, returns -1 if it is not present.
 * @param {Number} [from] The index at which to begin the search
 */
qq.indexOf = function(arr, elt, from){
    if (arr.indexOf) return arr.indexOf(elt, from);
    
    from = from || 0;
    var len = arr.length;    
    
    if (from < 0) from += len;  

    for (; from < len; from++){  
        if (from in arr && arr[from] === elt){  
            return from;
        }
    }  
    return -1;  
}; 
    
qq.getUniqueId = (function(){
    var id = 0;
    return function(){ return id++; };
})();

//
// Events

qq.attach = function(element, type, fn){
    if (element.addEventListener){
        element.addEventListener(type, fn, false);
    } else if (element.attachEvent){
        element.attachEvent('on' + type, fn);
    }
};
qq.detach = function(element, type, fn){
    if (element.removeEventListener){
        element.removeEventListener(type, fn, false);
    } else if (element.attachEvent){
        element.detachEvent('on' + type, fn);
    }
};

qq.preventDefault = function(e){
    if (e.preventDefault){
        e.preventDefault();
    } else{
        e.returnValue = false;
    }
};

//
// Node manipulations

/**
 * Insert node a before node b.
 */
qq.insertBefore = function(a, b){
    b.parentNode.insertBefore(a, b);
};
qq.remove = function(element){
    element.parentNode.removeChild(element);
};

qq.contains = function(parent, descendant){       
    // compareposition returns false in this case
    if (parent == descendant) return true;
    
    if (parent.contains){
        return parent.contains(descendant);
    } else {
        return !!(descendant.compareDocumentPosition(parent) & 8);
    }
};

/**
 * Creates and returns element from html string
 * Uses innerHTML to create an element
 */
qq.toElement = (function(){
    var div = document.createElement('div');
    return function(html){
        div.innerHTML = html;
        var element = div.firstChild;
        div.removeChild(element);
        return element;
    };
})();

//
// Node properties and attributes

/**
 * Sets styles for an element.
 * Fixes opacity in IE6-8.
 */
qq.css = function(element, styles){
    if (styles.opacity != null){
        if (typeof element.style.opacity != 'string' && typeof(element.filters) != 'undefined'){
            styles.filter = 'alpha(opacity=' + Math.round(100 * styles.opacity) + ')';
        }
    }
    qq.extend(element.style, styles);
};
qq.hasClass = function(element, name){
    var re = new RegExp('(^| )' + name + '( |$)');
    return re.test(element.className);
};
qq.addClass = function(element, name){
    if (!qq.hasClass(element, name)){
        element.className += ' ' + name;
    }
};
qq.removeClass = function(element, name){
    var re = new RegExp('(^| )' + name + '( |$)');
    element.className = element.className.replace(re, ' ').replace(/^\s+|\s+$/g, "");
};
qq.setText = function(element, text){
    element.innerText = text;
    element.textContent = text;
};

//
// Selecting elements

qq.children = function(element){
    var children = [],
    child = element.firstChild;

    while (child){
        if (child.nodeType == 1){
            children.push(child);
        }
        child = child.nextSibling;
    }

    return children;
};

qq.getByClass = function(element, className){
    if (element.querySelectorAll){
        return element.querySelectorAll('.' + className);
    }

    var result = [];
    var candidates = element.getElementsByTagName("*");
    var len = candidates.length;

    for (var i = 0; i < len; i++){
        if (qq.hasClass(candidates[i], className)){
            result.push(candidates[i]);
        }
    }
    return result;
};

/**
 * obj2url() takes a json-object as argument and generates
 * a querystring. pretty much like jQuery.param()
 * 
 * how to use:
 *
 *    `qq.obj2url({a:'b',c:'d'},'http://any.url/upload?otherParam=value');`
 *
 * will result in:
 *
 *    `http://any.url/upload?otherParam=value&a=b&c=d`
 *
 * @param  Object JSON-Object
 * @param  String current querystring-part
 * @return String encoded querystring
 */
qq.obj2url = function(obj, temp, prefixDone){
    var uristrings = [],
        prefix = '&',
        add = function(nextObj, i){
            var nextTemp = temp 
                ? (/\[\]$/.test(temp)) // prevent double-encoding
                   ? temp
                   : temp+'['+i+']'
                : i;
            if ((nextTemp != 'undefined') && (i != 'undefined')) {  
                uristrings.push(
                    (typeof nextObj === 'object') 
                        ? qq.obj2url(nextObj, nextTemp, true)
                        : (Object.prototype.toString.call(nextObj) === '[object Function]')
                            ? encodeURIComponent(nextTemp) + '=' + encodeURIComponent(nextObj())
                            : encodeURIComponent(nextTemp) + '=' + encodeURIComponent(nextObj)                                                          
                );
            }
        }; 

    if (!prefixDone && temp) {
      prefix = (/\?/.test(temp)) ? (/\?$/.test(temp)) ? '' : '&' : '?';
      uristrings.push(temp);
      uristrings.push(qq.obj2url(obj));
    } else if ((Object.prototype.toString.call(obj) === '[object Array]') && (typeof obj != 'undefined') ) {
        // we wont use a for-in-loop on an array (performance)
        for (var i = 0, len = obj.length; i < len; ++i){
            add(obj[i], i);
        }
    } else if ((typeof obj != 'undefined') && (obj !== null) && (typeof obj === "object")){
        // for anything else but a scalar, we will use for-in-loop
        for (var i in obj){
            add(obj[i], i);
        }
    } else {
        uristrings.push(encodeURIComponent(temp) + '=' + encodeURIComponent(obj));
    }

    return uristrings.join(prefix)
                     .replace(/^&/, '')
                     .replace(/%20/g, '+'); 
};

//
//
// Uploader Classes
//
//

var qq = qq || {};
    
/**
 * Creates upload button, validates upload, but doesn't create file list or dd. 
 */
qq.FileUploaderBasic = function(o){
    this._options = {
        // set to true to see the server response
        debug: false,
        action: '/server/upload',
        params: {},
        button: null,
        multiple: true,
        maxConnections: 3,
        method: 'POST',
        fieldName: 'qqfile',
        // validation        
        allowedExtensions: [],               
        sizeLimit: 0,   
        minSizeLimit: 0,
        maxFilesCount: 0, // 0 - no limit, works only in multiple mode
        minFilesCount: 0, // 0 - no limit, works only in multiple mode
        // events
        // return false to cancel submit
        onSubmit: function(id, fileName){},
        onProgress: function(id, fileName, loaded, total){},
        onComplete: function(id, fileName, responseJSON){},
        onCancel: function(id, fileName){},
        // messages                
        messages: {
            typeError: "{file} has invalid extension. Only {extensions} are allowed.",
            sizeError: "{file} is too large, maximum file size is {sizeLimit}.",
            minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
            emptyError: "{file} is empty, please select files again without it.",
            onLeave: "The files are being uploaded, if you leave now the upload will be cancelled.",
            maxFilesError: "You must select less then {maxFilesCount} files.",
            minFilesError: "You must select more then {minFilesCount} files."
        },
        showMessage: function(message){
            alert(message);
        }               
    };
    qq.extend(this._options, o);
        
    // number of files being uploaded
    this._filesInProgress = 0;
    // number of files was processed
    this._filesUploaded = 0;
    this._handler = this._createUploadHandler(); 
    
    if (this._options.button){ 
        this._button = this._createUploadButton(this._options.button);
    }
                        
    this._preventLeaveInProgress();         
};
   
qq.FileUploaderBasic.prototype = {
    setParams: function(params){
        this._options.params = params;
    },
    getInProgress: function(){
        return this._filesInProgress;         
    },
    _createUploadButton: function(element){
        var self = this;
        
        return new qq.UploadButton({
            element: element,
            multiple: this._options.multiple && qq.UploadHandlerXhr.isSupported(),
            onChange: function(input){
                self._onInputChange(input);
            }        
        });           
    },    
    _createUploadHandler: function(){
        var self = this,
            handlerClass;        
        
        if(qq.UploadHandlerXhr.isSupported()){           
            handlerClass = 'UploadHandlerXhr';                        
        } else {
            handlerClass = 'UploadHandlerForm';
        }

        var handler = new qq[handlerClass]({
            debug: this._options.debug,
            action: this._options.action,         
            maxConnections: this._options.maxConnections,
            fieldName: this._options.fieldName,
            method: this._options.method,   
            onProgress: function(id, fileName, loaded, total){                
                self._onProgress(id, fileName, loaded, total);
                self._options.onProgress(id, fileName, loaded, total);                    
            },            
            onComplete: function(id, fileName, result){
                self._onComplete(id, fileName, result);
                self._options.onComplete(id, fileName, result);
            },
            onCancel: function(id, fileName){
                self._onCancel(id, fileName);
                self._options.onCancel(id, fileName);
            }
        });

        return handler;
    },    
    _preventLeaveInProgress: function(){
        var self = this;
        
        qq.attach(window, 'beforeunload', function(e){
            if (!self._filesInProgress){return;}
            
            var e = e || window.event;
            // for ie, ff
            e.returnValue = self._options.messages.onLeave;
            // for webkit
            return self._options.messages.onLeave;             
        });        
    },    
    _onSubmit: function(id, fileName){
        this._filesInProgress++;  
    },
    _onProgress: function(id, fileName, loaded, total){        
    },
    _onComplete: function(id, fileName, result){
        this._filesInProgress--;                 
        if (result.error){
            this._options.showMessage(result.error);
        } else {
          this._filesUploaded++;
        }             
    },
    _onCancel: function(id, fileName){
        this._filesInProgress--;        
    },
    _onInputChange: function(input){
        if (this._handler instanceof qq.UploadHandlerXhr){                
            this._uploadFileList(input.files);                   
        } else {             
            if (this._validateFile(input)){                
                this._uploadFile(input);                                    
            }                      
        }               
        this._button.reset();   
    },  
    _uploadFileList: function(files){
        if ( this._validateFiles(files) ) {
          for (var i=0; i<files.length; i++){
              this._uploadFile(files[i]);        
          }
        }
    },       
    _uploadFile: function(fileContainer){      
        var id = this._handler.add(fileContainer);
        var fileName = this._handler.getName(id);
        
        if (this._options.onSubmit(id, fileName) !== false){
            this._onSubmit(id, fileName);
            this._handler.upload(id, this._options.params);
        }
    },
    _validateFiles: function(files){
        var uploadedCount = this._filesUploaded + files.length;
        
        if (this._options.maxFilesCount > 0) {
          if ( uploadedCount > this._options.maxFilesCount) { 
            this._error('maxFilesError', 'name');
            return false;
          }
        }
        
        if (this._options.minFilesCount > 0) {
          if ( uploadedCount < this._options.minFilesCount) {
            this._error('minFilesError', 'name');
            return false;
          }
        }
        
        for (var i=0; i<files.length; i++){
            if ( !this._validateFile(files[i])){
                return false;
            }            
        }
        
        return true;
    },      
    _validateFile: function(file){
        var name, size;
        
        if (file.value){
            // it is a file input            
            // get input value and remove path to normalize
            name = file.value.replace(/.*(\/|\\)/, "");
        } else {
            // fix missing properties in Safari
            name = file.fileName != null ? file.fileName : file.name;
            size = file.fileSize != null ? file.fileSize : file.size;
        }
                    
        if (! this._isAllowedExtension(name)){            
            this._error('typeError', name);
            return false;
            
        } else if (size === 0){            
            this._error('emptyError', name);
            return false;
                                                     
        } else if (size && this._options.sizeLimit && size > this._options.sizeLimit){            
            this._error('sizeError', name);
            return false;
                        
        } else if (size && size < this._options.minSizeLimit){
            this._error('minSizeError', name);
            return false;            
        }
        
        return true;                
    },
    _error: function(code, fileName){
        var message = this._options.messages[code];        
        function r(name, replacement){ message = message.replace(name, replacement); }
        
        r('{file}', this._formatFileName(fileName));        
        r('{extensions}', this._options.allowedExtensions.join(', '));
        r('{sizeLimit}', this._formatSize(this._options.sizeLimit));
        r('{minSizeLimit}', this._formatSize(this._options.minSizeLimit));
        r('{maxFilesCount}', this._options.maxFilesCount);
        r('{minFilesCount}', this._options.minFilesCount);
        
        this._options.showMessage(message);                
    },
    _formatFileName: function(name){
        if (name.length > 33){
            name = name.slice(0, 19) + '...' + name.slice(-13);    
        }
        return name;
    },
    _isAllowedExtension: function(fileName){
        var ext = (-1 !== fileName.indexOf('.')) ? fileName.replace(/.*[.]/, '').toLowerCase() : '';
        var allowed = this._options.allowedExtensions;
        
        if (!allowed.length){return true;}        
        
        for (var i=0; i<allowed.length; i++){
            if (allowed[i].toLowerCase() == ext){ return true;}    
        }
        
        return false;
    },    
    _formatSize: function(bytes){
        var i = -1;                                    
        do {
            bytes = bytes / 1024;
            i++;  
        } while (bytes > 99);
        
        return Math.max(bytes, 0.1).toFixed(1) + ['kB', 'MB', 'GB', 'TB', 'PB', 'EB'][i];          
    }
};
    
       
/**
 * Class that creates upload widget with drag-and-drop and file list
 * @inherits qq.FileUploaderBasic
 */
qq.FileUploader = function(o){
    // call parent constructor
    qq.FileUploaderBasic.apply(this, arguments);
    
    // additional options    
    qq.extend(this._options, {
        element: null,
        // if set, will be used instead of qq-upload-list in template
        listElement: null,
                
        template: '<div class="qq-uploader">' + 
                '<div class="qq-upload-drop-area"><span>Drop files here to upload</span></div>' +
                '<div class="qq-upload-button">Upload a file</div>' +
                '<ul class="qq-upload-list"></ul>' + 
             '</div>',

        // template for one item in file list
        fileTemplate: '<li>' +
                '<span class="qq-upload-file"></span>' +
                '<span class="qq-upload-spinner"></span>' +
                '<span class="qq-upload-size"></span>' +
                '<a class="qq-upload-cancel" href="#">Cancel</a>' +
                '<span class="qq-upload-failed-text">Failed</span>' +
            '</li>',        
        
        classes: {
            // used to get elements from templates
            button: 'qq-upload-button',
            drop: 'qq-upload-drop-area',
            dropActive: 'qq-upload-drop-area-active',
            list: 'qq-upload-list',
                        
            file: 'qq-upload-file',
            spinner: 'qq-upload-spinner',
            size: 'qq-upload-size',
            cancel: 'qq-upload-cancel',

            // added to list item when upload completes
            // used in css to hide progress spinner
            success: 'qq-upload-success',
            fail: 'qq-upload-fail'
        }
    });
    // overwrite options with user supplied    
    qq.extend(this._options, o);       

    this._element = this._options.element;
    this._element.innerHTML = this._options.template;        
    this._listElement = this._options.listElement || this._find(this._element, 'list');
    
    this._classes = this._options.classes;
        
    this._button = this._createUploadButton(this._find(this._element, 'button'));        
    
    this._bindCancelEvent();
    this._setupDragDrop();
};

// inherit from Basic Uploader
qq.extend(qq.FileUploader.prototype, qq.FileUploaderBasic.prototype);

qq.extend(qq.FileUploader.prototype, {
    /**
     * Gets one of the elements listed in this._options.classes
     **/
    _find: function(parent, type){                                
        var element = qq.getByClass(parent, this._options.classes[type])[0];        
        if (!element){
            throw new Error('element not found ' + type);
        }
        
        return element;
    },
    _setupDragDrop: function(){
        var self = this,
            dropArea = this._find(this._element, 'drop');                        

        var dz = new qq.UploadDropZone({
            element: dropArea,
            onEnter: function(e){
                qq.addClass(dropArea, self._classes.dropActive);
                e.stopPropagation();
            },
            onLeave: function(e){
                e.stopPropagation();
            },
            onLeaveNotDescendants: function(e){
                qq.removeClass(dropArea, self._classes.dropActive);  
            },
            onDrop: function(e){
                dropArea.style.display = 'none';
                qq.removeClass(dropArea, self._classes.dropActive);
                self._uploadFileList(e.dataTransfer.files);    
            }
        });
                
        dropArea.style.display = 'none';

        qq.attach(document, 'dragenter', function(e){     
            if (!dz._isValidFileDrag(e)) return; 
            
            dropArea.style.display = 'block';            
        });                 
        qq.attach(document, 'dragleave', function(e){
            if (!dz._isValidFileDrag(e)) return;            
            
            var relatedTarget = document.elementFromPoint(e.clientX, e.clientY);
            // only fire when leaving document out
            if ( ! relatedTarget || relatedTarget.nodeName == "HTML"){               
                dropArea.style.display = 'none';                                            
            }
        });                
    },
    _onSubmit: function(id, fileName){
        qq.FileUploaderBasic.prototype._onSubmit.apply(this, arguments);
        this._addToList(id, fileName);  
    },
    _onProgress: function(id, fileName, loaded, total){
        qq.FileUploaderBasic.prototype._onProgress.apply(this, arguments);

        var item = this._getItemByFileId(id);
        var size = this._find(item, 'size');
        size.style.display = 'inline';
        
        var text; 
        if (loaded != total){
            text = Math.round(loaded / total * 100) + '% from ' + this._formatSize(total);
        } else {                                   
            text = this._formatSize(total);
        }          
        
        qq.setText(size, text);         
    },
    _onComplete: function(id, fileName, result){
        qq.FileUploaderBasic.prototype._onComplete.apply(this, arguments);

        // mark completed
        var item = this._getItemByFileId(id);                
        qq.remove(this._find(item, 'cancel'));
        qq.remove(this._find(item, 'spinner'));
        
        if (result.success){
            qq.addClass(item, this._classes.success);    
        } else {
            qq.addClass(item, this._classes.fail);
        }         
    },
    _addToList: function(id, fileName){
        var item = qq.toElement(this._options.fileTemplate);                
        item.qqFileId = id;

        var fileElement = this._find(item, 'file');        
        qq.setText(fileElement, this._formatFileName(fileName));
        this._find(item, 'size').style.display = 'none';        

        this._listElement.appendChild(item);
    },
    _getItemByFileId: function(id){
        var item = this._listElement.firstChild;        
        
        // there can't be txt nodes in dynamically created list
        // and we can  use nextSibling
        while (item){            
            if (item.qqFileId == id) return item;            
            item = item.nextSibling;
        }          
    },
    /**
     * delegate click event for cancel link 
     **/
    _bindCancelEvent: function(){
        var self = this,
            list = this._listElement;            
        
        qq.attach(list, 'click', function(e){            
            e = e || window.event;
            var target = e.target || e.srcElement;
            
            if (qq.hasClass(target, self._classes.cancel)){                
                qq.preventDefault(e);
               
                var item = target.parentNode;
                self._handler.cancel(item.qqFileId);
                qq.remove(item);
            }
        });
    }    
});
    
qq.UploadDropZone = function(o){
    this._options = {
        element: null,  
        onEnter: function(e){},
        onLeave: function(e){},  
        // is not fired when leaving element by hovering descendants   
        onLeaveNotDescendants: function(e){},   
        onDrop: function(e){}                       
    };
    qq.extend(this._options, o); 
    
    this._element = this._options.element;
    
    this._disableDropOutside();
    this._attachEvents();   
};

qq.UploadDropZone.prototype = {
    _disableDropOutside: function(e){
        // run only once for all instances
        if (!qq.UploadDropZone.dropOutsideDisabled ){

            qq.attach(document, 'dragover', function(e){
                if (e.dataTransfer){
                    e.dataTransfer.dropEffect = 'none';
                    e.preventDefault(); 
                }           
            });
            
            qq.UploadDropZone.dropOutsideDisabled = true; 
        }        
    },
    _attachEvents: function(){
        var self = this;              
                  
        qq.attach(self._element, 'dragover', function(e){
            if (!self._isValidFileDrag(e)) return;
            
            var effect = e.dataTransfer.effectAllowed;
            if (effect == 'move' || effect == 'linkMove'){
                e.dataTransfer.dropEffect = 'move'; // for FF (only move allowed)    
            } else {                    
                e.dataTransfer.dropEffect = 'copy'; // for Chrome
            }
                                                     
            e.stopPropagation();
            e.preventDefault();                                                                    
        });
        
        qq.attach(self._element, 'dragenter', function(e){
            if (!self._isValidFileDrag(e)) return;
                        
            self._options.onEnter(e);
        });
        
        qq.attach(self._element, 'dragleave', function(e){
            if (!self._isValidFileDrag(e)) return;
            
            self._options.onLeave(e);
            
            var relatedTarget = document.elementFromPoint(e.clientX, e.clientY);                      
            // do not fire when moving a mouse over a descendant
            if (qq.contains(this, relatedTarget)) return;
                        
            self._options.onLeaveNotDescendants(e); 
        });
                
        qq.attach(self._element, 'drop', function(e){
            if (!self._isValidFileDrag(e)) return;
            
            e.preventDefault();
            self._options.onDrop(e);
        });          
    },
    _isValidFileDrag: function(e){
        var dt = e.dataTransfer,
            // do not check dt.types.contains in webkit, because it crashes safari 4            
            isWebkit = navigator.userAgent.indexOf("AppleWebKit") > -1;                        

        // dt.effectAllowed is none in Safari 5
        // dt.types.contains check is for firefox            
        return dt && dt.effectAllowed != 'none' && 
            (dt.files || (!isWebkit && dt.types.contains && dt.types.contains('Files')));
        
    }        
}; 

qq.UploadButton = function(o){
    this._options = {
        element: null,  
        // if set to true adds multiple attribute to file input      
        multiple: false,
        // name attribute of file input
        name: 'file',
        onChange: function(input){},
        hoverClass: 'qq-upload-button-hover',
        focusClass: 'qq-upload-button-focus'                       
    };
    
    qq.extend(this._options, o);
        
    this._element = this._options.element;
    
    // make button suitable container for input
    qq.css(this._element, {
        position: 'relative',
        overflow: 'hidden',
        // Make sure browse button is in the right side
        // in Internet Explorer
        direction: 'ltr'
    });   
    
    this._input = this._createInput();
};

qq.UploadButton.prototype = {
    /* returns file input element */    
    getInput: function(){
        return this._input;
    },
    /* cleans/recreates the file input */
    reset: function(){
        if (this._input.parentNode){
            qq.remove(this._input);    
        }                
        
        qq.removeClass(this._element, this._options.focusClass);
        this._input = this._createInput();
    },    
    _createInput: function(){                
        var input = document.createElement("input");
        
        if (this._options.multiple){
            input.setAttribute("multiple", "multiple");
        }
                
        input.setAttribute("type", "file");
        input.setAttribute("name", this._options.name);
        
        qq.css(input, {
            position: 'absolute',
            // in Opera only 'browse' button
            // is clickable and it is located at
            // the right side of the input
            right: 0,
            top: 0,
            fontFamily: 'Arial',
            // 4 persons reported this, the max values that worked for them were 243, 236, 236, 118
            fontSize: '118px',
            margin: 0,
            padding: 0,
            cursor: 'pointer',
            opacity: 0
        });
        
        this._element.appendChild(input);

        var self = this;
        qq.attach(input, 'change', function(){
            self._options.onChange(input);
        });
                
        qq.attach(input, 'mouseover', function(){
            qq.addClass(self._element, self._options.hoverClass);
        });
        qq.attach(input, 'mouseout', function(){
            qq.removeClass(self._element, self._options.hoverClass);
        });
        qq.attach(input, 'focus', function(){
            qq.addClass(self._element, self._options.focusClass);
        });
        qq.attach(input, 'blur', function(){
            qq.removeClass(self._element, self._options.focusClass);
        });

        // IE and Opera, unfortunately have 2 tab stops on file input
        // which is unacceptable in our case, disable keyboard access
        if (window.attachEvent){
            // it is IE or Opera
            input.setAttribute('tabIndex', "-1");
        }

        return input;            
    }        
};

/**
 * Class for uploading files, uploading itself is handled by child classes
 */
qq.UploadHandlerAbstract = function(o){
    this._options = {
        debug: false,
        action: '/upload.php',
        method: 'POST',
        fieldName: 'qqfile',
        // maximum number of concurrent uploads        
        maxConnections: 999,
        onProgress: function(id, fileName, loaded, total){},
        onComplete: function(id, fileName, response){},
        onCancel: function(id, fileName){}
    };
    qq.extend(this._options, o);    
    
    this._queue = [];
    // params for files in queue
    this._params = [];
};
qq.UploadHandlerAbstract.prototype = {
    log: function(str){
        if (this._options.debug && window.console) console.log('[uploader] ' + str);        
    },
    /**
     * Adds file or file input to the queue
     * @returns id
     **/    
    add: function(file){},
    /**
     * Sends the file identified by id and additional query params to the server
     */
    upload: function(id, params){
        var len = this._queue.push(id);

        var copy = {};        
        qq.extend(copy, params);
        this._params[id] = copy;        
                
        // if too many active uploads, wait...
        if (len <= this._options.maxConnections){               
            this._upload(id, this._params[id]);
        }
    },
    /**
     * Cancels file upload by id
     */
    cancel: function(id){
        this._cancel(id);
        this._dequeue(id);
    },
    /**
     * Cancells all uploads
     */
    cancelAll: function(){
        for (var i=0; i<this._queue.length; i++){
            this._cancel(this._queue[i]);
        }
        this._queue = [];
    },
    /**
     * Returns name of the file identified by id
     */
    getName: function(id){},
    /**
     * Returns size of the file identified by id
     */          
    getSize: function(id){},
    /**
     * Returns id of files being uploaded or
     * waiting for their turn
     */
    getQueue: function(){
        return this._queue;
    },
    /**
     * Actual upload method
     */
    _upload: function(id){},
    /**
     * Actual cancel method
     */
    _cancel: function(id){},     
    /**
     * Removes element from queue, starts upload of next
     */
    _dequeue: function(id){
        var i = qq.indexOf(this._queue, id);
        this._queue.splice(i, 1);
                
        var max = this._options.maxConnections;
        
        if (this._queue.length >= max && i < max){
            var nextId = this._queue[max-1];
            this._upload(nextId, this._params[nextId]);
        }
    }        
};

/**
 * Class for uploading files using form and iframe
 * @inherits qq.UploadHandlerAbstract
 */
qq.UploadHandlerForm = function(o){
    qq.UploadHandlerAbstract.apply(this, arguments);
       
    this._inputs = {};
};
// @inherits qq.UploadHandlerAbstract
qq.extend(qq.UploadHandlerForm.prototype, qq.UploadHandlerAbstract.prototype);

qq.extend(qq.UploadHandlerForm.prototype, {
    add: function(fileInput){
        fileInput.setAttribute('name', this._options.fieldName);
        var id = 'qq-upload-handler-iframe' + qq.getUniqueId();       
        
        this._inputs[id] = fileInput;
        
        // remove file input from DOM
        if (fileInput.parentNode){
            qq.remove(fileInput);
        }
                
        return id;
    },
    getName: function(id){
        // get input value and remove path to normalize
        return this._inputs[id].value.replace(/.*(\/|\\)/, "");
    },    
    _cancel: function(id){
        this._options.onCancel(id, this.getName(id));
        
        delete this._inputs[id];        

        var iframe = document.getElementById(id);
        if (iframe){
            // to cancel request set src to something else
            // we use src="javascript:false;" because it doesn't
            // trigger ie6 prompt on https
            iframe.setAttribute('src', 'javascript:false;');

            qq.remove(iframe);
        }
    },     
    _upload: function(id, params){                        
        var input = this._inputs[id];
        
        if (!input){
            throw new Error('file with passed id was not added, or already uploaded or cancelled');
        }                

        var fileName = this.getName(id);
                
        var iframe = this._createIframe(id);
        var form = this._createForm(iframe, params);
        form.appendChild(input);

        var self = this;
        this._attachLoadEvent(iframe, function(){                                 
            self.log('iframe loaded');
            
            var response = self._getIframeContentJSON(iframe);

            self._options.onComplete(id, fileName, response);
            self._dequeue(id);
            
            delete self._inputs[id];
            // timeout added to fix busy state in FF3.6
            setTimeout(function(){
                qq.remove(iframe);
            }, 1);
        });

        form.submit();        
        qq.remove(form);        
        
        return id;
    }, 
    _attachLoadEvent: function(iframe, callback){
        qq.attach(iframe, 'load', function(){
            // when we remove iframe from dom
            // the request stops, but in IE load
            // event fires
            if (!iframe.parentNode){
                return;
            }

            // fixing Opera 10.53
            if (iframe.contentDocument &&
                iframe.contentDocument.body &&
                iframe.contentDocument.body.innerHTML == "false"){
                // In Opera event is fired second time
                // when body.innerHTML changed from false
                // to server response approx. after 1 sec
                // when we upload file with iframe
                return;
            }

            callback();
        });
    },
    /**
     * Returns json object received by iframe from server.
     */
    _getIframeContentJSON: function(iframe){
        // iframe.contentWindow.document - for IE<7
        var doc = iframe.contentDocument ? iframe.contentDocument: iframe.contentWindow.document,
            response;
        
        this.log("converting iframe's innerHTML to JSON");
        this.log("innerHTML = " + doc.body.innerHTML);
                        
        try {
            response = eval("(" + doc.body.innerHTML + ")");
        } catch(err){
            response = {};
        }        

        return response;
    },
    /**
     * Creates iframe with unique name
     */
    _createIframe: function(id){
        // We can't use following code as the name attribute
        // won't be properly registered in IE6, and new window
        // on form submit will open
        // var iframe = document.createElement('iframe');
        // iframe.setAttribute('name', id);

        var iframe = qq.toElement('<iframe src="javascript:false;" name="' + id + '" />');
        // src="javascript:false;" removes ie6 prompt on https

        iframe.setAttribute('id', id);

        iframe.style.display = 'none';
        document.body.appendChild(iframe);

        return iframe;
    },
    /**
     * Creates form, that will be submitted to iframe
     */
    _createForm: function(iframe, params){
        // We can't use the following code in IE6
        // var form = document.createElement('form');
        // form.setAttribute('method', 'post');
        // form.setAttribute('enctype', 'multipart/form-data');
        // Because in this case file won't be attached to request
        var form = qq.toElement('<form enctype="multipart/form-data"></form>');

        var queryString = qq.obj2url(params, this._options.action);
        
        form.setAttribute('method', this._options.method);
        form.setAttribute('action', queryString);
        form.setAttribute('target', iframe.name);
        form.style.display = 'none';

        // Rails CSRFProtection
        var token = $('meta[name="csrf-token"]').attr('content');
        var param = $('meta[name="csrf-param"]').attr('content');
        var input = qq.toElement('<input type="hidden" />');
        
        input.setAttribute('name', param);
        input.setAttribute('value', token);
        
        form.appendChild(input);
        document.body.appendChild(form);

        return form;
    }
});

/**
 * Class for uploading files using xhr
 * @inherits qq.UploadHandlerAbstract
 */
qq.UploadHandlerXhr = function(o){
    qq.UploadHandlerAbstract.apply(this, arguments);

    this._files = [];
    this._xhrs = [];
    
    // current loaded size in bytes for each file 
    this._loaded = [];
};

// static method
qq.UploadHandlerXhr.isSupported = function(){
    var input = document.createElement('input');
    input.type = 'file';        
    
    return (
        'multiple' in input &&
        typeof File != "undefined" &&
        typeof (new XMLHttpRequest()).upload != "undefined" );       
};

// @inherits qq.UploadHandlerAbstract
qq.extend(qq.UploadHandlerXhr.prototype, qq.UploadHandlerAbstract.prototype)

qq.extend(qq.UploadHandlerXhr.prototype, {
    /**
     * Adds file to the queue
     * Returns id to use with upload, cancel
     **/    
    add: function(file){
        if (!(file instanceof File)){
            throw new Error('Passed obj in not a File (in qq.UploadHandlerXhr)');
        }
                
        return this._files.push(file) - 1;        
    },
    getName: function(id){        
        var file = this._files[id];
        // fix missing name in Safari 4
        return file.fileName != null ? file.fileName : file.name;       
    },
    getSize: function(id){
        var file = this._files[id];
        return file.fileSize != null ? file.fileSize : file.size;
    },    
    /**
     * Returns uploaded bytes for file identified by id 
     */    
    getLoaded: function(id){
        return this._loaded[id] || 0; 
    },
    /**
     * Sends the file identified by id and additional query params to the server
     * @param {Object} params name-value string pairs
     */    
    _upload: function(id, params){
        var file = this._files[id],
            name = this.getName(id),
            size = this.getSize(id);
                
        this._loaded[id] = 0;
                                
        var xhr = this._xhrs[id] = new XMLHttpRequest();
        var self = this;
                                        
        xhr.upload.onprogress = function(e){
            if (e.lengthComputable){
                self._loaded[id] = e.loaded;
                self._options.onProgress(id, name, e.loaded, e.total);
            }
        };

        xhr.onreadystatechange = function(){            
            if (xhr.readyState == 4){
                self._onComplete(id, xhr);                    
            }
        };

        // build query string
        params = params || {};
        params[this._options.fieldName] = name;
        var queryString = qq.obj2url(params, this._options.action);

        xhr.open(this._options.method, queryString, true);
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        xhr.setRequestHeader("X-File-Name", encodeURIComponent(name));
        xhr.setRequestHeader('X-File-Size', size);
        xhr.setRequestHeader('X-File-Type', file.type);
        xhr.setRequestHeader("Content-Type", "application/octet-stream");

        // Rails CSRFProtection
        if ($.rails) $.rails.CSRFProtection(xhr);        

        xhr.send(file);
    },
    _onComplete: function(id, xhr){
        // the request was aborted/cancelled
        if (!this._files[id]) return;
        
        var name = this.getName(id);
        var size = this.getSize(id);
        
        this._options.onProgress(id, name, size, size);
                
        if ([200, 201].indexOf( xhr.status ) > -1){
            this.log("xhr - server response received");
            this.log("responseText = " + xhr.responseText);
                        
            var response;
                    
            try {
                response = eval("(" + xhr.responseText + ")");
            } catch(err){
                response = {};
            }
            
            this._options.onComplete(id, name, response);
                        
        } else {                   
            this._options.onComplete(id, name, {});
        }
                
        this._files[id] = null;
        this._xhrs[id] = null;    
        this._dequeue(id);                    
    },
    _cancel: function(id){
        this._options.onCancel(id, this.getName(id));
        
        this._files[id] = null;
        
        if (this._xhrs[id]){
            this._xhrs[id].abort();
            this._xhrs[id] = null;                                   
        }
    }
});
/**
 * Author: Sergey Kukunin
 * See: https://github.com/Kukunin/jquery-endless-scroll
 */

(function($) {
	'use strict';

	// Is pushState supported by this browser?
	$.support.pushState =
		window.history && window.history.pushState && window.history.replaceState &&
		// pushState isn't reliable on iOS until 5.
		!navigator.userAgent.match(/((iPod|iPhone|iPad).+\bOS\s+[1-4]|WebApps\/.+CFNetwork)/)

	//Declaration of modules
	var scrollModule = {
		init: function(options, obj) {
			obj.options = $.extend({
				scrollContainer: window,
				scrollPadding: 100,
				scrollEventDelay: 300
			}, options);
			this.options = obj.options;
			this.container = obj.container;
			obj.scrollModule = this;

			this._toplock = true;
			this._bottomlock = true;

			this.scrollContainer = $(this.options.scrollContainer);

			this.updateEntities();
			this.sortMarkers();

			this.currentPage = null;

			this.container.on("jes:afterPageLoad", $.proxy(function(event, url, placement) {
				this.updateEntities();
				this.sortMarkers();
				this.checkMarker();

				if ( placement == "top" ) {
					//Get offset between first and second pages
					var offset = this.markers[1].top,
						scrollTop = this.scrollContainer.scrollTop();

					this.scrollContainer.scrollTop(scrollTop + offset);
				}
			}, this));

			this.bind();
		},
		updateEntities: function() {
			this.entities = $(this.options.entity, this.container);
		},
		sortMarkers: function() {
			var markers = [];
			$(".jes-marker", this.container).each(function() {
				markers.push({ top: $(this).position().top, url: $(this).data("jesUrl") });
			});
			this.markers = markers;
		},
		//Check, whether user scrolled to another page
		checkMarker: function() {
			var newPage = this.markers[0],
				scrollTop = this.scrollContainer.scrollTop();

			//Determine, what is current page
			for ( var i = 1; i < this.markers.length; i++ ) {
				if ( scrollTop > this.markers[i].top ) {
					newPage = this.markers[i];
				} else {
					break;
				}
			}
			if ( newPage.url != this.currentPage ) {
				this.currentPage = newPage.url;
				$(this.container).trigger("jes:scrollToPage", newPage.url);
			}
		},
		bind: function() {
			this.scrollContainer.on("scroll.jes", $.proxy(function(event) {
				if ( this._tId ) { return; }

				this.scrollHandler(event);
				//Clean up mark
				this._tId= setTimeout($.proxy(function(){
					this._tId = null;
				},this), this.options.scrollEventDelay);

			}, this));
		},
		unbind: function() {
			$(this.options.scrollContainer).off("scroll.jes");
		},
		scrollHandler: function(ev) {
			var $scrollable = this.scrollContainer,
				$entities = this.entities,
				$firstEntity = $entities.first(),
				$lastEntity = $entities.last();

			var scrollTop = $scrollable.scrollTop(),
				height = $scrollable.height(),
				scrollBottom = scrollTop + height;

			var topEntityPosition = $firstEntity.position().top,
				topTarget = topEntityPosition + this.options.scrollPadding,
				bottomEntityPosition = $lastEntity.outerHeight() + $lastEntity.position().top,
				bottomTarget = bottomEntityPosition - this.options.scrollPadding;

			//Don't trigger event again, if already fired
			//Visitor have to leave the area and get back to fire event again
			//Process top threshold
			if ( scrollTop < topTarget ) {
				if ( !this._toplock ) {
					$(this.container).trigger("jes:topThreshold");
					this._toplock = true;
				}
			} else {
				this._toplock = false;
			}

			//Process bottom threshold
			if ( scrollBottom > bottomTarget ) {
				if ( !this._bottomlock ) {
					$(this.container).trigger("jes:bottomThreshold");
					this._bottomlock = true;
				}
			} else {
				this._bottomlock = false;
			}

			this.checkMarker();
		}
	}

	var ajaxModule = {
		init: function(options, obj) {
			obj.options = $.extend({
			}, options);

			this.options = obj.options;
			this.container = obj.container;

			//markers
			this.setMarker($(this.options.entity, this.container).first(), location.href);

			obj.ajaxModule = this;
		},
		loadPage: function(url, placement, callback) {
			//The hash with methods list
			//depends from placement
			var actions = {
					top: {
						find: 'first',
						inject: 'insertBefore'
					},
					bottom: {
						find: 'last',
						inject: 'insertAfter'
					}
				},
				action = actions[placement];

			this.container.trigger("jes:beforePageLoad", [url, placement]);

			//Make AJAX query
			$.get(url, null, $.proxy(function (_data) {
				var data = $("<div>").html(_data),
				containerSelector = this.options.container,
				container = $(containerSelector, data).first();

				if ( container.length ) {
					//Find entities
					var entities = container.find(this.options.entity);

					if ( placement == "bottom" ) {
						//Remove duplicated (staled) entities from page
						entities.each(function(i) {
							var id = $(this).attr("id");
							if ( id ) {
								$('#' + id, this.container).remove();
							}
						});
					}

					//Find the cursor
					var cursor = $(this.options.entity, containerSelector)[action.find]();

					//Find and insert entities
					entities[action.inject](cursor);
					this.setMarker(entities.first(), url);
				}

				if ( $.isFunction(callback) ) {
					callback(data);
				}
				this.container.trigger("jes:afterPageLoad", [url, placement, data, entities]);
			}, this), 'html');
		},
		setMarker: function(entity, url) {
			entity.addClass("jes-marker").data("jesUrl", url);
		}
	}

	var navigationModule = {
		init: function(options, obj) {
			obj.options = $.extend({
				nextPage: ".pagination a[rel=next]",
				previousPage: ".pagination a[rel=previous]"
			}, options);

			this.options = obj.options;
			this.container = obj.container;

			$.each([{
				selector: this.options.nextPage,
				event: "jes:bottomThreshold.navigation",
				placement: 'bottom'
			}, {
				selector: this.options.previousPage,
				event: "jes:topThreshold.navigation",
				placement: 'top'
			}], $.proxy(function(i, v) {
				v.element = $(v.selector);
				if ( v.element.length ) {
					var url = v.element.prop("href"),
					lock = false;

					var handler = function() {
						//this object is container
						if ( lock || !url ) return;

						lock = true;
						obj.ajaxModule.loadPage(url, v.placement, $.proxy(function( data ) {
							//Search new next link
							var newElement = $(v.selector, $(data));
							if ( newElement.length ) {
								//Update URL and remove lock
								lock = false;
								url = newElement.prop("href");
								v.element.attr("href", url);
							} else {
								//Remove event at all
								$(this).off(v.event);
								v.element.remove();
							}
						}, this));
					};

					$(this.container).on(v.event, handler);
					$(v.element).on("click", $.proxy(function(ev) {
						ev.preventDefault();
						handler.apply(this.container)
					}, this));
				}
			},this));
		}
	}

	var pushStateHistory = {
		init: function(options, obj) {
			if ( !$.support.pushState ) {
				return;
			}

			obj.container.on("jes:scrollToPage", function(event, url) {
				history.replaceState({}, null, url);
			});
		}
	}

	$.endlessScroll = function(options) {

		//Initialize modules
		this.options = $.extend(true, {
			container: "#container",
			entity: ".entity",
			_modules: [ ajaxModule, scrollModule, navigationModule, pushStateHistory ],
			modules: []
		}, options);

		this.container = $(this.options.container);
		if ( !this.container.length ) {
			throw "Container for endless scroll isn't available on the page";
			return;
		}


		//Merge custom options with default
		$.merge(this.options.modules, this.options._modules);
		//Init modules
		this.options.modules.forEach($.proxy(function(module) {
			module.init(this.options, this);
		},this));


		return this;
	}

})(jQuery);
(function($, undefined) {

/**
 * Unobtrusive scripting adapter for jQuery
 *
 * Requires jQuery 1.6.0 or later.
 * https://github.com/rails/jquery-ujs

 * Uploading file using rails.js
 * =============================
 *
 * By default, browsers do not allow files to be uploaded via AJAX. As a result, if there are any non-blank file fields
 * in the remote form, this adapter aborts the AJAX submission and allows the form to submit through standard means.
 *
 * The `ajax:aborted:file` event allows you to bind your own handler to process the form submission however you wish.
 *
 * Ex:
 *     $('form').live('ajax:aborted:file', function(event, elements){
 *       // Implement own remote file-transfer handler here for non-blank file inputs passed in `elements`.
 *       // Returning false in this handler tells rails.js to disallow standard form submission
 *       return false;
 *     });
 *
 * The `ajax:aborted:file` event is fired when a file-type input is detected with a non-blank value.
 *
 * Third-party tools can use this hook to detect when an AJAX file upload is attempted, and then use
 * techniques like the iframe method to upload the file instead.
 *
 * Required fields in rails.js
 * ===========================
 *
 * If any blank required inputs (required="required") are detected in the remote form, the whole form submission
 * is canceled. Note that this is unlike file inputs, which still allow standard (non-AJAX) form submission.
 *
 * The `ajax:aborted:required` event allows you to bind your own handler to inform the user of blank required inputs.
 *
 * !! Note that Opera does not fire the form's submit event if there are blank required inputs, so this event may never
 *    get fired in Opera. This event is what causes other browsers to exhibit the same submit-aborting behavior.
 *
 * Ex:
 *     $('form').live('ajax:aborted:required', function(event, elements){
 *       // Returning false in this handler tells rails.js to submit the form anyway.
 *       // The blank required inputs are passed to this function in `elements`.
 *       return ! confirm("Would you like to submit the form with missing info?");
 *     });
 */

  // Shorthand to make it a little easier to call public rails functions from within rails.js
  var rails;

  $.rails = rails = {
    // Link elements bound by jquery-ujs
    linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote], a[data-disable-with]',

    // Select elements bound by jquery-ujs
    inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',

    // Form elements bound by jquery-ujs
    formSubmitSelector: 'form',

    // Form input elements bound by jquery-ujs
    formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not(button[type])',

    // Form input elements disabled during form submission
    disableSelector: 'input[data-disable-with], button[data-disable-with], textarea[data-disable-with]',

    // Form input elements re-enabled after form submission
    enableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled',

    // Form required input elements
    requiredInputSelector: 'input[name][required]:not([disabled]),textarea[name][required]:not([disabled])',

    // Form file input elements
    fileInputSelector: 'input:file',

    // Link onClick disable selector with possible reenable after remote submission
    linkDisableSelector: 'a[data-disable-with]',

    // Make sure that every Ajax request sends the CSRF token
    CSRFProtection: function(xhr) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    },

    // Triggers an event on an element and returns false if the event result is false
    fire: function(obj, name, data) {
      var event = $.Event(name);
      obj.trigger(event, data);
      return event.result !== false;
    },

    // Default confirm dialog, may be overridden with custom confirm dialog in $.rails.confirm
    confirm: function(message) {
      return confirm(message);
    },

    // Default ajax function, may be overridden with custom function in $.rails.ajax
    ajax: function(options) {
      return $.ajax(options);
    },

    // Submits "remote" forms and links with ajax
    handleRemote: function(element) {
      var method, url, data,
        crossDomain = element.data('cross-domain') || null,
        dataType = element.data('type') || ($.ajaxSettings && $.ajaxSettings.dataType),
        options;

      if (rails.fire(element, 'ajax:before')) {

        if (element.is('form')) {
          method = element.attr('method');
          url = element.attr('action');
          data = element.serializeArray();
          // memoized value from clicked submit button
          var button = element.data('ujs:submit-button');
          if (button) {
            data.push(button);
            element.data('ujs:submit-button', null);
          }
        } else if (element.is(rails.inputChangeSelector)) {
          method = element.data('method');
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else {
          method = element.data('method');
          url = element.attr('href');
          data = element.data('params') || null;
        }

        options = {
          type: method || 'GET', data: data, dataType: dataType, crossDomain: crossDomain,
          // stopping the "ajax:beforeSend" event will cancel the ajax request
          beforeSend: function(xhr, settings) {
            if (settings.dataType === undefined) {
              xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
            return rails.fire(element, 'ajax:beforeSend', [xhr, settings]);
          },
          success: function(data, status, xhr) {
            element.trigger('ajax:success', [data, status, xhr]);
          },
          complete: function(xhr, status) {
            element.trigger('ajax:complete', [xhr, status]);
          },
          error: function(xhr, status, error) {
            element.trigger('ajax:error', [xhr, status, error]);
          }
        };
        // Only pass url to `ajax` options if not blank
        if (url) { options.url = url; }

        return rails.ajax(options);
      } else {
        return false;
      }
    },

    // Handles "data-method" on links such as:
    // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
    handleMethod: function(link) {
      var href = link.attr('href'),
        method = link.data('method'),
        target = link.attr('target'),
        csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content'),
        form = $('<form method="post" action="' + href + '"></form>'),
        metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

      if (csrf_param !== undefined && csrf_token !== undefined) {
        metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
      }

      if (target) { form.attr('target', target); }

      form.hide().append(metadata_input).appendTo('body');
      form.submit();
    },

    /* Disables form elements:
      - Caches element value in 'ujs:enable-with' data store
      - Replaces element text with value of 'data-disable-with' attribute
      - Sets disabled property to true
    */
    disableFormElements: function(form) {
      form.find(rails.disableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        element.data('ujs:enable-with', element[method]());
        element[method](element.data('disable-with'));
        element.prop('disabled', true);
      });
    },

    /* Re-enables disabled form elements:
      - Replaces element text with cached value from 'ujs:enable-with' data store (created in `disableFormElements`)
      - Sets disabled property to false
    */
    enableFormElements: function(form) {
      form.find(rails.enableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        if (element.data('ujs:enable-with')) element[method](element.data('ujs:enable-with'));
        element.prop('disabled', false);
      });
    },

   /* For 'data-confirm' attribute:
      - Fires `confirm` event
      - Shows the confirmation dialog
      - Fires the `confirm:complete` event

      Returns `true` if no function stops the chain and user chose yes; `false` otherwise.
      Attaching a handler to the element's `confirm` event that returns a `falsy` value cancels the confirmation dialog.
      Attaching a handler to the element's `confirm:complete` event that returns a `falsy` value makes this function
      return false. The `confirm:complete` event is fired whether or not the user answered true or false to the dialog.
   */
    allowAction: function(element) {
      var message = element.data('confirm'),
          answer = false, callback;
      if (!message) { return true; }

      if (rails.fire(element, 'confirm')) {
        answer = rails.confirm(message);
        callback = rails.fire(element, 'confirm:complete', [answer]);
      }
      return answer && callback;
    },

    // Helper function which checks for blank inputs in a form that match the specified CSS selector
    blankInputs: function(form, specifiedSelector, nonBlank) {
      var inputs = $(), input,
        selector = specifiedSelector || 'input,textarea';
      form.find(selector).each(function() {
        input = $(this);
        // Collect non-blank inputs if nonBlank option is true, otherwise, collect blank inputs
        if (nonBlank ? input.val() : !input.val()) {
          inputs = inputs.add(input);
        }
      });
      return inputs.length ? inputs : false;
    },

    // Helper function which checks for non-blank inputs in a form that match the specified CSS selector
    nonBlankInputs: function(form, specifiedSelector) {
      return rails.blankInputs(form, specifiedSelector, true); // true specifies nonBlank
    },

    // Helper function, needed to provide consistent behavior in IE
    stopEverything: function(e) {
      $(e.target).trigger('ujs:everythingStopped');
      e.stopImmediatePropagation();
      return false;
    },

    // find all the submit events directly bound to the form and
    // manually invoke them. If anyone returns false then stop the loop
    callFormSubmitBindings: function(form, event) {
      var events = form.data('events'), continuePropagation = true;
      if (events !== undefined && events['submit'] !== undefined) {
        $.each(events['submit'], function(i, obj){
          if (typeof obj.handler === 'function') return continuePropagation = obj.handler(event);
        });
      }
      return continuePropagation;
    },

    //  replace element's html with the 'data-disable-with' after storing original html
    //  and prevent clicking on it
    disableElement: function(element) {
      element.data('ujs:enable-with', element.html()); // store enabled state
      element.html(element.data('disable-with')); // set to disabled state
      element.bind('click.railsDisable', function(e) { // prevent further clicking
        return rails.stopEverything(e)
      });
    },

    // restore element to its original state which was disabled by 'disableElement' above
    enableElement: function(element) {
      if (element.data('ujs:enable-with') !== undefined) {
        element.html(element.data('ujs:enable-with')); // set to old enabled state
        // this should be element.removeData('ujs:enable-with')
        // but, there is currently a bug in jquery which makes hyphenated data attributes not get removed
        element.data('ujs:enable-with', false); // clean up cache
      }
      element.unbind('click.railsDisable'); // enable element
    }

  };

  $.ajaxPrefilter(function(options, originalOptions, xhr){ if ( !options.crossDomain ) { rails.CSRFProtection(xhr); }});

  $(document).delegate(rails.linkDisableSelector, 'ajax:complete', function() {
      rails.enableElement($(this));
  });

  $(document).delegate(rails.linkClickSelector, 'click.rails', function(e) {
    var link = $(this), method = link.data('method'), data = link.data('params');
    if (!rails.allowAction(link)) return rails.stopEverything(e);

    if (link.is(rails.linkDisableSelector)) rails.disableElement(link);

    if (link.data('remote') !== undefined) {
      if ( (e.metaKey || e.ctrlKey) && (!method || method === 'GET') && !data ) { return true; }

      if (rails.handleRemote(link) === false) { rails.enableElement(link); }
      return false;

    } else if (link.data('method')) {
      rails.handleMethod(link);
      return false;
    }
  });

  $(document).delegate(rails.inputChangeSelector, 'change.rails', function(e) {
    var link = $(this);
    if (!rails.allowAction(link)) return rails.stopEverything(e);

    rails.handleRemote(link);
    return false;
  });

  $(document).delegate(rails.formSubmitSelector, 'submit.rails', function(e) {
    var form = $(this),
      remote = form.data('remote') !== undefined,
      blankRequiredInputs = rails.blankInputs(form, rails.requiredInputSelector),
      nonBlankFileInputs = rails.nonBlankInputs(form, rails.fileInputSelector);

    if (!rails.allowAction(form)) return rails.stopEverything(e);

    // skip other logic when required values are missing or file upload is present
    if (blankRequiredInputs && form.attr("novalidate") == undefined && rails.fire(form, 'ajax:aborted:required', [blankRequiredInputs])) {
      return rails.stopEverything(e);
    }

    if (remote) {
      if (nonBlankFileInputs) {
        return rails.fire(form, 'ajax:aborted:file', [nonBlankFileInputs]);
      }

      // If browser does not support submit bubbling, then this live-binding will be called before direct
      // bindings. Therefore, we should directly call any direct bindings before remotely submitting form.
      if (!$.support.submitBubbles && $().jquery < '1.7' && rails.callFormSubmitBindings(form, e) === false) return rails.stopEverything(e);

      rails.handleRemote(form);
      return false;

    } else {
      // slight timeout so that the submit button gets properly serialized
      setTimeout(function(){ rails.disableFormElements(form); }, 13);
    }
  });

  $(document).delegate(rails.formInputClickSelector, 'click.rails', function(event) {
    var button = $(this);

    if (!rails.allowAction(button)) return rails.stopEverything(event);

    // register the pressed submit button
    var name = button.attr('name'),
      data = name ? {name:name, value:button.val()} : null;

    button.closest('form').data('ujs:submit-button', data);
  });

  $(document).delegate(rails.formSubmitSelector, 'ajax:beforeSend.rails', function(event) {
    if (this == event.target) rails.disableFormElements($(this));
  });

  $(document).delegate(rails.formSubmitSelector, 'ajax:complete.rails', function(event) {
    if (this == event.target) rails.enableFormElements($(this));
  });

})( jQuery );
$.QueryString = (function(a) {
  if (a == "") return {};
  var b = {};
  for (var i = 0; i < a.length; ++i)
  {
    var p=a[i].split('=');
    if (p.length != 2) continue;
    b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
  }
  return b;
})(window.location.search.substr(1).split('&'))

$(document).ready(function(){
  var selector = "div.gal-item div.gal-inner-holder";

  $(document)
    .on('mouseover', selector, function(e){
      $(this).addClass('hover');
    })
    .on('mouseout', selector, function(e){
      $(this).removeClass('hover');
    })
    .on('click', selector, function(e){
      var url = $(this).parents('div.gal-item').data('url');
      CKEDITOR.tools.callFunction(CKEditorFuncNum, url);
      window.close();
    });

  $(document).on('ajax:complete', "div.gal-item a.gal-del", function(xhr, status){
    $(this).parents('div.gal-item').remove();
  });

  var endlessScroll = $.endlessScroll({
    container: ".fileupload-list",
    entity: ".gal-item",
    scrollPadding: 100
  });

  // Don't listen events first second
  endlessScroll.scrollModule.unbind();
  window.setTimeout(function() { endlessScroll.scrollModule.bind();}, 1000);
});

// Collection of all instances on page
qq.FileUploader.instances = new Object();

/**
 * Class that creates upload widget with drag-and-drop and file list
 * @inherits qq.FileUploaderBasic
 */
qq.FileUploaderInput = function(o){
    // call parent constructor
    qq.FileUploaderBasic.apply(this, arguments);

    // additional options
    qq.extend(this._options, {
        element: null,
        // if set, will be used instead of qq-upload-list in template
        listElement: null,

        template_id: '#fileupload_tmpl',

        classes: {
            // used to get elements from templates
            button: 'fileupload-button',
            drop: 'fileupload-drop-area',
            dropActive: 'fileupload-drop-area-active',
            list: 'fileupload-list',
            preview: 'fileupload-preview',

            file: 'fileupload-file',
            spinner: 'fileupload-spinner',
            size: 'fileupload-size',
            cancel: 'fileupload-cancel',

            // added to list item when upload completes
            // used in css to hide progress spinner
            success: 'fileupload-success',
            fail: 'fileupload-fail'
        }
    });
    // overwrite options with user supplied
    qq.extend(this._options, o);

    this._element = document.getElementById(this._options.element);
    this._listElement = this._options.listElement || this._find(this._element, 'list');

    this._classes = this._options.classes;

    this._button = this._createUploadButton(this._find(this._element, 'button'));

    //this._setupDragDrop();

    qq.FileUploader.instances[this._element.id] = this;
};

// inherit from Basic Uploader
qq.extend(qq.FileUploaderInput.prototype, qq.FileUploaderBasic.prototype);

qq.extend(qq.FileUploaderInput.prototype, {
    /**
     * Gets one of the elements listed in this._options.classes
     **/
    _find: function(parent, type){
        var element = qq.getByClass(parent, this._options.classes[type])[0];
        if (!element){
          alert(type);
            throw new Error('element not found ' + type);
        }

        return element;
    },
    _setupDragDrop: function(){
        var self = this,
            dropArea = this._find(this._element, 'drop');

        var dz = new qq.UploadDropZone({
            element: dropArea,
            onEnter: function(e){
                qq.addClass(dropArea, self._classes.dropActive);
                e.stopPropagation();
            },
            onLeave: function(e){
                e.stopPropagation();
            },
            onLeaveNotDescendants: function(e){
                qq.removeClass(dropArea, self._classes.dropActive);
            },
            onDrop: function(e){
                dropArea.style.display = 'none';
                qq.removeClass(dropArea, self._classes.dropActive);
                self._uploadFileList(e.dataTransfer.files);
            }
        });

        dropArea.style.display = 'none';

        qq.attach(document, 'dragenter', function(e){
            if (!dz._isValidFileDrag(e)) return;

            dropArea.style.display = 'block';
        });
        qq.attach(document, 'dragleave', function(e){
            if (!dz._isValidFileDrag(e)) return;

            var relatedTarget = document.elementFromPoint(e.clientX, e.clientY);
            // only fire when leaving document out
            if ( ! relatedTarget || relatedTarget.nodeName == "HTML"){
                dropArea.style.display = 'none';
            }
        });
    },
    _onSubmit: function(id, fileName){
        qq.FileUploaderBasic.prototype._onSubmit.apply(this, arguments);
        this._addToList(id, fileName);
    },
    _onProgress: function(id, fileName, loaded, total){
        qq.FileUploaderBasic.prototype._onProgress.apply(this, arguments);

        var item = this._getItemByFileId(id);
        var size = this._find(item, 'size');

        var text;
        if (loaded != total){
            text = Math.round(loaded / total * 100) + '% from ' + this._formatSize(total);
        } else {
            text = this._formatSize(total);
        }

        qq.setText(size, text);
    },
    _onComplete: function(id, fileName, result){
        qq.FileUploaderBasic.prototype._onComplete.apply(this, arguments);

        var item = this._getItemByFileId(id);
        var asset = result.asset ? result.asset : result;

        if (asset && asset.id){
            qq.addClass(item, this._classes.success);

            asset.size = this._formatSize(asset.size);
            asset.controller = (asset.type !== undefined && asset.type.toLowerCase() == "ckeditor::picture" ? "pictures" : "attachment_files");

            $(item).replaceWith($(this._options.template_id).tmpl(asset));
        } else {
            qq.addClass(item, this._classes.fail);
        }
    },
    _addToList: function(id, fileName){
        if (this._listElement) {
          if (this._options.multiple === false) {
            $(this._listElement).empty();
          }

          var asset = {
            id: 0,
            filename: this._formatFileName(fileName),
            size: 0,
            format_created_at: '',
            url_content: "#",
            controller: "assets",
            url_thumb: ""
          };

          var item = $(this._options.template_id).tmpl(asset).attr('qqfileid', id)

          item.find('div.img').html('').addClass('preloader');
          item.prependTo( this._listElement );

          this._bindCancelEvent(item);
        }
    },
    _getItemByFileId: function(id){
        return $(this._listElement).find('div[qqfileid=' + id  +']').get(0);
    },
    /**
     * delegate click event for cancel link
     **/
    _bindCancelEvent: function(element){
        var self = this,
            item = $(element);

        item.find('a.' + this._classes.cancel).bind('click', function(e){
          self._handler.cancel( item.attr('qqfileid') );
          item.remove();
          qq.preventDefault(e);
          return false;
        });
    }
});





