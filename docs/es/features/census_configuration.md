# Configurar conexión con el Censo

Este servicio tiene como objetivo poder configurar la conexión con un censo a través del panel de administración sin necesidad de modificar el código de la aplicación.

Cabe destacar que para configurar correctamente esta conexión se requerirá de un perfil técnico que conozca el WebService con el cual queremos conectarnos.

## Activar la funcionalidad

Para activar la funcionalidad hay que acceder desde el panel de administración a la sección **Configuración > Configuración global > Funcionalidades** y activar el módulo de **Configurar conexión al censo remoto (SOAP)**.

## Configuración

Una vez activada la funcionalidad, podremos acceder a la sección **Configuración > Configuración global** y clicar en la pestaña **Configuración del Censo Remoto** para poder configurar la conexión con el censo.

La información a rellenar esta dividida en tres apartados:

### Información General

- **Endpoint**: Nombre del host donde se encuentra el servicio del Censo con el que queremos conectarnos (wsdl).

### Datos de la Petición

En esta sección rellenaremos todos los campos necesarios para poder realizar una petición para verificar un usuario contra un censo.

Para ayudar a entender cómo rellenar cada uno de los campos, nos basaremos en un supuesto WebService que recibe un método llamado `:get_habita_datos` con la siguiente estructura:

```ruby
{
  request: {
    codigo_institucion: 12,        #Valor estático
    codigo_portal:      5,         #Valor estático
    codigo_usuario:     10,        #Valor estático
    documento:          12345678Z, #Valor dinámico relacionado con Número de Documento
    tipo_documento:     1,         #Valor dinámico relacionado con Tipo de Documento
    codigo_idioma:      102,       #Valor estático
    nivel:              3          #Valor estático
  }
}
```

Campos necesarios para la petición:

- **Nombre del método de la petición**: Nombre del método que acepta el WebService del censo.

  ![Datos de la petición - Nombre del método de la petición se rellena con get_habita_datos](../../img/remote_census/request-data-method-name-es.png)
- **Estructura de la petición**: Estructura de la petición que recibe el WebService del censo. Los valores _fijos_ de esta petición deberán rellenarse. Los valores _dinámicos_ relacionados con Tipo de Documento, Número de Documento, Fecha de Nacimiento y Código Postal deberán dejarse con valor _null_.

  ![Datos de la petición - Estructura](../../img/remote_census/request-data-structure-es.png)

  ```ruby
  {
    request: {
      codigo_institucion: 12,        # Since it is a "fixed" value in all requests, we fill in it.
      codigo_portal:      5,         # Since it is a "fixed" value in all requests, we fill in it.
      codigo_usuario:     10,        # Since it is a "fixed" value in all requests, we fill in it.
      documento:          null,      # Since it is a value related to Document Type, Document Number, Date of Birth or Postal Code, we fill it in with a null value
      tipo_documento:     null,      # Since it is a value related to Document Type, Document Number, Date of Birth or Postal Code, we fill it in with a null value
      codigo_idioma:      102,       # Since it is a "fixed" value in all requests, we fill in it.
      nivel:              3          # Since it is a "fixed" value in all requests, we fill in it.
    }
  }
  ```

- **Ruta para Tipo de Documento**: Ruta donde se encuentra el campo en la estructura de la petición que envía el Tipo de Documento.

  *NOTA: NO RELLENAR en caso de que el WebService no requiera el Tipo de Documento para verificar un usuario.*

  ![Datos de la petición - Ruta para tipo de documento se rellena con request.tipo_documento](../../img/remote_census/request-data-path-document-type-es.png)
- **Ruta para Número de Documento**: Ruta donde se encuentra el campo en la estructura de la petición que envía el Número de Documento.

  *NOTA: NO RELLENAR en caso de que el WebService no requiera el Número de Documento para verificar un usuario.*

  ![Datos de la petición - Ruta para número de documento se rellena con request.documento](../../img/remote_census/request-data-path-document-number-es.png)
- **Ruta para Fecha de Nacimiento**: Ruta donde se encuentra el campo en la estructura de la petición que envía la Fecha de Nacimiento.

  *NOTA: NO RELLENAR en caso de que el WebService no requiera la Fecha de Nacimiento para verificar un usuario.*

  En el caso del *Ejemplo* lo dejaríamos en blanco, ya que no se necesita enviar la fecha de nacimiento para verificar a un usuario.

  ![Datos de la petición - Ruta para fecha de nacimiento se deja en blanco](../../img/remote_census/request-data-path-date-of-birth-es.png)
- **Ruta para Código Postal**: Ruta donde se encuentra el campo en la estructura de la petición que envía el Código Postal.

  *NOTA: NO RELLENAR en caso de que el WebService no requiera el Código Postal para verificar un usuario.*

  En el caso del *Ejemplo* lo dejaríamos en blanco, ya que no se necesita enviar el código postal para verificar a un usuario.

  ![Datos de la petición - Ruta para código postal se deja en blanco](../../img/remote_census/request-data-path-postal-code-es.png)

### Datos de la respuesta

En esta sección configuraremos todos los campos necesarios para poder recibir la respuesta del WebService y verificar a un usuario en la aplicación.

Al igual que en el apartado anterior, definiremos un ejemplo de respuesta para ayudar a entender cómo rellenar cada uno de los campos de esta sección.

```ruby
{
  get_habita_datos_response: {
    get_habita_datos_return: {
      datos_habitante: {
        item: {
          fecha_nacimiento_string: "31-12-1980",
          identificador_documento: "12345678Z",
          descripcion_sexo: "Varón",
          nombre: "José",
          apellido1: "García"
        }
      },
      datos_vivienda: {
        item: {
          codigo_postal: "28013",
          codigo_distrito: "01"
        }
      }
    }
  }
}
```

Campos necesarios para parsear la respuesta:

- **Ruta para la Fecha de Nacimiento**: Ruta de la respuesta donde se encuentra la Fecha de Nacimiento.

  ![Datos de la respuesta - Ruta para la fecha de nacimiento se rellena con get_habita_datos_response.get_habita_datos_return.datos_habitante.item.fecha_nacimiento_string](../../img/remote_census/response-data-path-date-of-birth-es.png)
- **Ruta para el Código Postal**: Ruta de la respuesta donde se encuentra el Código Postal.

  ![Datos de la respuesta - Ruta para el código postal se rellena con get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_postal](../../img/remote_census/response-data-path-postal-code-es.png)
- **Ruta para el Distrito**: Ruta de la respuesta donde se encuentra el Distrito.

  ![Datos de la respuesta - Ruta para el distrito se rellena con get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_distrito](../../img/remote_census/response-data-path-district-es.png)
- **Ruta para el Género**: Ruta de la respuesta donde se encuentra el Género.

  ![Datos de la respuesta - Ruta para el género se rellena con get_habita_datos_response.get_habita_datos_return.datos_habitante.item.descripcion_sexo](../../img/remote_census/response-data-path-gender-es.png)
- **Ruta para el Nombre**: Ruta de la respuesta donde se encuentra el Nombre.

  ![Datos de la respuesta - Ruta para el nombre se rellena con get_habita_datos_response.get_habita_datos_return.datos_habitante.item.nombre](../../img/remote_census/response-data-path-name-es.png)
- **Ruta para el Apellido**: Ruta de la respuesta donde se encuentra el Apellido

  ![Datos de la respuesta - Ruta para el apellido se rellena con get_habita_datos_response.get_habita_datos_return.datos_habitante.item.apellido1](../../img/remote_census/response-data-path-last-name-es.png)
- **Ruta para detectar una respuesta válida**: Ruta de la respuesta que tiene que venir rellenada para considerarse una respuesta válida.

  ![Datos de la respuesta - Ruta para detectar una respuesta válida se rellena con get_habita_datos_response.get_habita_datos_return.datos_habitante.item](../../img/remote_census/response-data-path-valid-response-es.png)

  Una vez rellenados correctamente los datos generales, los campos necesarios de la petición y **todos** los campos para validar la respuesta, la aplicación podrá verificar cualquier usuario contra el WebService definido.
