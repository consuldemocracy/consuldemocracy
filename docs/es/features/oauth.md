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
  oidc_client_id: "tu-id-de-cliente-oidc"
  oidc_client_secret: "tu-secreto-de-cliente-oidc"
  oidc_issuer: "https://tu-proveedor-oidc.com"
```
