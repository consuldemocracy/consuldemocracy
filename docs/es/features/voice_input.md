# Entrada por voz (dictado)

La mayoría de los dispositivos pueden convertir la voz en texto, de forma que las personas pueden hablar en lugar de escribir. Esto se llama dictado o escritura por voz. Es útil para quienes encuentran lenta o difícil la escritura con teclado, y para cualquiera que prefiera hablar al redactar una propuesta, un debate o un comentario.

Consul Democracy no incluye ningún reconocimiento de voz propio. No graba, recibe ni almacena audio. El dictado lo ofrece el sistema operativo (o, en Linux, una aplicación independiente) y el resultado se inserta en el campo de texto como si se hubiera escrito con el teclado.

Para que los usuarios conozcan esta opción, el campo de descripción de los formularios para crear propuestas, debates, proyectos de gasto y propuestas de legislación colaborativa muestra una breve indicación: "Puedes dictar con la escritura por voz de tu dispositivo." Puedes cambiar el texto de la indicación como se explica en [Traducciones y textos](../customization/translations.md) (el identificador es `shared.voice_input_hint`).

Esta página explica cómo usar el dictado integrado en cada sistema operativo. Puedes compartir estos pasos con tus usuarios o enlazar esta página desde tus propias páginas de ayuda.

## Resumen

| Dispositivo | Herramienta | Cómo empezar |
| --- | --- | --- |
| Windows 10 y 11 | Escritura por voz (incluida en el sistema) | Pulsa la tecla Windows + H |
| macOS | Dictado (incluido en el sistema) | Usa el atajo de Dictado, o Edición > Iniciar dictado |
| Linux | Handy (aplicación gratuita independiente) | Pulsa el atajo que elijas en Handy |
| Android | Escritura por voz en Gboard (el teclado de Google) | Toca el icono del micrófono del teclado |
| iPhone y iPad | Dictado (incluido en el sistema) | Toca la tecla del micrófono del teclado |

## Antes de empezar

* Haz clic o toca dentro del campo de texto donde quieras escribir. El texto dictado se inserta donde está el cursor.
* Necesitas un micrófono que funcione. Los teléfonos y la mayoría de los portátiles tienen uno integrado.
* Es posible que tu dispositivo te pida permiso para usar el micrófono la primera vez. El permiso lo solicita tu dispositivo, no Consul Democracy.
* No todos los idiomas están disponibles en todos los dispositivos. Si tu idioma no está disponible, usa el teclado.
* Según el dispositivo y el idioma, tu voz puede procesarse en tu dispositivo o enviarse al proveedor del servicio de dictado (Microsoft, Apple, Google). Consulta la información de privacidad de tu dispositivo si esto es importante para ti.
* Lee siempre el texto después de dictar. El reconocimiento de voz puede cometer errores, sobre todo con nombres, términos técnicos y en entornos ruidosos.

## Windows

Windows 11 llama a esta función _escritura por voz_ y Windows 10 la llama _dictado_. El atajo es el mismo en ambos. La escritura por voz necesita conexión a internet.

### Activar y usar la escritura por voz

1. Haz clic dentro del campo de texto donde quieras escribir.
2. Pulsa la tecla **Windows** + **H** del teclado. En una pantalla táctil, pulsa en su lugar el botón del micrófono del teclado táctil.
3. Aparece una pequeña barra de escritura por voz. Espera a que muestre "Escuchando..." y empieza a hablar.
4. Para parar, pulsa de nuevo la tecla **Windows** + **H**, haz clic en el botón del micrófono de la barra o di "Detén la escucha".

Puedes decir el nombre de los signos de puntuación, como "coma", "punto" o "signo de interrogación", para añadirlos al texto.

### Dictar en otro idioma

1. Abre **Inicio > Configuración > Hora e idioma > Idioma y región**.
2. En **Idiomas preferidos**, selecciona **Agregar un idioma**, elige tu idioma y selecciona **Siguiente**.
3. Selecciona **Siguiente** (o **Instalar**) para terminar de añadir el idioma.
4. Pulsa la tecla **Windows** + **Barra espaciadora** y elige ese idioma.
5. Pulsa la tecla **Windows** + **H** y habla en ese idioma.

### Si no funciona

* Asegúrate de que el cursor está dentro de un campo de texto. La escritura por voz solo se inicia si hay un lugar donde escribir.
* Abre **Inicio > Configuración > Privacidad y seguridad > Micrófono** y comprueba que el acceso al micrófono está activado.
* Abre **Inicio > Configuración > Sistema > Sonido > Entrada** y comprueba que está seleccionado el micrófono correcto.
* Si el Acceso por voz ya está en ejecución, sustituye a la escritura por voz. Selecciona el campo de texto y empieza a hablar, o desactiva el Acceso por voz.

