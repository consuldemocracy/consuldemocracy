# Funcionalidades

Actualmente Consul soporta:

* Registro y verificación de usuarios tanto en la misma aplicación como con distintos proveedores (Twitter, Facebook, Google).
* Distintos perfiles de usuario, tanto ciudadanos individuales como organizaciones.
* Distintos perfiles de administración, gestión y moderación.
* Espacio permanente de debates y propuestas.
* Comentarios anidados en debates y propuestas.
* Presupuestos participativos a través de distintas fases.

# Usuario

Para registrar un usuario nuevo es posible hacerlo en la propia aplicación, dando un nombre de usuario (nombre público que aparecerá en tus publicaciones), un correo electrónico y una contraseña con la que se accederá a la web. Se deben aceptar las condiciones de uso. El usuario debe confirmar su correo electrónico para poder iniciar sesión.

![Registro de usuario](imgs/user_registration.png "Registro de usuario")

Por otro lado también se puede habilitar el registro a través de servicios externos como Twitter, Facebook y Google. Para esto hace falta tener la configuración habilitada en Settings y las claves y secretos de estos servicios en el fichero *config/secrets.yml*.

```
  twitter_key: ""
  twitter_secret: ""
  facebook_key: ""
  facebook_secret: ""
  google_oauth2_key: ""
  google_oauth2_secret: ""
```

Una vez el usuario ha iniciado sesión le aparecerá la posibilidad de verificar su cuenta, a través de una conexión con el padrón municipal.

![Verificación de usuario](imgs/user_preverification.png?raw=true "Verificación de usuario")

Para esta funcionalidad hace falta que el padrón municipal soporte la posibilidad de conexión a través de una API, puedes ver un ejemplo en *lib/census_api.rb*.

![Verificación de usuario](imgs/user_verification.png?raw=true "Verificación de usuario")

# Perfil de usuario

Dentro de su perfil cada usuario puede configurar si quiere mostrar públicamente su lista de actividades, así como las notificaciones que le enviará la aplicación a través de correo electrónico. Estas notificiaciones pueden ser:

* Recibir un email cuando alguien comenta en sus propuestas o debates.
* Recibir un email cuando alguien contesta a sus comentarios.
* Recibir emails con información interesante sobre la web.
* Recibir resumen de notificaciones sobre propuestas.
* Recibir emails con mensajes privados.

# Paneles de administración, gestión y moderación

Consul cuenta con tres perfiles de usuario diferenciados para hacer tareas de revisión y moderación de los contenidos. Se detallan a continuación:

## Administración

![Panel de administración](imgs/panel_administration.png?raw=true "Panel de administración")

Desde aquí puedes administrar el sistema, a través de las siguientes acciones:

### Temas de debate

Los temas (también llamadas tags, o etiquetas) de debate son palabras que definen los usuarios al crear debates, para catalogarlos (ej: sanidad, movilidad, arganzuela, ...). Aquí se pueden eliminar temas inapropiados, o marcarlos para ser propuestos al crear debates (cada usuario puede definir los que quiera, pero se le sugieren algunos que nos parecen útiles como catalogación por defecto; aquí se puede cambiar cuáles se sugieren).

### Propuestas/Debates/Comentarios ocultos

Cuando un moderador o un administrador oculta una Propuesta/Debate/Comentario aparecerá en esta lista. De esta forma los administradores pueden revisar que se ha ocultado el elemento adecuado.
* Al pulsar Confirmar se acepta el que se haya ocultado, se considera que se ha hecho correctamente.
* Al pulsar Volver a mostrar se revierte la acción de ocultar y vuelve a ser una Propuesta/Debate/Comentario visible, en el caso de que se considere que ha sido una acción errónea el haberlo ocultado.
Para facilitar la gestión, arriba encontramos un filtro con las secciones: "pendientes" (los elementos sobre los que todavía no se ha pulsado "confirmar" o "volver a mostrar", que deberían ser revisados todavía), "confirmados" y "todos".

Es recomendable revisar regularmente la sección "pendientes".

### Usuarios bloqueados

Cuando un moderador o un administrador bloquea a un usuario aparecerá en esta lista. Al bloquear a un usuario, éste deja de poder utilizarlo para ninguna acción de la web. Los administradores pueden desbloquearlos pulsando el botón al lado del nombre del usuario en la lista.

### Organizaciones

En la web hay dos tipos de usuarios: individuales y organizaciones. Cualquier persona puede crear usuarios de un tipo o de otro en la propia web. Los usuarios de organizaciones pueden ser verificados por parte de los administradores, confirmando que quien gestiona el usuario efectivamente representa a esa organización. Una vez se haya realizado el proceso de verificación, por el proceso externo a la web que se haya definido para ello, se pulsa el botón "Verificar" para confimarlo; lo que hará que al lado del nombre de la organización aparezca una etiqueta señalando que es una organización verificada.

