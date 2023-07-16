# Imágenes

Si quieres sobreescribir alguna imagen debes primero fijarte el nombre que tiene, por defecto se encuentran en `app/assets/images`. Por ejemplo si quieres modificar `app/assets/images/logo_header.png` debes poner otra con ese mismo nombre en el directorio `app/assets/images/custom`. Los iconos que seguramente quieras modificar son:

* apple-touch-icon-200.png
* icon_home.png
* logo_email.png
* logo_header.png
* map.jpg
* social_media_icon.png
* social_media_icon_twitter.png

## Mapa de la ciudad

Puedes encontrar el mapa de la ciudad en [`/app/assets/images/map.jpg`](https://github.com/consuldemocracy/consuldemocracy/blob/master/app/assets/images/map.jpg), simplemente reemplazalo con una imagen de los distritos de tu ciudad ([ejemplo](https://github.com/consuldemocracy/consuldemocracy/blob/master/app/assets/images/map.jpg)).

Después te recomendamos utilizar una herramienta online como <http://imagemap-generator.dariodomi.de/> o <https://www.image-map.net/> para generar las coordenadas para poder establecer un [image-map](https://www.w3schools.com/tags/tag_map.asp) sobre cada distrito. Estas coordenadas deben ser introducidas en la respectiva Geozona creada en el panel de administración (`/admin/geozones`)
