# Personalización de vistas y HTML

Al igual que la mayoría de aplicaciones hechas con Ruby on Rails, Consul Democracy utiliza ficheros ERB para generar HTML. Estos ficheros tradicionalmente se encuentran en el directorio `app/views/`.

A diferencia del [código de Ruby](models.md), [código de CSS](css.md) o [código de JavaScript](javascript.md), no es posible sobrescribir solamente partes de un fichero ERB. Así que, para personalizar una vista, tendrás que encontrar el archivo que quieras cambiar en el directorio `app/views/` y copiarlo en `app/views/custom/`, manteniendo la estructura de subdirectorios, y posteriormente aplicar las personalizaciones. Por ejemplo, si quieres personalizar `app/views/welcome/index.html.erb`, tendrás que copiarlo en `app/views/custom/welcome/index.html.erb`.

Para que sea más fácil llevar la cuenta de tus cambios personalizados, al utilizar el sistema de control de versiones git, recomendamos copiar el archivo original al directorio personalizado en un "commit" (sin modificar este fichero) y modificar el archivo personalizado en otro "commit" distinto. Esto hará que, al actualizar a una nueva versión de Consul Democracy, sea más fácil comprobar las diferencias entre la vista de la versión anterior de Consul Democracy, la vista de la nueva versión de Consul Democracy, y tus cambios personalizados.

Como se ha mencionado anteriormente, el archivo personalizado sobrescribirá el original completamente. Esto quiere decir que, al actualizar a una nueva versión de Consul Democracy, los cambios en el archivo original serán ignorados. Tendrás que comprobar los cambios en el archivo original y aplicarlos a tu fichero personalizado cuando corresponda.

**Nota**: Consul Democracy solamente utiliza el directorio `app/views/` para código escrito antes del año 2021. El código escrito desde entonces se encuentra en el directorio `app/components/`. La razón principal es que los componentes permiten extraer parte de la lógica en un archivo de Ruby, y mantener código Ruby personalizado es más sencillo que mantener código ERB personalizado.
