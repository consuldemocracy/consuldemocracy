# Personalización de estilos con CSS

Consul Democracy usa hojas de estilo escritas utilizando [Sass](http://sass-lang.com/guide) con la sintaxis SCSS y ubicadas en el directorio `app/assets/stylesheets/`.

Para cambiar estilos, puedes añadirlos directamente en algún fichero bajo `app/assets/stylesheets/custom/`. Como alternativa, puedes usar el fichero `app/assets/stylesheets/custom.scss`.

Por ejemplo, para cambiar el margen del pie de página, crear el archivo `app/assets/stylesheets/custom/layout.scss` con el siguiente contenido:

```scss
.footer {
  margin-top: $line-height;
}
```

Esto sobrescribirá la propiedad `margin-top` del selector `.footer`.

Las reglas de precedencia de CSS siguen aplicándose en ese caso, con lo que si hay una regla definiendo la propiedad `margin-top` para el selector `body .footer`, el código anterior será ignorado. Por lo tanto, para sobrescribir propiedades de ciertos elementos de forma adecuada, usa exactamente el mismo selector utilizado en el código original.

## Variables de Sass

Consul Democracy utiliza variables y funciones definidas en el [framework Foundation](http://foundation.zurb.com/) y añade algunas variables más. Para sobrescribir estas variables, usa el archivo `app/assets/stylesheets/_consul_custom_overrides.scss`. Por ejemplo, para cambiar el color de fondo del pie de página, añade:

```scss
$footer: #fdfdfd;
```

Las variables que puedes sobrescribir están definidas en los ficheros `_settings.scss` y `_consul_settings.scss`.

Para definir nuevas variables, puedes usar el fichero `app/assets/stylesheets/_custom_settings.scss`.

## Variables de CSS

En aplicaciones multientidad, las variables de Sass tienen una limitación: su valor será el mismo para todas las entidades.

Debido a esto, para los colores más frecuentemente personalizados, Consul Democracy proporciona variables de CSS, con las que puedes definir diferentes colores para diferentes entidades.

Por ejemplo, puedes personalizar los colores de los principales elementos de la aplicación así como de enlaces y botones con:

```scss
.tenant-public {
  --anchor-color: #372;
  --anchor-color-hover: #137;
  --brand: #153;
  --brand-secondary: #134a00;
  --button-background-hover: #fa0;
  --button-background-hover-contrast: #{$black};
  --footer: #e6e6e6;
  --main-header: #351;
  --top-links: var(--main-header);
  --subnavigation: #ffd;
}
```

Echa un vistazo al archivo `app/assets/stylesheets/custom/tenants.scss` para más información.

## Accesibilidad

Para mantener el nivel de accesibilidad, si añades colores nuevos, utiliza un [comprobador de contraste de color](http://webaim.org/resources/contrastchecker/) (WCAG AA es obligatorio, WCAG AAA es recomendable).
