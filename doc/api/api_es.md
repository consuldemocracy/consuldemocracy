# Documentación de la API

* [Características](#características)
* [GraphQL](#graphql)
* [Haciendo peticiones a la API](#haciendo-peticiones-a-la-api)
  * [Clientes soportados](#clientes-soportados)
    * [GraphiQL](#graphiql)
    * [Postman](#postman)
    * [Librerías HTTP](#librerías-http)
* [Información disponible](#información-disponible)
* [Ejemplos de consultas](#ejemplos-de-consultas)
  * [Recuperar un único elemento de una colección](#recuperar-un-único-elemento-de-una-colección)
  * [Recuperar una colección completa](#recuperar-una-colección-completa)
    * [Paginación](#paginación)
  * [Acceder a varios recursos en una única petición](#acceder-a-varios-recursos-en-una-única-petición)
* [Limitaciones de seguridad](#limitaciones-de-seguridad)
  * [Ejemplo de consulta demasiado profunda](#ejemplo-de-consulta-demasiado-profunda)
  * [Ejemplo de consulta demasiado compleja](#ejemplo-de-consulta-demasiado-compleja)
* [Ejemplos de código](#ejemplos-de-código)

## Características

* API de sólo lectura
* Acceso público, sin autenticación
* Usa GraphQL por debajo
  * El tamaño máximo (y por defecto) de página está establecido a 25
  * La profundiad máxima de las consultas es de 8 niveles
  * Como máximo se pueden solicitar 2 colecciones en una misma consulta
  * Soporte para peticiones GET (consulta dentro del *query string*) y POST (consulta dentro del *body*, como `application/json` o `application/graphql`).

## GraphQL

La API de CONSUL utiliza GraphQL [http://graphql.org](https://graphql.org), en concreto la [implementación en Ruby](http://graphql-ruby.org/). Si no estás familiarizado con este tipo de APIs, es recomendable investigar un poco sobre GraphQL previamente.

Una de las caracteríticas que diferencian una API REST de una GraphQL es que con esta última es posible construir *consultas personalizadas*, de forma que el servidor nos devuelva únicamente la información en la que estamos interesados.

Las consultas en GraphQL están escritas siguiendo un estándar que presenta ciertas similitudes con el formato JSON, por ejemplo:

```
{
  proposal(id: 1) {
    id,
    title,
    public_author {
      id,
      username
    }
  }
}
```

Las respuestas son en formato JSON:

```json
{
  "data": {
    "proposal": {
      "id": 1,
      "title": "Hacer las calles del centro de Madrid peatonales",
      "public_author": {
        "id": 2,
        "username": "electrocronopio"
      }
    }
  }
}
```

## Haciendo peticiones a la API

Siguiendo las [directrices oficiales](http://graphql.org/learn/serving-over-http/), la API de CONSUL soporta los siguientes tipos de peticiones:

* Peticiones GET, con la consulta dentro del *query string*.
* Peticiones POST
  * Con la consulta dentro del *body*, con `Content-Type: application/json`
  * Con la consulta dentro del *body*, con `Content-Type: application/graphql`

### Clientes soportados

Al ser una API que funciona a través de HTTP, cualquier herramienta capaz de realizar este tipo de peticiones resulta válida.

Esta sección contiene unos pequeños ejemplos sobre cómo hacer las peticiones a través de:

* GraphiQL
* Extensiones de Chrome como Postman
* Cualquier librería HTTP

#### GraphiQL

[GraphiQL](https://github.com/graphql/graphiql) es una interfaz de navegador para realizar consultas a una API GraphQL, así como una fuente adicional de documentación. Está desplegada en la ruta `/graphiql` y es la mejor forma de familiarizarse una API basada en GraphQL.

![GraphiQL](../imgs/graphiql.png)

Tiene tres paneles principales:

* En el panel de la izquierda se escribe la consulta a realizar.
* El panel central muestra el resultado de la petición.
* El panel derecho (ocultable) contiene una documentación autogenerada a partir de la información expuesta en la API.

#### Postman

Ejemplo de petición `GET`, con la consulta como parte del *query string*:

![Postman GET](../imgs/graphql-postman-get.png)

Ejemplo de petición `POST`, con la consulta como parte del *body* y codificada como `application/json`:

![Postman POST](../imgs/graphql-postman-post-headers.png)

La consulta debe estar ubicada en un documento JSON válido, como valor de la clave `"query"`:

![Postman POST](../imgs/graphql-postman-post-body.png)

#### Librerías HTTP

Por supuesto es posible utilizar cualquier librería HTTP de lenguajes de programación.

**IMPORTANTE**: Debido a los protocolos de seguridad de los servidores del Ayuntamiento de Madrid, es necesario incluir un *User Agent* perteneciente a un navegador para que la petición no sea descartada. Por ejemplo:

`User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36`

## Información disponible

El fichero [config/api.yml](../../config/api.yml) contiene una lista completa de los modelos (y sus campos) que están expuestos actualmente en la API.

La lista de modelos es la siguiente:

| Modelo                  | Descripción                  |
| ----------------------- | ---------------------------- |
| `User`                  | Usuarios                     |
| `Debate`                | Debates                      |
| `Proposal`              | Propuestas                   |
| `Comment`               | Comentarios en debates, propuestas y otros comentarios |
| `Geozone`               | Geozonas (distritos)         |
| `ProposalNotification`  | Notificaciones asociadas a propuestas |
| `Tag`                   | Tags en debates y propuestas |
| `Vote`                  | Información sobre votos      |

## Ejemplos de consultas

### Recuperar un único elemento de una colección

```
{
  proposal(id: 2) {
    id,
    title,
    comments_count
  }
}
```

Respuesta:

```json
{
  "data": {
    "proposal": {
      "id": 2,
      "title": "Crear una zona cercada para perros en Las Tablas",
      "comments_count": 10
    }
  }
}
```

### Recuperar una colección completa

```
{
  proposals {
    edges {
      node {
        title
      }
    }
  }
}
```

Respuesta:

```json
{
  "data": {
    "proposals": {
      "edges": [
        {
          "node": {
            "title": "ELIMINACION DE ZONA APARCAMIENTO EXCLUSIVO FUNCIONARIOS EN MADRID"
          }
        },
        {
          "node": {
            "title": "iluminación de zonas deportivas"
          }
        }
      ]
    }
  }
}
```

#### Paginación

Actualmente el número máximo (y por defecto) de elementos que se devuelven en cada página está establecido a 25. Para poder navegar por las distintas páginas es necesario solicitar además información relativa al `endCursor`:

```
{
  proposals(first: 25) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        title
      }
    }
  }
}

```

La respuesta:

```json
{
  "data": {
    "proposals": {
      "pageInfo": {
        "hasNextPage": true,
        "endCursor": "NQ=="
      },
      "edges": [
        # ...
      ]
    }
  }
}
```

Para recuperar la siguiente página, hay que pasar como parámetro el cursor recibido en la petición anterior, y así sucesivamente:

```
{
  proposals(first: 25, after: "NQ==") {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        title
      }
    }
  }
}
```

### Acceder a varios recursos en una única petición

Esta consulta solicita información relativa a varios modelos distintos en una única peticion: `Proposal`, `User`, `Geozone` y `Comment`:

```
{
  proposal(id: 15262) {
    id,
    title,
    public_author {
      username
    },
    geozone {
      name
    },
    comments(first: 2) {
      edges {
        node {
          body
        }
      }
    }
  }
}
```

## Limitaciones de seguridad

Permitir que un cliente personalice las consultas supone un factor de riesgo importante. Si se permitiesen consultas demasiado complejas, sería posible realizar un ataque DoS contra el servidor.

Existen tres mecanismos principales para evitar este tipo de abusos:

* Paginación de resultados
* Limitar la profundidad máxima de las consultas
* Limitar la cantidad de información que es posible solicitar en una consulta

### Ejemplo de consulta demasiado profunda

La profundidad máxima de las consultas está actualmente establecida en 8. Consultas más profundas (como la siguiente), serán rechazadas:

```
{
  user(id: 1) {
    public_proposals {
      edges {
        node {
          id,
          title,
          comments {
            edges {
              node {
                body,
                public_author {
                  username
                }
              }
            }
          }
        }
      }
    }
  }
}
```

La respuesta obtenida tendrá el siguiente aspecto:

```json
{
  "errors": [
    {
      "message": "Query has depth of 9, which exceeds max depth of 8"
    }
  ]
}
```

### Ejemplo de consulta demasiado compleja

El principal factor de riesgo se da cuando se solicitan varias colecciones de recursos en una misma consulta. El máximo número de colecciones que pueden aparecer en una misma consulta está limitado a 2. La siguiente consulta solicita información de las colecciónes `users`, `debates` y `proposals`, así que será rechazada:

```
{
  users {
    edges {
      node {
        public_debates {
          edges {
            node {
              title
            }
          }
        },
        public_proposals {
          edges {
            node {
              title
            }
          }
        }
      }
    }
  }
}
```

La respuesta obtenida tendrá el siguiente aspecto:

```json
{
  "errors": [
    {
      "message": "Query has complexity of 3008, which exceeds max complexity of 2500"
    },
    {
      "message": "Query has complexity of 3008, which exceeds max complexity of 2500"
    },
    {
      "message": "Query has complexity of 3008, which exceeds max complexity of 2500"
    }
  ]
}
```

No obstante sí que es posible solicitar información perteneciente a más de dos modelos en una única consulta, siempre y cuando no se intente acceder a la colección completa. Por ejemplo, la siguiente consulta que accede a los modelos `User`, `Proposal` y `Geozone` es válida:

```
{
  user(id: 468501) {
    id
    public_proposals {
      edges {
        node {
          title
          geozone {
            name
          }
        }
      }
    }
  }
}
```

La respuesta:

```json
{
  "data": {
    "user": {
      "id": 468501,
      "public_proposals": {
        "edges": [
          {
            "node": {
              "title": "Empadronamiento necesario para la admisión en GoFit Vallehermoso",
              "geozone": {
                "name": "Chamberí"
              }
            }
          }
        ]
      }
    }
  }
}
```

## Ejemplos de código

El directorio [doc/api/examples](examples) contiene ejemplos de código para acceder a la API.