# OAuth

Puedes configurar la autenticación con servicios externos usando OAuth, por ahora están soportados Twitter, Facebook y Google.

## 1. Crea una aplicación en la plataforma

Para cada plataforma, sigue las instrucciones en la sección de desarrolladores de su página web.

## 2. Establece la url de tu CONSUL

Te preguntarán por la URL de autenticación de tu instalación de CONSUL, y como podrás comprobar corriendo la tarea `rake routes` en tu repositorio local:

```bash
user_omniauth_authorize GET|POST /users/auth/:provider(.:format)          users/omniauth_callbacks#passthru {:provider=>/twitter|facebook|google_oauth2/}
```

Por ejemplo para facebook la URL sería `yourdomain.com/users/auth/facebook/callback`

## 3. Establece la clave y secreto

Cuando completes el registro de la aplicación en su plataforma te darán un _key_ y _secret_, estos deben ser almacenados en tu fichero `config/secrets.yml`:

```text
  twitter_key: ""
  twitter_secret: ""
  facebook_key: ""
  facebook_secret: ""
  google_oauth2_key: ""
  google_oauth2_secret: ""
```

_NOTA:_ Además en el caso de Google, verifica que las APIs de _Contacts API_ y _Google+ API_ están habilitadas para tu aplicación en su plataforma.

