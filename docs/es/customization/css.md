# Estilos con CSS

Si quieres cambiar algun selector CSS (de las hojas de estilo) puedes hacerlo en el fichero `app/assets/stylesheets/custom.scss`. Por ejemplo si quieres cambiar el color del header (`.top-links`) puedes hacerlo agregando:

```css
.top-links {
  background: red;
}
```

Si quieres cambiar alguna variable de [foundation](http://foundation.zurb.com/) puedes hacerlo en el fichero `app/assets/stylesheets/_custom_settings.scss`. Por ejemplo para cambiar el color general de la aplicación puedes hacerlo agregando:

```css
$brand:             #446336;
```

Usamos un preprocesador de CSS, [SASS, con la sintaxis SCSS](http://sass-lang.com/guide).

Además puedes comprobar la sintaxis de tus ficheros scss con:

```bash
scss-lint
```

## Accesibilidad

Para mantener el nivel de accesibilidad, si añades colores nuevos utiliza un [Comprobador de contraste de color](http://webaim.org/resources/contrastchecker/) (WCAG AA es obligatorio, WCAG AAA es recomendable)
