# Autenticación con servicios externos (OAuth)

Puedes configurar la autenticación con servicios externos usando OAuth. Actualmente, se pueden utilizar Twitter, Facebook, Google, Wordpress, SAML y OpenID Connect (OIDC).

## 1. Crea una aplicación en la plataforma

Para Twitter, Facebook, Google y Wordpress, sigue las instrucciones en la sección de desarrolladores de su página web. Para SAML, tendrás que configurar tu propio proveedor de identidad (IdP). Para OIDC, tendrás que registrar tu aplicación con un proveedor de OpenID Connect.

## 2. Establece la URL de autenticación de tu instalación de Consul Democracy

Te preguntarán por la URL de autenticación de tu instalación de Consul Democracy, y como podrás comprobar corriendo la tarea `rails routes | grep omniauth` en tu repositorio local:

```bash
user_twitter_omniauth_authorize GET|POST /users/auth/twitter(.:format) users/omniauth_callbacks#passthru
user_twitter_omniauth_callback GET|POST /users/auth/twitter/callback(.:format) users/omniauth_callbacks#twitter
user_facebook_omniauth_authorize GET|POST /users/auth/facebook(.:format) users/omniauth_callbacks#passthru
user_facebook_omniauth_callback GET|POST /users/auth/facebook/callback(.:format) users/omniauth_callbacks#facebook
user_google_oauth2_omniauth_authorize GET|POST /users/auth/google_oauth2(.:format) users/omniauth_callbacks#passthru
user_google_oauth2_omniauth_callback GET|POST /users/auth/google_oauth2/callback(.:format) users/omniauth_callbacks#google_oauth2
user_wordpress_oauth2_omniauth_authorize GET|POST /users/auth/wordpress_oauth2(.:format) users/omniauth_callbacks#passthru
user_wordpress_oauth2_omniauth_callback GET|POST /users/auth/wordpress_oauth2/callback(.:format) users/omniauth_callbacks#wordpress_oauth2
user_saml_omniauth_authorize GET|POST /users/auth/saml(.:format) users/omniauth_callbacks#passthru
user_saml_omniauth_callback GET|POST /users/auth/saml/callback(.:format) users/omniauth_callbacks#saml
user_oidc_omniauth_authorize GET|POST /users/auth/oidc(.:format) users/omniauth_callbacks#passthru
user_oidc_omniauth_callback GET|POST /users/auth/oidc/callback(.:format) users/omniauth_callbacks#oidc
```

Por ejemplo para Facebook la URL sería `yourdomain.com/users/auth/facebook/callback`.

## 3. Establece la clave y secreto

Cuando completes el registro de la aplicación en su plataforma te darán un *key* y *secret*, estos deben ser almacenados en tu fichero `config/secrets.yml`:

```yml
  twitter_key: ""
  twitter_secret: ""
  facebook_key: ""
  facebook_secret: ""
  google_oauth2_key: ""
  google_oauth2_secret: ""
  wordpress_oauth2_key: ""
  wordpress_oauth2_secret: ""
  wordpress_oauth2_site: ""
  saml_sp_entity_id: "https://tusp.org/entityid"
  saml_idp_metadata_url: "https://tuidp.org/api/saml/metadata"
  saml_idp_sso_service_url: "https://tuidp.org/api/saml/sso"
  saml_additional_settings: {}
  oidc_client_id: "tu-id-de-cliente-oidc"
  oidc_client_secret: "tu-secreto-de-cliente-oidc"
  oidc_issuer: "https://tu-proveedor-oidc.com"
```

### Acerca de `saml_additional_settings`

El campo `saml_additional_settings` es opcional. Permite enviar parámetros adicionales en la petición SAML al proveedor de identidad (IdP) al iniciar la autenticación.

La mayoría de configuraciones funcionan sin él, pero algunos IdP exigen campos como identificadores de la entidad, RelayState o contexto de autenticación.

**Ejemplo:**

```yml
saml_additional_settings:
  RelayState: "https://tusp.org/panel"
  authn_context: "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
  organization: "ejemplo-org"
```

* **RelayState**: Redirige al usuario a una página concreta tras iniciar sesión correctamente.
* **authn_context**: Solicita un método de autenticación concreto al IdP.
* **organization**: Ejemplo de configuración personalizada (útil si el IdP necesita información de la entidad u organización).

Si no necesitas configuraciones adicionales, puedes dejarlo vacío:

```yml
saml_additional_settings: {}
```

### Acerca de `certificate` y `private_key`

Estas dos configuraciones permiten que Consul Democracy firme las `AuthnRequests` SAML y descifre las respuestas cifradas del IdP. Son opcionales: si los dejas vacíos, la estrategia SAML se configura sin par de claves del proveedor de servicio.

#### Paso 1: Generar una clave privada

```bash
openssl genrsa -out sp-private.key 2048
```

#### Paso 2: Generar un certificado autofirmado con esa clave

```bash
openssl req -new -x509 -key sp-private.key -out sp-public.crt -days 3650 -subj "/CN=nombre-de-tu-aplicación"
```

#### Paso 3: Copiar el contenido PEM en `secrets.yml`

Pega el contenido de cada fichero PEM (incluidas las líneas `BEGIN`/`END`) como un bloque YAML con el indicador `|` para conservar los saltos de línea. De manera opcional, también puedes añadir opciones de seguridad adicionales.

```yml
saml_additional_settings:
  certificate: |
    -----BEGIN CERTIFICATE-----
    MIID...
    -----END CERTIFICATE-----
  private_key: |
    -----BEGIN PRIVATE KEY-----
    MIIE...
    -----END PRIVATE KEY-----
  security: # Opcional
    logout_requests_signed: true # Opcional
```

* `sp-private.key`: el contenido va en `private_key`.
* `sp-public.crt`: el contenido va en `certificate`.
