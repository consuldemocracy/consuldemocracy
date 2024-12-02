# Configuración básica

Una vez que tengas Consul Democracy funcionando en el servidor, hay algunas opciones básicas de configuración que probablemente quieras definir para poder empezar a usarlo.

Para ello, deberás acceder a tu instalación de Consul Democracy a través de cualquier navegador e identificarte con el usuario de administración (inicialmente es el usuario `admin@consul.dev` con la contraseña `12345678`).

Una vez identificado, en la parte superior derecha de la pantalla verás un botón con el texto "Menú". Pincha en él y a continuación pincha en "Administración" para ir al área de administración. Desde esta interfaz puedes configurar las siguientes opciones básicas:

## Cambio de la contraseña de administrador

Ya que el correo `admin@consul.dev` no existe, y que cualquiera que esté familiarizado con Consul Democracy sabrá cuál es la contraseña por defecto de administrador, recomendamos encarecidamente que cambies las credenciales justo después de instalar la aplicación.

En primer lugar, identifícate como administrador utilizando el correo y la contraseña por defecto.

A continuación, entra en "Mi cuenta". En la página de "Mi cuenta", pincha en "Cambiar mis datos de acceso". Rellena el formulario con el nuevo correo y la nueva contraseña.

La contraseña se actualizará inmediatamente, y podrás cerrar la sesión y abrir una nueva utilizando la nueva contraseña. Para actualizar la dirección de correo, recibirás un correo en esa dirección pidiéndote que confirmes tu cuenta. Pincha en el enlace incluido en ese correo, y podrás identificarte en la aplicación usando la nueva dirección de correo.

También puedes cambiar el nombre de usuario por defecto ("admin"). Una vez más, entra en "Mi cuenta". En esa página, verás un formulario que incluye el campo "Nombre de usuario". Para actualizarlo, cambia el valor de ese campo y pincha el botón de "Guardar cambios".

Es posible que, antes de hacer todo esto, ya hayas registrado un nuevo usuario que te gustaría usar como administrador. De ser así, en lugar de seguir el proceso descrito anteriormente, identifícate como administrador y vete al área de administración. Una vez allí, en el menú de navegación, pincha en "Perfiles" para abrir un submenú y a continuación pincha en "Administradores". Para añadir un administrador, usa el formulario de búsqueda e introduce el correo del usuario al que quieras hacer administrador (sabemos que no es muy intuitivo; ¡perdón!). Una vez que aparezcan los resultados de búsqueda, pincha en "Añadir como Administrador". Ahora puedes cerrar sesión, entrar con el nuevo administrador, pinchar nuevamente en "Perfiles" y a continuación en "Administradores", y borrar el administrador por defecto `admin@consul.dev`. Ten en cuenta que con esto ese usuario no se borrará, pero ya no tendrá permisos de administrador.

## Parámetros de la configuración global

En el menú de navegación del área de administración, pincha en "Configuración" para abrir un submenú y a continuación pincha en "Configuración global". Aquí encontrarás muchos parámetros interesantes, pero por el momento te recomendamos definir algunos de los más básicos (más adelante, cuando estés más familiarizado con la herramienta, podrás volver a esta sección a configurar otros parámetros):

* Nombre del sitio. Este nombre aparecerá en el asunto de emails, páginas de ayuda, ...
* Nombre email remitente. Este nombre aparecerá como nombre del remitente en los emails enviados desde la aplicación. Como por ejemplo el email que los usuarios reciben para confirmar que han creado su cuenta.
* Dirección email remitente. Esta dirección de email aparecerá en los emails enviados desde la aplicación.
* Edad mínima para participar. Si utilizas un sistema de verificación de usuarios, esta será la edad mínima que se exigirá a los usuarios.
* Número de apoyos necesarios para aprobar una Propuesta. Si utilizas la sección de propuestas ciudadanas, puedes definir un mínimo de apoyos que necesitan las propuestas para ser consideradas. Cualquier usuario podrá crear propuestas, pero solo las que lleguen a ese valor serán tenidas en cuenta.
* Cargos públicos de nivel x. Consul Democracy permite que algunas cuentas de usuario se marquen como "cuentas oficiales", apareciendo más resaltadas sus intervenciones en la plataforma. Esto por ejemplo se usa en una ciudad si se quieren definir cuentas para el Alcalde, los Concejales, etc. Esta opción de cargos públicos te permitirá definir la etiqueta oficial que aparece al lado de los nombres de usuario de estas cuentas de mayor importancia (nivel 1) a menor (nivel 5).

## Categorías de las propuestas

Cuando los usuarios crean propuestas en la plataforma, se sugieren unas categorías generales para ayudar a organizar las propuestas. Para definir estas categorías, en el menú de navegación del área de administración pincha en "Configuración" y a continuación en "Temas de propuestas". En la parte superior encontrarás un formulario en el que puedes escribir el nombre de un tema y crearlo con el botón que aparece a continuación.

## Definición de geozonas

Las geozonas son áreas territoriales más pequeñas que la zona en la que usas Consul Democracy (por ejemplo, los distritos en una ciudad en la que se use Consul Democracy). Si las activas, esto permitirá por ejemplo que las propuestas ciudadanas se asignen a una zona concreta, o que las votaciones estén restringidas a la gente que viva en alguna zona.