Más información: [Usar la escritura por voz para hablar en lugar de escribir en tu PC (Soporte de Microsoft)](https://support.microsoft.com/es-es/accessibility/windows/use-voice-typing-to-talk-instead-of-type-on-your-pc).

## macOS

En un Mac, la función se llama _Dictado_. Hay que activarla una vez.

### Activar el Dictado

1. Elige **menú Apple > Ajustes del Sistema**.
2. Haz clic en **Teclado** en la barra lateral. Puede que tengas que desplazarte hacia abajo.
3. Busca **Dictado**, actívalo y haz clic en **Activar** si se te pide.
4. Si tu Mac te pregunta si quieres compartir grabaciones de audio para mejorar Siri y el Dictado, elige la opción que prefieras. Puedes cambiarlo después en **Ajustes del Sistema > Privacidad y seguridad > Analíticas y mejoras**.
5. Opcional: en la misma sección **Dictado**, abre el menú **Atajo** y elige el atajo que quieras usar para iniciar el Dictado.

### Usar el Dictado

1. Haz clic dentro del campo de texto donde quieras escribir.
2. Inicia el Dictado con tu atajo de Dictado, con la tecla del micrófono del teclado (si la tiene) o eligiendo **Edición > Iniciar dictado** en la barra de menús.
3. Habla. Di "nueva línea" o "nuevo párrafo" para empezar una línea nueva, y di el nombre de los signos de puntuación, como "signo de exclamación", para añadirlos.
4. Para parar, pulsa la tecla **Esc**, la tecla del micrófono o tu atajo de Dictado. El Dictado también se detiene solo tras 30 segundos sin voz.

### Otros ajustes

* **Idioma:** en **Ajustes del Sistema > Teclado > Dictado**, haz clic en **Editar** junto a **Idiomas** para añadir o quitar un idioma. Con varios idiomas, haz clic en el indicador de idioma junto al cursor (o pulsa la tecla Globo) para cambiar.
* **Micrófono:** usa el menú **Fuente del micrófono** de la misma sección para elegir el micrófono.
* **Privacidad:** el texto bajo el ajuste de Dictado indica si tu voz se procesa en tu Mac o se envía a Apple.

Si el **Control por voz** está activado, sustituye al Dictado estándar. Desactiva el Control por voz para usar los pasos anteriores.

Más información: [Dictar mensajes y documentos en el Mac (Soporte de Apple)](https://support.apple.com/es-es/guide/mac-help/mh40584/26/mac).

## Linux

Linux no tiene una función de dictado integrada que funcione en todos los escritorios y todos los navegadores. Una opción gratuita es [Handy](https://handy.computer), una aplicación de código abierto que convierte la voz en texto en cualquier campo de texto. Handy es un proyecto independiente y Consul Democracy no lo mantiene. Ejecuta el reconocimiento de voz en tu propio ordenador, por lo que tu voz no se envía a ningún servicio en la nube. Handy también funciona en Windows y macOS.

Los pasos siguientes son un resumen. Para ver las instrucciones más recientes, consulta la [página del proyecto Handy](https://github.com/cjpais/handy).

### Instalar Handy

1. Ve a [handy.computer](https://handy.computer) o a la [página de versiones de Handy](https://github.com/cjpais/handy/releases) y descarga la última versión para Linux.
2. Instálala:
   * En Debian y Ubuntu, instala el archivo `.deb` con APT para que también se instalen las dependencias, por ejemplo `sudo apt install ./Handy_*.deb`.
   * En otras distribuciones, usa el AppImage de la página de versiones.
3. Si Handy no arranca y avisa de que falta la biblioteca `libgtk-layer-shell.so.0`, instálala:

```bash
# Debian y Ubuntu
sudo apt install libgtk-layer-shell0
# Fedora
sudo dnf install gtk-layer-shell
# Arch Linux
sudo pacman -S gtk-layer-shell
```

### Instalar una herramienta de entrada de texto

Handy necesita una pequeña herramienta auxiliar para escribir el texto en otras aplicaciones. Instala la que corresponda a tu servidor gráfico. Si no sabes cuál usas, ejecuta `echo $XDG_SESSION_TYPE`.

| Servidor gráfico | Herramienta | Comando |
| --- | --- | --- |
| X11 | xdotool | `sudo apt install xdotool` |
| Wayland | wtype (recomendada) | `sudo apt install wtype` |
| Wayland o X11 | dotool (alternativa) | `sudo apt install dotool`, después `sudo usermod -aG input $USER` y cierra sesión y vuelve a entrar |

En Ubuntu 26.04 con Wayland, `wtype` no funciona. La documentación de Handy recomienda usar `ydotool`; sigue las instrucciones de la página del proyecto Handy.

### Configurar Handy

1. Inicia Handy y concede los permisos de micrófono (y de accesibilidad) si se te piden.
2. Abre **Settings > Models** y elige un modelo de reconocimiento de voz. La primera vez, Handy descarga el modelo, que puede ser grande. Los modelos pequeños son más rápidos y usan menos memoria; los grandes suelen ser más precisos.
3. Abre los ajustes de atajos y elige un atajo de teclado. Handy puede funcionar como _pulsar para hablar_ (mantén pulsado el atajo mientras hablas y suéltalo para parar) o como interruptor (pulsa una vez para empezar y otra para parar).
4. En Wayland, los atajos globales deben configurarse en tu entorno de escritorio. Crea un atajo personalizado que ejecute el comando `handy --toggle-transcription`:
   * **GNOME:** **Configuración > Teclado > Atajos de teclado > Atajos personalizados**.
   * **KDE Plasma:** **Preferencias del Sistema > Atajos > Atajos personalizados**.

La interfaz de Handy está en inglés, por lo que los nombres de sus menús se indican tal como aparecen en la aplicación.

### Usar Handy

1. Haz clic dentro del campo de texto donde quieras escribir. Puede estar en cualquier aplicación, incluido tu navegador web.
2. Pulsa tu atajo (y mantenlo pulsado si usas pulsar para hablar) y habla.
3. Detén la grabación. Tras un momento, Handy inserta el texto transcrito en el campo.

### Si no funciona

* Comprueba que has instalado la herramienta de entrada de texto de tu servidor gráfico (ver arriba).
* Si el texto no aparece en el lugar correcto, abre **Settings > Advanced** en Handy y establece **Overlay Position** en **None**.
* Si Handy muestra una ventana en blanco o se cierra al arrancar, consulta la sección "Known issues" de la página del proyecto Handy.

## Android

La mayoría de los teléfonos Android usan Gboard, el teclado de Google, que tiene un micrófono integrado para la escritura por voz. Si tu teléfono usa otro teclado (por ejemplo, el teclado de Samsung), busca una tecla de micrófono en ese teclado; los pasos son similares.

### Activar la escritura por voz

1. Instala **Gboard** desde Google Play Store si tu teléfono todavía no lo tiene.
2. Abre **Ajustes > Sistema > Idiomas y entrada > Teclado en pantalla** y comprueba que Gboard es el teclado activo. Los nombres de estos menús varían según el teléfono.
3. Abre los ajustes de Gboard, selecciona **Escritura por voz** y actívala.

### Usar la escritura por voz

1. Toca el campo de texto donde quieras escribir, para que aparezca el teclado.
2. Toca el icono del **micrófono** en la parte superior del teclado.
3. La primera vez, Android pide permiso para grabar audio. Elige **Solo mientras la app está en uso** (o **Solo esta vez**). La escritura por voz no puede funcionar sin acceso al micrófono.
4. Habla cuando el teclado indique que está escuchando.
5. Para parar, toca de nuevo el icono del micrófono. Para volver al teclado normal, toca el icono del teclado.

Puedes decir signos de puntuación como "coma", "punto", "signo de interrogación", "nueva línea" o "nuevo párrafo". Los comandos de puntuación no están disponibles en todos los idiomas. Para corregir una palabra, mantenla pulsada, toca el micrófono y di la palabra nueva.

### Dictar en otro idioma

1. Añade el idioma en **Ajustes de Gboard > Idiomas**.
2. Con la escritura por voz activa, toca la abreviatura del idioma que aparece abajo a la izquierda en la barra de voz y elige un idioma.

En algunos teléfonos Pixel, la escritura por voz se llama _Escritura por voz avanzada_ o _Escritura por voz del Asistente_ y funciona de forma ligeramente distinta. Los pasos básicos son los mismos.

Más información: [Escribir con la voz (Ayuda de Gboard)](https://support.google.com/gboard/answer/2781851?hl=es).

## iPhone y iPad

En iPhone y iPad, la función se llama _Dictado_. Hay que activarla una vez.

### Activar el Dictado

1. Abre **Ajustes > General > Teclado**.
2. Activa **Activar dictado**. Si aparece un mensaje, toca **Activar dictado** de nuevo.

### Usar el Dictado

1. Toca el campo de texto donde quieras escribir, para que aparezca el teclado.
2. Toca la tecla del **micrófono** del teclado. La primera vez, toca **OK** o **Permitir** si iOS pide permiso para usar el micrófono.
3. Habla. iOS añade la puntuación automáticamente y también puedes decirla, como "coma" o "signo de interrogación". Puedes seguir usando el teclado mientras dictas.
4. Para parar, toca de nuevo la tecla del micrófono o la tecla del teclado.

### Si no ves la tecla del micrófono

* Comprueba que **Activar dictado** está activado en **Ajustes > General > Teclado**.
* Comprueba que el Dictado no está bloqueado en **Ajustes > Tiempo de uso > Restricciones de contenido y privacidad**.
* Algunos teclados de terceros no tienen tecla de micrófono. Cambia al teclado de Apple con la tecla del globo.
* En un iPad con teclado externo, el teclado en pantalla está oculto. Usa la tecla de dictado de tu teclado, si la tiene.
* El Dictado no está disponible en todos los idiomas y regiones. En los modelos e idiomas compatibles también funciona sin conexión a internet.

Más información: [Dictar texto en el iPhone (Soporte de Apple)](https://support.apple.com/es-es/guide/iphone/iph2c0651d2/ios).
