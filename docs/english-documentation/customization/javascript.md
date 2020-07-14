# Javascript

If you want to add some custom Javascript code, `app/assets/javascripts/custom.js` is the file to do it. For example to create a new alert just add:

```javascript
$(function(){
  alert('foobar');
});
```

If you work with Coffeescript code you can check it with [coffeelint](http://www.coffeelint.org/) \(install with `npm install -g coffeelint`\) :

```bash
coffeelint .
```

