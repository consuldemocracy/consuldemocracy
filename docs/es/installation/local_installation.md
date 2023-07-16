# Instalación local

Antes de comenzar a instalar Consul Democracy, comprueba que tengas todos los [prerrequisitos](prerequisites.md) correctamente instalados.

1. Primero, clona el [repositorio de Consul Democracy en Github](https://github.com/consuldemocracy/consuldemocracy/) y ve a la carpeta del proyecto:

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
```

2. Instala la versión de Ruby necesaria con el gestor de versiones de tu elección. Algunos ejemplos:

```bash
rvm install `cat .ruby-version` # Si usas RVM
rbenv install `cat .ruby-version` # Si usas rbenv
asdf install ruby `cat .ruby-version` # Si usas asdf
```

3. Comprueba que estemos usando la versión de Ruby que acabamos de instalar:

```bash
ruby -v
=> # (debería aparecer la versión mencionada en el fichero .ruby-version)
```

4. Instala [Bundler](http://bundler.io/)

```bash
gem install bundler --version 1.17.1
```

5. Instala las gemas requeridas usando Bundler:

```bash
bundle
```

6. Copia los archivos de configuración de ejemplo del entorno dentro de unos nuevos válidos:

```bash
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
```

Y configura los de tu usuario de base de datos `consul` en `database.yml`

7. Ejecuta las siguientes [tareas Rake](https://github.com/ruby/rake) para crear y rellenar tu base de datos local con el mínimo de información necesaria para que la aplicación funcione correctamente:

```bash
bin/rake db:create
bin/rake db:setup
bin/rake db:dev_seed
bin/rake db:test:prepare
```

8. Comprueba que todo funciona correctamente lanzando la suite de tests (ten en cuenta que podría tardar más de una hora):

```bash
bin/rspec
```

9. Ahora que ya está todo listo puedes ejecutar la aplicación:

```bash
bin/rails s
```

¡Felicidades! Tu aplicación Consul Democracy local estará corriendo en `http://localhost:3000`.

En caso de que quieras acceder a la aplicación local como usuario administrador existe un usuario por defecto verificado y con permisos con **nombre de usuario** `admin@consul.dev` y **contraseña** `12345678`.

Si necesitas un usuario específico que pueda realizar acciones como votar sin permisos de administración, dispones de otro usuario verificado con **nombre de usuario** `verified@consul.dev` y **contraseña** `12345678`.
