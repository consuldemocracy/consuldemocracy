![Logotipo de CONSUL DEMOCRACY](../img/consul_logo.png)

# CONSUL DEMOCRACY

Aplicación de Participación Ciudadana y Gobierno Abierto

## Fundación CONSUL DEMOCRACY y página web del proyecto

Puedes acceder a la página principal del proyecto en [http://consuldemocracy.org](http://consuldemocracy.org/es) donde puedes encontrar información sobre el uso de la plataforma, la Fundación CONSUL DEMOCRACY, la comunidad de usuarios y socios locales, noticias y formas de obtener más ayuda o ponerte en contacto con nosotros.

## Configuración para desarrollo y tests

**NOTA**:
El proceso de instalación varía según el sistema operativo. Por favor, consulta la [documentación de instalación local](installation/local_installation.md) apropiada para tu SO.

Prerrequisitos: tener instalado git, Ruby 3.4.9, CMake, pkg-config, Node.js 22.22.3, ImageMagick y PostgreSQL (>=13).

**Nota**: Es posible que ejecutar `bin/setup`, como se indica a continuación, falle si has configurado un nombre de usuario y contraseña para PostgreSQL. Si es así, edita las líneas que contienen `username:` y `password:` (añadiendo tus credenciales) en el fichero `config/database.yml` y ejecuta `bin/setup` de nuevo.

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
bin/setup
bin/rake db:dev_seed
```

Para ejecutar la aplicación en local:

```bash
bin/rails s
```

Para ejecutar los tests:

```bash
bin/rspec
```

Nota: ejecutar todos los tests en tu máquina puede tardar más de una hora, por lo que recomendamos encarecidamente que configures un sistema de Integración Continua para ejecutarlos utilizando varios trabajos en paralelo cada vez que abras o modifiques una PR (si usas GitHub Actions o GitLab CI, esto ya está configurado en `.github/workflows/tests.yml` y `.gitlab-ci.yml`) y cuando trabajes en tu máquina ejecutes solamente los tests relacionados con tu desarrollo actual. Al configurar la aplicación por primera vez, recomendamos que ejecutes al menos un test en `spec/models/` y un test en `spec/system/` para comprobar que tu máquina está configurada para ejecutar los tests correctamente.

Puedes usar el usuario administrador por defecto del fichero seeds:

 **user:** admin@consul.dev
 **pass:** 12345678

Pero para ciertas acciones, como apoyar, necesitarás un usuario verificado, el fichero seeds proporciona uno:

 **user:** verified@consul.dev
 **pass:** 12345678

## Configuración para entornos de producción

Ver [instalador](https://github.com/consuldemocracy/installer)

## Licencia

El código de este proyecto está publicado bajo la licencia AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](open_source/license.md))

## Contribuciones

Ver fichero [CONTRIBUTING_ES.md](https://github.com/consuldemocracy/consuldemocracy/blob/master/CONTRIBUTING_ES.md)
