# Configure connection to the Census

The objective of this service is to be able to configure the connection with a census through the administration panel without having to modify the application code.

It should be noted that to properly configure this connection, a technical profile that knows the WebService with which we want to connect will be required.

## Enabling the feature

To enable the feature you have to access from the administration panel to the **Settings > Global settings > Features** section and enable the **Configure connection to the remote census (SOAP)** module.

## Configuration

Once the feature is activated, we can access the section **Settings > Global settings** and click on the tab **Remote Census Configuration** to be able to configure the connection with the census.

The information to be filled in is divided into three sections:

### General Information

- **Endpoint**: Host name where the census service is available (wsdl).

### Request data

In this section we will fill in all the necessary fields to be able to make a request to verify a user through a census.

To help you understand how to fill in each of the fields, we will rely on a supposed WebService that receives a method called  `:get_habita_datos` with the following structure:

```ruby
{
  request: {
    codigo_institucion: 12,        # Static Value
    codigo_portal:      5,         # Static Value
    codigo_usuario:     10,        # Static Value
    documento:          12345678Z, # Dynamic value related to Document Number
    tipo_documento:     1,         # Dynamic value related to Document Type
    nivel:              3          # Static Value
  }
}
```

Required fields for the request:

- **Request method name**: Request method name accepted by the census WebService.

  ![Request data - Request method name is filled in with get_habita_datos](../../img/remote_census/request-data-method-name-en.png)
- **Request Structure**: Structure of the request received by the WebService of the census. The _static_ values of this request should be reported. The _dynamic_ values related to Document Type, Document Number, Date of Birth and Postal Code should be filled with _null_ value.

  ![Request data - Structure](../../img/remote_census/request-data-structure-en.png)

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

- **Path for document type**: Path in the request structure that sends the Document Type.

  *NOTE: DO NOT FILL IN if the WebService does not require the Document Type to verify a user.*

  ![Request data - Path for document type is filled in with request.tipo_documento](../../img/remote_census/request-data-path-document-type-en.png)

- **Path for document number**: Path in the request structure that sends the Document Number.

  *NOTE: DO NOT FILL IN if the WebService does not require the Document Number to verify a user.*

  ![Request data - Path for document number is filled in with request.documento](../../img/remote_census/request-data-path-document-number-en.png)
- **Path for date of birth**: Path in the request structure that sends the Date of Birth.

  *NOTE: DO NOT FILL IN if the WebService does not require the Date of Birth to verify a user.*

  In *this example*, we will leave it blank, since it is not necessary to send the date of birth to verify a user.

  ![Request data - Path for date of birth is left blank](../../img/remote_census/request-data-path-date-of-birth-en.png)
- **Path for Postal Code**: Path in the request structure that sends the Postal Code.

  *NOTE: DO NOT FILL IN if the WebService does not require the Postal Code to verify a user.*

  In *this example*, we will leave it blank, since it is not necessary to send the postal code to verify a user.

  ![Request data - Path for postal code is left blank](../../img/remote_census/request-data-path-postal-code-en.png)

### Response data

In this section we will configure all the necessary fields to be able to receive the answer of the WebService and to verify a user in the application.

As in the previous section, we will define an example answer to help you understand how to fill in each of the fields in this section.

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

Required fields to parse the response:

- **Path for Date of Birth**: Path in the response structure containing the user's Date of Birth.

  ![Response data - Path for date of birth is filled in with get_habita_datos_response.get_habita_datos_return.datos_habitante.item.fecha_nacimiento_string](../../img/remote_census/response-data-path-date-of-birth-en.png)
- **Path for Postal Code**: Path in the response structure containing the user's Postal Code.

  ![Response data - Path for postal code is filled in with get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_postal](../../img/remote_census/response-data-path-postal-code-en.png)
- **Path for District**: Path in the response structure containing the user's District.

  ![Response data - Path for district is filled in with get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_distrito](../../img/remote_census/response-data-path-district-en.png)
- **Path for Gender**: Path in the response structure containing the user's Gender.

  ![Response data - Path for gender is filled in with get_habita_datos_response.get_habita_datos_return.datos_habitante.item.descripcion_sexo](../../img/remote_census/response-data-path-gender-en.png)
- **Path for Name**: Path in the response structure containing the user's Name.

  ![Response data - Path for name is filled in with get_habita_datos_response.get_habita_datos_return.datos_habitante.item.nombre](../../img/remote_census/response-data-path-name-en.png)
- **Path for the Last Name**: Path in the response structure containing the user's Last Name.

  ![Response data - Path for last name is filled in with get_habita_datos_response.get_habita_datos_return.datos_habitante.item.apellido1](../../img/remote_census/response-data-path-last-name-en.png)
- **Path for detecting a valid response**: Path in the response structure that must be filled in in valid responses.

  ![Response data - Path for valid response is filled in with get_habita_datos_response.get_habita_datos_return.datos_habitante.item](../../img/remote_census/response-data-path-valid-response-en.png)

  Once the general data, the necessary fields of the request and **all** fields to validate the response have been correctly filled in, the application will be able to verify any user through the defined WebService.
