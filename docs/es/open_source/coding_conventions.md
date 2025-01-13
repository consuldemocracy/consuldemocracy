# Convenciones de código

## Linters

Consul Democracy incluye unas herramientas llamadas _linters_ que definen convenciones de código para Ruby, JavaScript, SCSS y Markdown. Seguir estas convenciones hace que el código sea consistente y más fácil de leer y mantener.

Cuando abras una _pull request_ (PR), nuestro sistema de integración continua (CI, por sus siglas en inglés) automáticamente comprueba que el código de la PR sigue estas convenciones (puedes ver el fichero `.github/workflows/linters.yml` para comprobar exactamente qué órdenes se ejecutan). Por favor, comprueba el informe generado por estos linters que aparecerá en la PR.

Es muy probable que prefieras seguir estas convenciones mientras desarrollas en vez de tener que esperar a tenerlo todo listo para abrir una PR. Para ello, recomendamos que compruebes si tu editor ofrece soporte para estos linters. Cuando un editor tiene suporte para estos linters, cada vez que grabas un fichero recibes información de forma inmediata sobre si estás siguiendo estas convenciones.

Una limitación que tenemos en la actualidad es que hay dos reglas de Rubocop (el linter que usamos para Ruby) que no se siguen siempre en código escrito hace varios años y otra regla que da falsos positivos. Estas reglas aparecen marcadas con `Severity: refactor` en el fichero `.rubocop.yml`; sería conveniente que configuraras tu editor para que no informase sobre estas reglas.

Si tu editor no ofrece soporte para estos linters, puedes ejecutar la orden `bundle exec pronto run`, que analizará los cambios que hay en tu rama actual, con lo que es considerablemente más rápido que ejecutar las órdenes que analizan todos los ficheros del proyecto.

## Más allá de los linters

Los linters no pueden comprobar todas las convenciones de código que seguimos. Además, hay código antiguo que no sigue estas convenciones, con lo que a veces te será difícil saber qué camino tomar.

A continuación, comentamos algunas claves que esperamos te sirvan de ayuda. No intentes memorizarlas todas de golpe; en lugar de ello, comprueba cuáles de estas convenciones están relacionadas con el código que que estás escribiendo ahora mismo.

### Añade solamente textos en inglés y en español

La mayoría de desarrolladores de Consul Democracy hablan inglés y español pero su conocimiento de otros idiomas es bastante limitado. Por otro lado, hay mucha gente que sabe otros idiomas pero no tiene el conocimiento técnico suficiente como para trabajar con el código fuente de Consul Democracy. Por eso, utilizamos el [Crowdin de Consul Democracy](https://crwd.in/consul) para las traducciones a otros idiomas.

Actualmente, esta configuración tiene un inconveniente, y es que si abres una _pull request_ (PR) que incluya cambios en otros idiomas, estos cambios serán reemplazados por el contenido de Crowdin. Así que es mejor que no incluyas textos en otros idiomas en una PR; en lugar de esto, una vez que el contenido de la PR haya sido incluido en Consul Democracy, utiliza Crowdin para añadir traducciones a otros idiomas.

### Usa componentes en vez de vistas y "helpers"

Es posible que hayas visto código HTML/ERB tanto en el directorio `app/views/` como en el directorio `app/components/`. Para código nuevo, utiliza `app/components/`. Estamos moviendo código existente de `app/views/` a `app/components/` paulatinamente.

Solamente hay un caso en que tienes que añadir código en `app/views/`. Supongamos que estás añadiendo un controlador nuevo llamado `AwesomeThingsController` que contiene la acción `index`. En este caso, necesitammos crear el archivo `app/views/awesome_things/views/index.html.erb`, con el siguiente contenido (nótese que, en el código que aparece a continuación, es posible que tengas que pasar uno o más parámetros al método `new` si el componente los necesita):

```erb
<%= render AwesomeThings::IndexComponent.new %>
```

El código al que se llama desde aquí iría en los archivos `app/components/awesome_things/index_component.rb` y `app/components/awesome_things/index_component.html.erb`.

De manera similar, cuando sea posible, evita usar métodos de _helpers_ y en su lugar añade métodos a los componentes. Como los métodos de _helpers_ están disponibles de forma global, al escribir un método de _helper_ con el mismo nombre que uno existente (incluso si el método existente está en otro módulo o incluso en una de nuestras dependencias), el método nuevo reemplazará al antiguo sin informar siquiera de ello. Los métodos de componentes, en cambio, solamente pueden accederse desde la clase del componente, lo que los hace más fiables y fáciles de refactorizar.

### Sigue la misma estructura de ficheros (S)CSS y JavaScript que para componentes

Si añades código de CSS o JavaScript que solamente afecta a un componente, crea un archivo siguiente la misma estructura de ficheros que dicho componente. Por ejemplo, el CSS relacionado con el código en `app/components/admin/budgets/form_component.html.erb` está en `app/assets/stylesheets/admin/budgets/form.scss`.

Las clases de HTML también siguen una estructura similar; por ejemplo, el archivo `app/components/admin/budgets/form_component.html.erb` contiene un elemento HTML con la clase `budgets-form` (nótese que, sin embargo, no siempre somos consistentes en cuanto a cuándo añadir el prefijo `admin-`).

### Utiliza el "concern" Header en páginas del área de administración

Cuando escribas una nueva página en el área de administración, utilizar el _concern_ `Header` en componentes hace que sea más fácil añadir un título y un encabezado adecuado a la página. Añade un método `title` como:

```ruby
class Admin::AwesomeThings::IndexComponent < ApplicationComponent
  include Header

  private

    def title
      t("admin.awesome_things.index.title")
    end
end
```

Esto permite añadir `<%= header %>` en el archivo `.html.erb`, que hará que se incluya la etiqueta `<title>` con el texto adecuado (lo cual es muy importante para temas de accesibilidad) y generará el encabezado de la página.

### Usa botones para peticiones HTTP que no sean GET

Por defecto, pinchar un enlace en un navegador genera una petición GET. Sin embargo, el método `link_to` de Rails acepta una opción `method:`; usarla permite incluir enlaces que generan otro tipo de peticiones (POST, PUT/PATCH, DELETE, ...). **No lo hagas**.

En lugar de esto, utiliza el método `button_to`, que genera un formulario con un botón con soporte nativo para otras peticiones. Usar botones en esta situación tiene varias ventajas:

* Las personas que usan lectores de pantalla sabrán qué va a pasar al pinchar en el botón, pero no tendrán claro qué pasará al pinchar en el enlace.
* Los botones funcionan cuando JavaScipt no ha cargado o está deshabilitado.
* La mayoría de navegadores permiten abrir un enlace en una nueva pestaña; para peticiones que no sean GET, normalmente esto generará un error.

Por la misma razón, utiliza botones en lugar de enlaces para controles que no generan peticiones HTTP sino que modifican el contenido de la página usando JavaScript (por ejemplo, para mostrar u ocultar cierto contenido).

### Utiliza secretos de entidades en vez de secretos de Rails

Rails gestiona la información confidencial mediante el archivo `config/secrets.yml`. Normalmente, las aplicaciones de Rails acceden a los contenidos de este fichero utilizando el método `Rails.application.secrets`.

Consul Democracy, sin embargo, es una [aplicación mulitentidad](../features/multitenancy.md). Con pocas excepciones, la mayoría de los secretos definidos en `config/secrets.yml` permiten distintos valores para distintas entidades. En este caso, utilizar `Tenant.current_secrets` en lugar de `Rails.application.secrets` encontrará el valor correcto para la entidad actual.

### Soporte para navegadores

Intentamos dar soporte al 100% de los navegadores siempre que sea posible. Eso quiere decir que no utilizamos ECMAScript 2015 (o posterior) sino que usamos la sintaxis de ECMAScript 5.

Sin embargo, en ocasiones, especialmente al añadir estilos con CSS, no es viable usar estilos que funcionen en el 100% de los navegadores. En este caso, el objetivo es hacer que la página se vea tal y como se espera en versiones de navegadores que tengan 7 años o menos (aproximadamente el 98% de los navegadores que usa la gente) a la vez que nos aseguramos de que la página no se vea excesivamente mal en el resto de navegadores.

### Soporte para idiomas que se escriben de derecha a izquierda

Para la correcta visualización en idiomas que se escriben de derecha a izquierda (RTL, por sus siglas en inglés), como árabe o hebreo, al escribir CSS, utiliza propiedades como `margin-#{$global-left}` or `margin-#{$global-right}` en lugar de `margin-left` o `margin-right`. Lo mismo con las propiedades de _padding_ u otras propiedades que definen posiciones. La variable `$global-left` tiene el valor `left` (izquierda) en idiomas que se escriben de izquierda a derecha y `right` (derecha) en idiomas que se escriben de derecha a izquierda; la variable `$global-right` toma el valor opuesto a `$global-left`.

Hasta que haya soporte universal en navegadores, no uses propiedades lógicas como `margin-inline`.

### Utiliza unidades rem en lugar de rem-calc

En nuestro código (S)CSS, seguramente encuentres muchos sitios que usan la función `rem-calc` de Foundation para convertir píxeles a rems. Otros sitios usan `rem` directamente para definir rems. Tarde o temprano acabaremos quitando los usos existentes de `rem-calc` así que utiliza `rem` en código nuevo.

### Escribe tests de componentes para escenarios donde no hay interacción

Durante años, estuvimos escribiendo tests de sistema para comprobar el contenido que aparece en una página. Sin embargo, los tests de sistema son muy lentos y, cuando Consul Democracy empezó a crecer, llegamos al punto en que ejecutar todos nuestros tests en una máquina de desarrollo tarda demasiado y dependemos de un sistema de integración continua. Para evitar que los tests tarden aún más, escribe tests de sistema solamente para probar qué sucede cuando el usuario interactúa con la página, como pinchando en enlaces o rellenando formularios. Para probar que, por ejemplo, hay contenido que se renderiza para usuarios verificados pero no para usuarios no verificados, escribe un test de componente.

### No compruebes la base de datos tras un test de sistema

En general, los tests de sistema tienen cuatro partes:

1. Introducir en la base de datos los datos necesarios para el test
2. Arrancar el navegador usando el método `visit`
3. Interactuar con la página de alguna forma
4. Comprobar los resultados de dicha interacción

Cuando compruebes el resultado de la interacción, no compruebes el contenido de la base de datos (por ejemplo, comprobando el resultado de `Proposal.count` después de crear una propuesta) porque podría resultar en una excepción inconsistente de base de datos cuando tanto el proceso que ejecuta los tests como el proceso que arrancó el navegador acceden a la base de datos. En lugar de esto, comprueba que el contenido de la página desde el punto de vista del usuario (por ejemplo, comprueba el número de propuestas que aparecen en el índice de propuestas en vez de comprobar `Proposal.count`).

Comprobar la base de datos en lugar de comprobar el punto de vista del usuario puede llevar a problemas de usabilidad y accesibilidad. Por ejemplo, un botón que modifique la base de datos pero aparentemente no haga nada desde el punto de vista del usuario es un problema de usabilidad que puede detectarse escribiendo tests desde el punto de vista del usuario. Por la misma razón, deberías utilizar textos que aparecen en pantalla en vez de atributos HTML; por ejemplo, en lugar de escribir `fill_in "residence_document_number", with: "12345678Z"`, escribe `fill_in "Document number", with: "12345678Z"`. Esto último comprueba que hay una etiqueta ("label") asociada correctamente con ese campo del formulario, mientras que usar el atributo HTML no lo hace.

### Evita peticiones simultáneas durante tests de sistema

Al usar métodos como `click_link`, asegúrate de que la petición ha terminado antes de generar otra. Conseguir esto en todo momento es muy difícil (nosotros también nos equivocamos en esto a veces), con lo que agradecemos enormemente que tengas esto en mente.

Como ejemplo, este test:

```ruby
scenario "maintains the navigation link" do
  visit admin_root_path
  click_link "Proposals"

  within("#side_menu") { expect(page).to have_link "Proposals" }
end
```

El problema de este test es que la expectativa también se cumple antes de pinchar en el enlace "Proposals". Con este test, lo que probablemente queramos sea que el navegador pinche en el enlace "Propuestas", espere a que la petición termine, y que después el test compruebe el contenido de la página. Sin embargo, eso no es lo que está pasando.

Lo que está pasando es que el navegador pincha en el enlace e inmediatamente el test comprueba el contenido de la página. Si la expectativa se cumple, el test no espera a que la petición termine. Eso quiere decir que la petición puede terminar cuando ya se esté ejecutando otro test distinto y, cuando eso sucede, puede pasar cualquier cosa. Por ejemplo, que se mezclen datos de dos tests diferentes.

Esto a veces resulta en tests que fallan de manera inconsistente (en inglés esto se conoce como "flaky test" o "flaky spec"), es decir, que fallan a veces, pero no siempre. Este tipo de tests supone un gran inconveniente, puesto que, si falla un test durante una _pull request_, vas a tardar un rato en averiguar si el test falla por cambios relacionados con esa _pull request_ o no.

El ejemplo anterior se resolvería con:

```ruby
scenario "maintains the navigation link" do
  visit admin_root_path
  click_link "Proposals"

  within("#side_menu") { expect(page).to have_css "[aria-current]", exact_text: "Proposals" }
end
```

En este caso, la expectativa no se cumple antes de pinchar en el enlace "Proposals", con lo que el test espera a que la petición termine.

Por cierto, es posible que hayas notado que en este test estamos comprobando un atributo HTML, que parece justo lo contrario de lo que recomendábamos en la sección [no compruebes la base de datos tras un test de sistema](#no-compruebes-la-base-de-datos-tras-un-test-de-sistema). Sin embargo, la gente que usa lectores de pantalla sí que oirá la información acerca del atributo `aria-current`, con lo que estamos probando el test desde el punto de vista del usuario.