En caso de que el proceso de verificación haya sido negativo, se pulsa el botón "Rechazar". Para editar alguno de los datos de la organización, se pulsa el botón "Editar".

Las organizaciones que no aparecen en la lista pueden ser encontradas para actuar sobre ellas por medio del buscador en la parte superior. Para facilitar la gestión, arriba encontramos un filtro con las secciones: "pendientes" (las organizaciones que todavía no han sido verificadas o rechazadas), "verificadas", "rechazadas" y "todas".

Es recomendable revisar regularmente la sección "pendientes".

### Cargos Públicos

En la web, los usuarios individuales pueden ser usuarios normales, o cargos públicos. Estos últimos se diferencian de los primeros únicamente en que al lado de sus nombres aparece una etiqueta que les identifica, y cambia ligeramente el estilo de sus comentarios. Esto permite que los usuarios les identifiquen más fácilmente. Al lado de cada usuario vemos la identificación que aparece en su etiqueta, y su nivel (la manera que internamente usa la web para diferenciar entre un tipo de cargos y otros). Pulsando el botón "Editar" al lado del usuario, se puede modificar su información. Los cargos públicos que no aparecen en la lista pueden ser encontrados para actuar sobre ellos por medio del buscador en la parte superior.

### Moderadores

Mediante el buscador de la parte superior se pueden buscar usuarios, para activarlos o desactivarlos como moderadores de la web. Los moderadores al acceder a la web con su usuario ven en la parte superior una nueva sección llamada "Moderar".

### Actividad de moderadores

En esta sección se va guardando todas las acciones que realizan los moderadores o los administradores respecto a la moderación: ocultar/mostrar Propuestas/Debates/Comentarios y bloquear usuarios. En la columna "Acción" comprobamos si la acción corresponde con ocultar o con volver a mostrar (restaurar) elementos o con bloquear usuarios. En las demás columnas tenemos el tipo de elemento, el contenido del elemento y el moderador o administrador que ha realizado la acción. Esta sección permite que los administradores detecten comportamientos irregulares por parte de moderadores específicos y que por lo tanto puedan corregirlos.

### Configuración Global

Opciones generales de configuración del sistema.

### Estadísticas

Estadísticas generales del sistema.

## Moderación

![Panel de moderación](imgs/panel_moderation.png?raw=true "Panel de moderación")

Desde aquí puedes moderar el sistema, a través de las siguientes acciones:

### Propuestas / Debates / Comentarios

Cuando un usuario marca en una Propuesta/Debate/Comentario la opción de "denunciar como inapropiado", aparecerá en esta lista. Respecto a cada uno aparecerá el título, fecha, número de denuncias (cuántos usuarios diferentes han marcado la opción de denuncia) y el texto de la Propuesta/Debate/Comentario.

A la derecha de cada elemento aparece una caja que podemos marcar para seleccionar todos los que queramos de la lista. Una vez seleccionados uno o varios, encontramos al final de la página tres botones para realizar acciones sobre ellos:

* Ocultar: hará que esos elementos dejen de mostrarse en la web.
* Bloquear autores: hará que el autor de ese elemento deje de poder acceder a la web, y que además todas las Propuestas/Debates/Comentarios de ese usuario dejen de mostrarse en la web.
* Marcar como revisados cuando consideramos que esos elementos no deben ser moderados, que su contenido es correcto, y que por lo tanto deben dejar de ser mostrados en esta lista de elementos inapropiados.

Para facilitar la gestión, arriba encontramos un filtro con las secciones:

* Pendientes: las Propuestas/Debates/Comentarios sobre los que todavía no se ha pulsado "ocultar", "bloquear" o "marcar como revisados", y que por lo tanto deberían ser revisados todavía.
* Todos: mostrando todos las Propuestas/Debates/Comentarios de la web, y no sólo los marcados como inapropiados.
* Marcados como revisados: los que algún moderador ha marcado como revisados y por lo tanto parecen correctos.

Es recomendable revisar regularmente la sección "pendientes".

### Bloquear usuarios

Un buscador nos permite encontrar cualquier usuario introduciendo su nombre de usuario o correo electrónico, y bloquearlo una vez encontrado. Al bloquearlo, el usuario no podrá volver a acceder a la web, y todas sus Propuestas/Debates/Comentarios serán ocultados y dejarán de ser visibles en la web.

## Gestión

![Panel de gestión](imgs/panel_management.png?raw=true "Panel de gestión")

Desde aquí puedes gestionar usuarios a través de las siguientes acciones:

* Usuarios.
* Editar cuenta de usuario.
* Crear propuesta.
* Apoyar propuestas.
* Crear proyecto de gasto.
* Apoyar proyectos de gasto.
* Imprimir propuestas.
* Imprimir proyectos de gasto.
* Invitaciones para usuarios.
