# Personalización de imágenes

Si quieres sobrescribir alguna imagen, primero debes fijarte en el nombre que tiene. Por defecto, se encuentran en `app/assets/images/`. Por ejemplo, si quieres modificar el logo de la cabecera (`app/assets/images/logo_header.png`), crea otro archivo con ese mismo nombre en el directorio `app/assets/images/custom/`. Ten en cuenta que, debido a restricciones en la forma en que Ruby on Rails carga imágenes, **tendrás que renombrar el archivo original**. En el ejemplo, renombra `app/assets/images/logo_header.png` a (por ejemplo) `app/assets/images/original_logo_header.png` y a continuación crea tu imagen personalizada en `app/assets/images/custom/logo_header.png`.

Las imágenes e iconos que seguramente quieras modificar son:

* apple-touch-icon-200.png
* icon_home.png
* logo_email.png
* logo_header.png
* map.jpg
* social_media_icon.png
* social_media_icon_twitter.png

Ten en cuenta que, en vez de personalizar estas imágenes utilizando el método explicado anteriormente, muchas de estas imágenes pueden personalizarse desde el área de administración, en la sección "Contenido del sitio, personalizar imágenes".

## Mapa de la ciudad

Puedes encontrar el mapa de la ciudad en `/app/assets/images/map.jpg` y reemplazarlo con una imagen de los distritos de tu ciudad, como esta [imagen de ejemplo de mapa](https://github.com/consuldemocracy/consuldemocracy/blob/master/app/assets/images/map.jpg).

Después te recomendamos utilizar una herramienta como <http://imagemap-generator.dariodomi.de/> o <https://www.image-map.net/> para generar las coordenadas para poder establecer un [image-map](https://www.w3schools.com/tags/tag_map.asp) sobre cada distrito. Estas coordenadas deben ser introducidas en la respectiva geozona creada en el panel de administración (`/admin/geozones`).
