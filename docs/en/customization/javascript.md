# Customizing JavaScript

In order to add custom JavaScript code, you can create a file under `app/assets/javascripts/custom/`.

## Adding new functions

To create a new function, we need to define it and then call it when the browser loads a page.

For example, in order to create an alert, we can create the file `app/assets/javascripts/custom/alert.js` with the following content:

```js
(function() {
  "use strict";
  App.Alert = {
    initialize: function() {
      alert("foobar");
    }
  };
}).call(this);
```

Then, edit the `initialize_modules` function in `app/assets/javascripts/custom.js`:

```js
var initialize_modules = function() {
  "use strict";

  // Add calls to your custom code here; this will be called when
  // loading a page

  App.Alert.initialize();
};
```

## Overwriting existing functions

In Consul Democracy, functions are defined as object properties. That means that, in order to overwrite a function, you can simply redefine the property of the object containing it. Where possible, it's recommended that your custom code calls the original code and only modifies the cases where it should behave differently. This way, when upgrading to a new version of Consul Democracy that updates the original functions, your custom functions will automatically include the modifications in the original code as well. Sometimes this won't be possible, though, which means you might need to change your custom function when upgrading.

For example, let's change the `generatePassword` function in `app/assets/javascripts/managers.js`. To do so, create a file `app/assets/javascripts/custom/managers.js` with the following content:

```js
(function() {
  "use strict";
  App.Managers.consulGeneratePassword = App.Managers.generatePassword;

  App.Managers.generatePassword = function() {
    return App.Managers.consulGeneratePassword() + "custom";
  };
}).call(this);
```

This will return what the original function returns followed by the "custom" string.
