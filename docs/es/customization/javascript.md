# Personalización de JavaScript

Para añadir código de JavaScript personalizado, crea un fichero en `app/assets/javascripts/custom/`.

## Añadir nuevas funciones

Para crear una nueva función, necesitas definirla y hacer que se llame cuando el navegador carga una página.

Por ejemplo, para crear una alerta, podemos crear el fichero `app/assets/javascripts/custom/alert.js` con el siguiente contenido:

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

A continuación, edita la función `initialize_modules` del fichero `app/assets/javascripts/custom.js`:

```js
var initialize_modules = function() {
  "use strict";

  // Add calls to your custom code here; this will be called when
  // loading a page

  App.Alert.initialize();
};
```

## Sobrescribir funciones existentes

En Consul Democracy, las funciones de JavaScript se definen como propiedades de un objeto. Esto quiere decir que, para sobrescribir una función, basta con redefinir la propiedad del objeto que la contiene. Siempre que sea posible, recomendamos que tu código personalizado llame al código original y solamente modifique los casos en que debería comportarse de forma diferente. De este modo, al actualizar a una versión de Consul Democracy que actualice las funciones originales, tus funciones personalizadas incluirán las modificaciones del código original automáticamente. En ocasiones, hacer esto no será posible, con lo que tendrás que cambiar tu función personalizada al actualizar.

Como ejemplo, vamos a cambiar la función `generatePassword` del fichero `app/assets/javascripts/managers.js`. Para ello, crea el fichero `app/assets/javascripts/custom/managers.js` con el siguiente contenido:

```js
(function() {
  "use strict";
  App.Managers.consulGeneratePassword = App.Managers.generatePassword;

  App.Managers.generatePassword = function() {
    return App.Managers.consulGeneratePassword() + "custom";
  };
}).call(this);
```

Esto devolverá lo que devuelve la función original seguida del texto "custom".