En el menú de navegación del área de administración, pincha en "Configuración" y a continuación en "Zonas". El botón "Crear una zona" que aparecerá a la derecha te permitirá crear nuevas geozonas. Solamente el nombre es necesario para definirlas, pero podrás añadir otros datos que pueden ser útiles en ciertas secciones. Inicialmente te recomendamos que empieces definiendo solamente los nombres de las zonas.

Una vez definidas, si creas una propuesta ciudadana verás cómo una de las opciones en el formulario de creación te permite elegir si tu propuesta se refiere a una geozona concreta.

Si activas las geozonas, puedes también mostrar una imagen que represente el área con las zonas. Esta imagen puedes cambiarla pinchando (en el menú de navegación del área de administración) en "Contenido del sitio" y a continuación en "Personalizar imágenes". La imagen por defecto que podrás cambiar es la titulada "map".

## Mapa para geolocalizar propuestas

Puedes permitir que, al crear propuestas, los usuarios puedan situarlas en un mapa. Para ello tienes que definir qué mapa quieres mostrar.

En primer lugar, en el menú de navegación del área de administración, pincha en "Configuración" y a continuación en "Configuración global". En la parte superior de esta página encontrarás varios enlaces a modo de pestañas; pincha en "Funcionalidades".

En esta página, busca una funcionalidad llamada "Geolocalización de propuestas y proyectos de gasto". Si no está activada, actívala.

A continuación, en la parte superior de esta página, pincha en "Configuración del mapa". Aquí encontrarás tres parámetros que tienes que rellenar:

* Latitud. Latitud para mostrar la posición del mapa.
* Longitud. Longitud para mostrar la posición del mapa.
* Zoom. Zoom para mostrar la posición del mapa. Puedes probar con un valor inicial y luego cambiarlo más adelante.

Una vez rellenados estos campos, pincha en el botón "Actualizar".

Si todo ha sido configurado correctamente, verás aquí el mapa centrado en la latitud y longitud que introdujiste antes. Puedes centrar correctamente el mapa y cambiar el nivel de zoom directamente sobre el mapa, pulsando luego el botón "Actualizar" que hay debajo de él.

## Emails a usuarios

Consul Democracy envía por defecto una serie de correos electrónicos a los usuarios. Por ejemplo, al crear una cuenta de usuario, al intentar recuperar la contraseña, al recibir un mensaje de otro usuario, etc.

Puedes comprobar el contenido de las plantillas de estos correos pinchando en "Mensajes a usuarios" (en el menú de navegación del área de administración) y a continuación en  "Emails del sistema". Ahí podrás previsualizar cada correo electrónico y ver el archivo donde está el contenido del correo por si quieres [personalizarlo](../customization/customization.md).

## Páginas básicas de información

Consul Democracy cuenta con una serie de páginas básicas de información que se mostrarán a los usuarios. Por ejemplo, "Política de Privacidad", "Preguntas Frecuentes", "Felicidades acabas de crear tu cuenta de usuario", etc.

Puedes modificar estas páginas y crear otras pinchando en "Contenido del sitio" (en el menu de navegación del área de administración) y a continuación en "Personalizar páginas".

## Página principal del sitio

Al acceder a tu instalación de Consul Democracy, los usuarios verán la página principal de la plataforma. Esta página es configurable, para que muestres el contenido que te parezca más relevante. Puedes modificarla pinchando en "Contenido del sitio" (en el menú de navegación del área de administración) y a continuación en "Homepage".

Prueba a crear "Encabezados" y "Tarjetas" y a activar las diferentes funcionalidades que encontrarás debajo para ver el efecto que producen en tu página principal.

## Textos de la plataforma

Si, en el menú de navegación de área de administración, pinchas en "Contenido del sitio" y a continuación en "Personalizar textos", verás diferentes pestañas con una serie de textos. Estos son todos los textos que se muestran en la plataforma. Por defecto, puedes utilizar los que existen, pero en cualquier momento puedes acceder a esta sección para modificar cualquiera de los textos.

Para más información sobre cómo añadir nuevas traducciones a tu versión de Consul Democracy, accede a la sección ["Textos y traducciones"](../customization/translations.md) de esta documentación.

## Tipos de procesos de participación

Por defecto, encontrarás en Consul Democracy diferentes tipos de procesos de participación para los usuarios. Para empezar a familiarizarte con la plataforma, te recomendamos tenerlos todos activados, pero puedes desactivar todos los que no te parezcan necesarios. Para ello, en el menú de navegación del área de administración, pincha en "Configuración" y posteriormente en "Configuración global". En la parte superior de esta página encontrarás varios enlaces a modo de pestaña; pincha en "Procesos de participación".

Encontrarás diversas funcionalidades con los nombres de los diferentes canales de participación: "Debates", "Propuestas", "Votaciones", "Legislación colaborativa" y "Presupuestos participativos". Puedes desactivar cualquiera de las funcionalidades y dejará de mostrarse en tu instalación de Consul Democracy.

## Más información y documentación detallada

Las opciones mencionadas te permitirán tener tu versión inicial de Consul Democracy. Te recomendamos que accedas a la sección [Documentación y guías sobre Consul Democracy](documentation_and_guides.md), donde podrás encontrar enlaces a documentación más detallada.
