# Usar AWS S3 como almacenamiento de archivos

Aunque Consul Democracy almacena la mayor parte de sus datos en una base de datos PostgreSQL, en Heroku todos los archivos como documentos o imágenes deben almacenarse en otro lugar, como puede ser AWS S3.

## Añadir la gema *aws-sdk-s3*

Añade la siguiente línea en tu *Gemfile_custom*:

```ruby
gem "aws-sdk-s3", "~> 1"
```

Y ejecuta `bundle install` para aplicar los cambios.

## Añadir tus credenciales en *secrets.yml*

Esta guía asume que tienes una cuenta de Amazon configurada para usar S3 y que has creado un _bucket_ para tu instancia de Consul Democracy. Se recomienda encarecidamente usar un _bucket_ diferente para cada instancia (producción, preproducción, staging).

Necesitarás la siguiente información:

- El **nombre** del _bucket_.
- La **región** del _bucket_ (`eu-central-1` para UE-Frankfurt, por ejemplo).
- Una **_access_key_** y un **_secret_key_** con permisos de lectura/escritura para el _bucket_.

**AVISO:** Se recomienda crear usuarios _IAM_ (Identity and Access Management) que solo tengan permisos de lectura/escritura en el _bucket_ que deseas usar para esa instancia específica de Consul Democracy.

Una vez que tengas esta información, puedes guardarla como variables de entorno de la instancia que ejecuta Consul Democracy. En este tutorial, las guardamos respectivamente como *S3_BUCKET*, *S3_REGION*, *S3_ACCESS_KEY_ID* and *S3_SECRET_ACCESS_KEY*.

```bash
heroku config:set S3_BUCKET=example-bucket-name S3_REGION=eu-west-example S3_ACCESS_KEY_ID=xxxxxxxxx S3_SECRET_ACCESS_KEY=yyyyyyyyyy
```

Ahora añade el siguiente bloque en tu fichero *secrets.yml*:

```yaml
production:
  s3:
    access_key_id: <%= ENV["S3_ACCESS_KEY_ID"] %>
    secret_access_key: <%= ENV["S3_SECRET_ACCESS_KEY"] %>
    region: <%= ENV["S3_REGION"] %>
    bucket: <%= ENV["S3_BUCKET"] %>
```

## Habilitar el uso de S3 en la aplicación

Primero, agrega la siguiente línea dentro de la clase `class Application < Rails::Application` en el fichero `config/application_custom.rb`:

```ruby
# Store uploaded files on the local file system (see config/storage.yml for options).
config.active_storage.service = :s3
```

Luego, descomenta el bloque de **s3** que encontrarás en el fichero *storage.yml*:

```yaml
s3:
  service: S3
  access_key_id: <%= Rails.application.secrets.dig(:s3, :access_key_id) %>
  secret_access_key: <%= Rails.application.secrets.dig(:s3, :secret_access_key) %>
  region: <%= Rails.application.secrets.dig(:s3, :region) %>
  bucket: <%= Rails.application.secrets.dig(:s3, :bucket) %>
```

Necesitarás reiniciar la aplicación para aplicar los cambios.
