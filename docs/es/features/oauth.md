# OAuth

Puedes configurar la autenticación con servicios externos usando OAuth, actualmente se pueden utilizar Twitter, Facebook, Google y Wordpress.

## 1. Crea una aplicación en la plataforma

Para cada plataforma, sigue las instrucciones en la sección de desarrolladores de su página web.

## 2. Establece la URL de autenticación de tu instalación de Consul Democracy

Te preguntarán por la URL de autenticación de tu instalación de Consul Democracy, y como podrás comprobar corriendo la tarea `rails routes |grep omniauth` en tu repositorio local:

```bash
  user_twitter_omniauth_authorize GET|POST /users/auth/twitter(.:format) users/omniauth_callbacks#passthru
  user_twitter_omniauth_callback GET|POST /users/auth/twitter/callback(.:format) users/omniauth_callbacks#twitter
  user_facebook_omniauth_authorize GET|POST /users/auth/facebook(.:format) users/omniauth_callbacks#passthru
  user_facebook_omniauth_callback GET|POST /users/auth/facebook/callback(.:format) users/omniauth_callbacks#facebook
  user_google_oauth2_omniauth_authorize GET|POST /users/auth/google_oauth2(.:format) users omniauth_callbacks#passthru
  user_google_oauth2_omniauth_callback GET|POST /users/auth/google_oauth2/callback(.:format) users/omniauth_callbacks#google_oauth2
  user_wordpress_oauth2_omniauth_authorize GET|POST /users/auth/wordpress_oauth2(.:format) users/omniauth_callbacks#passthru
  user_wordpress_oauth2_omniauth_callback GET|POST /users/auth/wordpress_oauth2/callback(.:format) users/omniauth_callbacks#wordpress_oauth2
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
```
