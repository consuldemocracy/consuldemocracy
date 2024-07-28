# OAuth

Puedes configurar la autenticación con servicios externos usando OAuth, por ahora están soportados Twitter, Facebook y Google.

## 1. Crea una aplicación en la plataforma

Para cada plataforma, sigue las instrucciones en la sección de desarrolladores de su página web.

## 2. Establece la url de tu Consul Democracy

Te preguntarán por la URL de autenticación de tu instalación de Consul Democracy, y como podrás comprobar corriendo la tarea `rake routes` en tu repositorio local:

```bash
user_omniauth_authorize GET|POST /users/auth/:provider(.:format)          users/omniauth_callbacks#passthru {:provider=>/twitter|facebook|google_oauth2/}
```

Por ejemplo para facebook la URL sería `yourdomain.com/users/auth/facebook/callback`

## 3. Establece la clave y secreto

Cuando completes el registro de la aplicación en su plataforma te darán un *key* y *secret*, estos deben ser almacenados en tu fichero `config/secrets.yml`:

```yml
  twitter_key: ""
  twitter_secret: ""
  facebook_key: ""
  facebook_secret: ""
  google_oauth2_key: ""
  google_oauth2_secret: ""
```

*NOTA:* Además en el caso de Google, verifica que las APIs de *Contacts API* y *Google+ API* están habilitadas para tu aplicación en su plataforma.
