# Instalación local

Antes de comenzar a instalar Consul, comprueba que tengas todos los [prerrequisitos](prerequisites) correctamente instalados.

1. Primero, clona el [repositorio de Consul en Github](https://github.com/consul/consul/):

```bash
git clone https://github.com/consul/consul.git
```

2. Ve a la carpeta del proyecto e instala las gemas requeridas usando [Bundler](http://bundler.io/):

```bash
cd consul
bundle
```

3. Copia los archivos de configuración de ejemplo del entorno dentro de unos nuevos válidos:

```bash
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
```

Y configura los de tu usuario de base de datos `consul` en `database.yml`

4. Ejecuta las siguientes [tareas Rake](https://github.com/ruby/rake) para crear y rellenar tu base de datos local con el mínimo de información necesaria para que la aplicación funcione correctamente:

```bash
rake db:create
rake db:setup
rake db:dev_seed
rake db:test:prepare
```

5. Comprueba que todo funciona correctamente lanzando la suite de tests (ten en cuenta que podría tardar más de una hora):

```bash
bin/rspec
```

6. Ahora que ya está todo listo puedes ejecutar la aplicación:

```bash
bin/rails s
```

¡Felicidades! Tu aplicación Consul local estará corriendo en `http://localhost:3000`.

En caso de que quieras acceder a la aplicación local como usuario administrador existe un usuario por defecto verificado y con permisos con **nombre de usuario** `admin@consul.dev` y **contraseña** `12345678`.

Si necesitas un usuario específico que pueda realizar acciones como votar sin permisos de administración, dispones de otro usuario verificado con **nombre de usuario** `verified@consul.dev` y **contraseña** `12345678`.
