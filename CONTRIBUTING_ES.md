# Cómo Contribuir a este Projecto

## Miembros del equipo

* Raimond García [github](https://github.com/voodoorai2000) | [twitter](https://twitter.com/voodoorai2000)
* Juanjo Bazán [github](https://github.com/xuanxu) | [twitter](https://twitter.com/xuanxu)
* Enrique García Cota [github](https://github.com/kikito) | [twitter](https://twitter.com/otikik)
* Alberto García Cabeza [github](https://github.com/decabeza)
* Alberto Calderón [github](https://github.com/bertocq) | [twitter](https://twitter.com/bertocq)
* Maria Checa [github](https://github.com/MariaCheca)

## Código de conducta

Los miembros del proyecto y la comunidad de personas que contribuyen a él se adhieren a un código de conducta que se puede consultar en el archivo [CODE_OF_CONDUCT_ES.md](CODE_OF_CONDUCT_ES.md).

## Comunicación general y de incidencias

El método preferido para informar sobre una incidencia en el proyecto es [creando una incidencia en la cuenta de Github del proyecto](https://github.com/consul/consul/issues/new).

Para comunicación más puntual e informal, contacta con los miembros del equipo por twitter.

## Resolver una incidencia

Los administradores utilizan dos etiquetas relacionadas con la disponibilidad para aceptar colaboraciones con las que marcar incidencias:

* `PRs-welcome`: las [incidencias marcadas como PRs-welcome](https://github.com/consul/consul/labels/PRs-welcome) son funcionalidades bien definidas y que están listas para que quien quiera pueda implementarlas.

* `Not-ready`: con esta etiqueta se señalan funcionalidades o cambios que han de realizarse pero que todavía no están del todo definidos o falta alguna decisión a nivel interno que tomar. Por tanto se desaconseja que se inicie su implementación de momento.

Cuando quieras resolver una incidencia mediante código:

* Avisa de que vas a trabajar en esta incidencia añadiendo un comentario.
* Cuando las incidencias tienen a alguien asignado significa que esa persona ya está trabajando en esa issue.
* Haz un fork del proyecto
* Crea una rama para resolver la incidencia desde la rama `master`
* Añade el código necesario para resolver la incidencia en tantos commits como sea preciso
* Asegúrate de que los tests pasan (y escribe más tests para probar la nueva funcionalidad si fuera preciso)
* Sigue estas [buenas prácticas](https://github.com/styleguide/ruby)
* Envía una *pull request* al repositorio principal indicando la incidencia que se está arreglando.

**¿Es tu primer Pull Request?** Puedes aprender en este curso gratuito (en inglés) sobre [cómo contribuir a un proyecto OpenSource en GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)


## Limpiar

En la urgencia del momento, las cosas a veces se ensucian, puedes ayudarnos a limpiar la casa:

* implementando [tests pendientes](https://travis-ci.org/consul/consul)
* incrementando la [cobertura de tests](https://coveralls.io/github/consul/consul?branch=master)
* mejorando la [calidad del código](https://codeclimate.com/github/consul/consul)
* actualizando [dependecias](https://gemnasium.com/consul/consul)
* haciendo el [código consistente](https://github.com/bbatsov/rubocop)

## Otras formas de contribuir sin código

* Si crees que hay una funcionalidad que hace falta, o descubres un problema, abre una incidencia (asegúrate de que
  no haya una incidencia para lo mismo ya abierta antes)
* También puedes ayudar dando este proyecto a conocer

## Cómo escribir una incidencia

* Trata de darle un título descriptivo (algo más que "xxx no funciona").
* Es buena idea incluir las siguientes secciones:
  * Pasos que se han realizado para producir la incidencia
  * Lo que se esperaba que pasara
  * Lo que ha pasado
* También es buena idea que incluyas tu sistema operativo, navegador, versión de navegador y plugins instalados.

¡Gracias! :heart: :heart: :heart:
