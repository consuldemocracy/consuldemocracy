## Configuración para los entornos de desarrollo y pruebas (Ubuntu 18.04)

## Git

Git es mantenido oficialmente en Ubuntu:

```bash
sudo apt install git
```

## Ruby

Las versiones de Ruby versions empaquetadas en repositorios oficiales no son aptas para trabajar con CONSUL, así que debemos instalarlo manualmente.

En primer lugar, necesitamos los siguiente paquetes para poder instalar Ruby:

```bash
sudo apt install libssl1.0-dev autoconf bison build-essential libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
```

Nótese que estamos instalando el paquete `libssl1.0-dev` en lugar de `libssl-dev`. Esto es debido a que Ruby 2.3.2 (versión que CONSUL 0.19 utiliza) no es compatible con OpenSSL 1.1.

El siguiente paso es instalar un gestor de versiones de Ruby, como rbenv:

```bash
wget -q https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer -O- | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

Por último, para instalar Ruby 2.3.2 (proceso que llevará unos minutos):

```bash
rbenv install 2.3.2
```

## Bundler

Comprueba que estemos usando la versión de Ruby que acabamos de instalar:

```bash
rbenv global 2.3.2
ruby -v
=> ruby 2.3.2p217
```

E instala Bundle con:

```bash
gem install bundler
```

## Node.js

Para compilar los archivos estáticos (JS, CSS, imágenes, etc.), es necesario un _runtime_ de JavaScript. Node.js es la opción recomendada. Al igual que como ocurre con Ruby, no es recomendable instalar Node directamente de los repositorios de tu distribución Linux.

Para instalar Node, puedes usar [n](https://github.com/tj/n)

Ejecuta en tu terminal:

```bash
wget -L https://git.io/n-install | bash -s -- -y lts
```

Y este instalará automáticamente la versión LTS (_Long Term Support_, inglés para "Soporte a largo plazo") más reciente de Node en tu directorio `$HOME` (usando [n-install](https://github.com/mklement0/n-install))

## PostgreSQL

Instala postgresql y sus dependencias de desarrollo con:

```bash
sudo apt install postgresql libpq-dev
```

Para el correcto funcionamiento de CONSUL, necesitas confgurar un usuario para tu base de datos. Como ejemplo, crearemos un usuario llamado "consul":

```bash
sudo -u postgres createuser consul --createdb --superuser --pwprompt
```

## ChromeDriver

Para realizar pruebas de integración, usamos Selenium junto a Headless Chrome.

Para poder utilizarlo, instala el paquete chromium-chromedrive y asegúrate de que se encuentre enlazado en algún directorio que esté en la variable de entorno PATH:

```bash
sudo apt install chromium-chromedriver
sudo ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/
```

¡Ya estás listo para [instalar CONSUL](local_installation.md)!
