# Instalación local

Antes de comenzar a instalar Consul Democracy, comprueba que tengas todos los [prerrequisitos](prerequisites.md) correctamente instalados.

1. Primero, clona el [repositorio de Consul Democracy en Github](https://github.com/consuldemocracy/consuldemocracy/) y ve a la carpeta del proyecto:

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
```

2. Instala la versión de Ruby necesaria con el gestor de versiones de tu elección. Algunos ejemplos:

```bash
rbenv install `cat .ruby-version` # Si usas rbenv
rvm install `cat .ruby-version` # Si usas RVM
asdf install ruby `cat .ruby-version` # Si usas asdf
```

3. Comprueba que estemos usando la versión de Ruby que acabamos de instalar:

```bash
ruby -v
=> # (debería aparecer la versión mencionada en el fichero .ruby-version)
```

4. Instala la versión de Node.js necesaria con tu gestor de versiones de Node.js. Si usas NVM:

```bash
nvm install `cat .node-version`
nvm use `cat .node-version`
```

5. Copia el archivo de ejemplo de configuración de base de datos:

```bash
cp config/database.yml.example config/database.yml
```

6. Configura las credenciales de base de datos con tu usuario `consul` en tu nuevo fichero `database.yml`

Nota: este paso no es necesario si estás utilizando un usuario de base de datos sin contraseña y el mismo nombre de usuario que tu usuario de sistema, que es el comportamiento por defecto en macOS.

```bash
nano config/database.yml
```

Y edita las líneas que contienen `username:` y `password:`, añadiendo tus credenciales.

7. Instala las dependencias del proyecto y crea la base de datos:

```bash
bin/setup
```

8. Ejecuta la siguiente [tarea Rake](https://github.com/ruby/rake) para rellenar tu base de datos local con datos de desarrollo:

```bash
bin/rake db:dev_seed
```

9. Comprueba que todo funciona correctamente lanzando la suite de tests

Nota: ejecutar todos los tests en tu máquina puede tardar más de una hora, por lo que recomendamos encarecidamente que configures un sistema de Integración Continua para ejecutarlos utilizando varios trabajos en paralelo cada vez que abras o modifiques una PR (si usas GitHub Actions o GitLab CI, esto ya está configurado en `.github/workflows/tests.yml` y `.gitlab-ci.yml`) y cuando trabajes en tu máquina ejecutes solamente los tests relacionados con tu desarrollo actual. Al configurar la aplicación por primera vez, recomendamos que ejecutes al menos un test en `spec/models/` y un test en `spec/system/` para comprobar que tu máquina está configurada para ejecutar los tests correctamente.

```bash
bin/rspec
```

10. Ahora que ya está todo listo puedes ejecutar la aplicación:

```bash
bin/rails s
```

¡Felicidades! Tu aplicación Consul Democracy local estará corriendo en `http://localhost:3000`.

En caso de que quieras acceder a la aplicación local como usuario administrador existe un usuario por defecto verificado y con permisos con **nombre de usuario** `admin@consul.dev` y **contraseña** `12345678`.

Si necesitas un usuario específico que pueda realizar acciones como votar sin permisos de administración, dispones de otro usuario verificado con **nombre de usuario** `verified@consul.dev` y **contraseña** `12345678`.
