# Instalación local

Antes de instalar Consul y empezar a usarlo asegúrate de tener [Ruby 2.3.2](https://www.ruby-lang.org/en/news/2016/11/15/ruby-2-3-2-released/) instalado en tu entorno local.

1. Primero, clona el [repositorio de Consul en Github](https://github.com/consul/consul/):

  ```
  git clone https://github.com/consul/consul.git
  ```

2. Ve a la carpeta del proyecto e instala las gemas requeridas usando [Bundler](http://bundler.io/):
  ```
  cd consul
  bundle install
  ```

3. Copia los archivos de configuración de ejemplo del entorno dentro de unos nuevos válidos:

  ```
  cp config/database.yml.example config/database.yml
  cp config/secrets.yml.example config/secrets.yml
  ```

4. Ejecuta las siguientes [tareas Rake](https://github.com/ruby/rake) para rellenar tu base de datos local con el mínimo de información necesaria para que la aplicación funcione correctamente:

  ```
  bin/rake db:setup
  bin/rake db:dev_seed
  RAILS_ENV=test rake db:setup
  ```

5. Ahora que ya está todo listo puedes ejecutar la aplicación:

  ```
  rails s
  ```

  ¡Felicidades! Tu aplicación Consul local estará corriendo en `http://localhost:3000`.

En caso de que quieras acceder a la aplicación local como usuario administrador existe un usuario por defecto con permisos con **nombre de usuario** `admin@consul.dev` y **contraseña** `12345678`.

Si necesitas un usuario específico que pueda realizar acciones como votar, dispones de otro usuario verificado con **nombre de usuario** `verified@consul.dev` y **contraseña** `12345678`.
