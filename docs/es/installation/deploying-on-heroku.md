# Instalación en Heroku

## Instalación manual

Este tutorial asume que ya has conseguido clonar Consul Democracy en tu máquina y conseguir que funcione.

1. En primer lugar, necesitas crear una cuenta en [Heroku](https://www.heroku.com) si no lo has hecho ya.
2. Instala [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) e inicia sesión con:

  ```bash
  heroku login
  ```

3. Accede a tu repositorio de Consul Democracy y crea una instancia

  ```bash
  cd consuldemocracy
  heroku create your-app-name
  ```

  Puedes añadir `--region eu` si quieres utilizar servidores europeos en lugar de los estadounidenses.

  Si _your-app-name_ no existe aún, Heroku creará tu aplicación.

4. Crea la base de datos con

  ```bash
  heroku addons:create heroku-postgresql
  ```

  Ahora deberías tener acceso a una base de datos Postgres vacía cuya dirección se guardó automáticamente como una variable de entorno llamada _DATABASE\_URL_. Consul Democracy se conectará automáticamente a ella durante la instalación.

5. **(No es necesario)** Crea un archivo con el nombre _heroku.yml_ en la raíz del proyecto y añade el siguiente código

  ```yml
  build:
    languages:
      - ruby
    packages:
      - imagemagick
  run:
    web: bundle exec rails server -e ${RAILS_ENV:-production}
  ```

6. Ahora, genera una clave secreta y guárdala en la variable de entorno SECRET\_KEY\_BASE de la siguinte manera

  ```bash
  heroku config:set SECRET_KEY_BASE=$(rails secret)
  ```

  Añade también la dirección de tu servidor:

  ```bash
  heroku config:set SERVER_NAME=myserver.address.com
  ```

  Es necesario que la aplicación sepa dónde se almacenan las variables de configuración añadiendo un enlace a las variables de entorno en _config/secrets.yml_

  ```yml
  production:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    server_name: <%= ENV["SERVER_NAME"] %>
  ```

  y añade este archivo en el repositorio comentando la línea correspondiente en el _.gitignore_.

  ```gitignore
  #/config/secrets.yml
  ```

  **¡Recuerda no añadir el archivo si tienes información sensible en él!**

7. Ahora ya puedes subir tu aplicación utilizando:

  ```bash
  git push heroku your-branch:master
  ```

8. No funcionará de inmediato porque la base de datos no contiene las tablas necesarias. Para crearlas, ejecuta

  ```bash
  heroku run rake db:migrate
  heroku run rake db:seed
  ```

  Si quieres añadir los datos de prueba en la base de datos, mueve `gem 'faker', '~> 1.8.7'` fuera del `group :development` y ejecuta:

  ```bash
  heroku config:set DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true
  heroku config:set DATABASE_CLEANER_ALLOW_PRODUCTION=true
  heroku run rake db:dev_seed
  ```

9. Ahora tu aplicación debería estar ya opertaiva. Puedes abrirla con

  ```bash
  heroku open
  ```

  También puedes arrancar la consola en heroku utilizando

  ```bash
  heroku console --app your-app-name
  ```

10. Heroku no permite guardar imágenes o documentos en sus servidores, por lo que es necesario configurar un nuevo espacio de almacenamiento.

  Consulta [nuestra guía de S3](./using-aws-s3-as-storage.md) para más detalles sobre la configuración de Paperclip con S3.

### Configurar Sendgrid

Añade el complemento (add-on) de SendGrid en Heroku. Esto creará una cuenta de SendGrid para la aplicación con `ENV["SENDGRID_USERNAME"]` y `ENV["SENDGRID_PASSWORD"]`.

Añade el siguiente código a `config/secrets.yml`, en la sección `production:`:

```
  mailer_delivery_method: :smtp
  smtp_settings:
    :address: "smtp.sendgrid.net"
    :port: 587
    :domain: "heroku.com"
    :user_name: ENV["SENDGRID_USERNAME"]
    :password: ENV["SENDGRID_PASSWORD"]
    :authentication: "plain"
    :enable_starttls_auto: true
```

Importante: Activa un "worker dyno" para que se envíen los correos electrónicos.

### Opcional (pero recomendado)

### Instalar rails\_12factor y especificar la versión de Ruby

**Instalar rails\_12factor sólo es útil si utilizas una versión de Consul Democracy anterior a la 1.0.0. La última versión utiliza Rails 5 que ya incluye los cambios.**

Como nos recomienda Heroku, puedes añadir la gema rails\_12factor y especificar la versión de Ruby a utilizar. Puedes hacerlo añadiendo:

```ruby
gem 'rails_12factor'

ruby 'x.y.z'
```

en el archivo _Gemfile\_custom_, donde `x.y.z` es la versión definida en el fichero `.ruby-version` del repositorio de Consul Democracy. No olvides ejecutar

```bash
bundle install
```

para generar el _Gemfile.lock_ antes de añadir los cambios y subirlos al servidor.

### Utilizar Puma como servidor web

Heroku recomienda utilizar Puma para mejorar el [rendimiento](http://blog.scoutapp.com/articles/2017/02/10/which-ruby-app-server-is-right-for-you) de la aplicación.

Si quieres permitir más concurrencia, descomenta la siguiente linea:

```ruby
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
```

Puedes encontrar una explicación para diferentes configuraciones en el siguiente [tutorial de Heroku](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server).

Por último hay que cambiar la tarea _web_ para usar Puma cambiándola en el archivo _heroku.yml_ con el siguiente código:

```yml
web: bundle exec puma -C config/puma.rb
```

### Añadir variables de configuración desde el panel de control

Las versiones gratuita y hobby de Heroku no son suficientes para ejecutar una aplicación como Consul Democracy. Para optimizar el tiempo de respuesta y asegurarte de que la aplicación no se quede sin memoria, puedes [cambiar el número de "workers" e hilos](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#workers) que utiliza Puma.

La configuración recomendada es un "worker" y tres hilos. Puedes configurarlo ejecutando estos dos comandos:

```bash
heroku config:set WEB_CONCURRENCY=1
heroku config:set RAILS_MAX_THREADS=3
```

También es recomendable configurar las siguientes variables:

```bash
heroku config:set RAILS_SERVE_STATIC_FILES=enabled
heroku config:set RAILS_ENV=production
```
