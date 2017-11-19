# Contribuciones

Te agradecemos que quieras colaborar contribuyendo a la Documentación de [Consul](https://github.com/consul/consul). Aquí tienes una guía donde consultar cómo sugerir cambios y mejoras al proyecto.

## Código de Conducta

Los miembros del proyecto y la comunidad de personas que contribuyen a él se adhieren a un código de conducta que se puede consultar en el archivo [CODE_OF_CONDUCT_ES.md](CODE_OF_CONDUCT_ES.md).

## Reporte de incidencias y comunicación

Si has visto alguna sección incompleta o ausente, te animamos a [abrir una incidencia en el repositorio de Documentación de Consul](https://github.com/consul/docs/issues/new).

Para comunicaciones más informales, contacta con nosotros a través del [gitter de consul](https://gitter.im/consul/consul)

Antes de hacerlo, **por favor tómate un tiempo para comprobar los [issues ya existentes](https://github.com/consul/docs/issues) y asegúrate de que lo que estás a punto de reportar no ha sido reportado previamente** por otra persona. De ser así, si tienes más detalles acerca de la incidencia puedes escribir un comentario en la página ‑¡un poco de ayuda puede marcar una gran diferencia!

Para escribir un nuevo issue, ten en cuenta estas recomendaciones para hacerlo más fácil de leer y comprender:

- Intenta usar un título descriptivo.
- Es buena idea incluir algunas secciones -en caso de que sean necesarias- como los pasos para reproducir el error, el comportamiento o respuesta que cabría esperar, la respuesta que devuelve o capturas de pantalla.
- También puede ser de ayuda incluir en la descripción tu sistema operativo, versión del navegador que usaste y posibles plugins instalados.

## Resolver incidencias

[Las incidencias en los Docs](https://github.com/consul/docs/issues) con la etiqueta `PRs-welcome` son tareas bien definidas que están listas para ser resueltas por cualquiera que se ofrezca a ello. Por otra parte, la etiqueta `not-ready` indica las tareas o cambios que aún están pendientes de concretar, por lo que recomendamos no intentar resolverlos hasta que los/as miembros/as del proyecto lleguen a una resolución.

Te sugerimos seguir los siguientes pasos para facilitar el seguimiento de los cambios que vayas a hacer:

- Primero, añade un comentario en la incidencia para notificar que vas resolverlo. Si el issue tiene a alguien asignado significa que ya hay alguien encargado de él.
- Si no existe una incidencia para la tarea que vas a resolver, puede ser una buena idea crearla para hablar en la página de la incidencia con el resto de la comunidad acerca de como afrontar la tarea. A veces ayuda a prevenir que el debate se produzca en la revisión del Pull Request, y la sensación de haber dedicado tiempo en trabajo en vano.
- Crea un fork del proyecto.
- Crea una rama de funcionalidad basada en la rama `master`. Para identificarla más fácilmente, puedes nombrarla con el número de incidencia seguido de un nombre conciso y descriptivo (por ejemplo: `123-fix_proposals_link`).
- Desarrolla los cambios haciendo commits en tu nueva rama.
- Cuando hayas terminado, envía un **pull request** al [repositorio de Consul](https://github.com/consul/docs/) describiendo la solución que propones para ayudarnos a entenderlo. También es importante que especifiques qué incidencia estás resolviendo al principio de la descripción del PR (por ejemplo, `Fixes #123`).
- El equipo de Consul revisará tu PR y podrá sugerir cambios si son necesarios. Una vez esté todo bien, tus cambios serán introducidos en el proyecto :)

> **¿Es tu primer Pull Request?** Puedes aprender cómo contribuir a un proyecto en Github siguiendo los tutoriales [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github) (en inglés).

## Cómo contribuir desde tu ordenador

### Gitbooks

Esta documentación se aloja online en [Gitbook](https://www.gitbook.com) de forma gratuita, y está formada de ficheros de texto [Markdown](https://es.wikipedia.org/wiki/Markdown). Markdown es un lenguage de marcado sencillo para dar estilo a párrafos, listas etc... Consulta [la guía de Gitbook sobre Markdown](https://toolchain.gitbook.com/syntax/markdown.html)

Para visualizar en tu navegador como se verían tus cambios puedes usar [https://github.com/GitbookIO/gitbook](https://github.com/GitbookIO/gitbook) para levantar un servidor local que sirva la documentación.

### Markdown Linter

Para mantener la consistencia en la sintaxis de ficheros Markdown este proyecto usa [Markdown Linter](https://github.com/markdownlint/markdownlint) junto a un fichero de configuración `.mdlrc` en el directorio raiz.

Para usarla instala la herramienta con `gem install mdl` y ejecuta después `mdl .`

## Otras formas de contribuir

Apreciaremos cualquier tipo de contribución a la Documentación de Consul. Incluso si no puedes contribuir a escribir nuevas secciones, puedes:

- Crea una incidencia para notificar al resto de contribuidores con toda la información posible sobre lo que falta o esta incorrecto.
- Ayuda a traducir documentación existente a un idioma que domines suficientemente.

Gracias! ❤️❤️❤️
