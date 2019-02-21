# Instalando CONSUL en un VPS de Digital Ocean

1. Instalar ANSIBLE en la máquina local

Para poder controlar la instalación de CONSUL en el servidor, es necesario instalar ANSIBLE en su máquina local. El método depende del tipo de sistema operativo que esté utilizando.

**Mac OSX**

Abra una consola de terminal y escriba los siguientes comandos:

  ```
  sudo easy_install pip
  sudo pip install ansible
  ```

**Linux**

Debe instalar ANSIBLE utilizando su gestor de paquetes. Por ejemplo, si está usando Ubuntu, estos son los comandos para instalarlo:

  ```
  sudo apt-get update 
  sudo apt-get install software-properties-common 
  sudo apt-add-repository --yes --update ppa:ansible/ansible
   sudo apt-get install ansible
  ```

**Windows**

Para poder usar ANSIBLE, primero debe instalar Cygwin, que es un entorno UNIX para Windows. Puede[descargar el software aquí] (http://cygwin.com/setup-x86_64.exe).
Una vez descargado, abra una ventana de consola y escriba el siguiente comando (es todo una larga línea):

  ```
  setup-x86_64.exe -q --packages=binutils,curl,cygwin32-gcc-g++,gcc-g++,git,gmp,libffi-devel,libgmp-devel,make,nano,openssh,openssl-devel,python-crypto,python-paramiko,python2,python2-devel,python2-openssl,python2-pip,python2-setuptools
  ```

Una vez que finalice el instalador, tendrá un acceso directo en el escritorio que puede utilizar para abrir un terminal Cygwin. En esta terminal, escriba:

  ```
  pip2 install ansible
  ```

2. Generación de claves SSH

En la ventana del terminal, escriba:

  ```
  ssh-keygen
  ```

Cuando se le pida el archivo en el que guardar la clave, sólo tiene que pulsar ENTER para dejar el valor predeterminado. Cuando se le pida una frase de contraseña, pulse ENTER de nuevo para dejarla vacía. Al final debería ver un mensaje como este:

  ```
  Your identification has been saved in /your_home/.ssh/id_rsa. 
  Your public key has been saved in /your_home/.ssh/id_rsa.pub.
  ```

Tome nota de la ubicación del archivo **id_rsa.pub**, porque necesitará el contenido de este archivo más adelante.

3. Comprar el servidor de Digital Ocean

Primero necesita [registrarse](https://cloud.digitalocean.com/registrations/new) y proporcionar su información personal.

Una vez que haya iniciado sesión, deberá crear un Droplet (ese es el nombre que Digital Ocean utiliza para un Servidor Virtual). Haga clic en el botón verde "Crear" en la parte superior de la página y seleccione "Droplets":

![Digital Ocean Droplets](../../img/digital_ocean/droplets.png)

En la página siguiente, debe seleccionar Ubuntu (debería estar preseleccionado) y cambiar la versión **de 18.04 x 64 a 16.04 x 64**.

![Digital Ocean Choose an image](../../img/digital_ocean/image.png)

En la sección "Elegir un tamaño" seleccione la opción **$80/mo 16GB/6CPUs** si va a ser un servidor de producción. Si está configurando un sistema de prueba con unos pocos usuarios, la opción más barata de $5/mes puede ser suficiente.

![Digital Ocean Choose a size](../../img/digital_ocean/size.png)

Deje el resto de las opciones con sus valores por defecto hasta "Elegir un centro de datos". Seleccione el que esté geográficamente más cerca de sus usuarios. Si se encuentra en la UE, seleccione los centros de datos de Frankfurt o Amsterdam.

![Digital Ocean Choose a region](../../img/digital_ocean/region.png)

En la sección "Añadir claves SSH" pulse el botón "Nueva clave SSH".

![Digital Ocean Add your SSH Keys](../../img/digital_ocean/ssh_keys.png)

En la ventana emergente que aparece es necesario copiar y pegar la clave pública que generamos en el paso anterior. Para ver el contenido de esta clave en la ventana del terminal, escriba:

  ```
  cat ~/.ssh/id_rsa.pub
  ```

Debería ver un texto como este:

  ```
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy/BXU0OsK8KLLXpd7tVnqDU+d4ZS2RHQmH+hv0BFFdP6PmUbKdBDigRqG6W3QBexB2DpVcb/bmHlfhzDlIHJn/oki+SmUYLSWWTWuSeF/1N7kWf9Ebisk6hiBkh5+i0oIJYvAUsNm9wCayQ+i3U3NjuB25HbgtyjR3jDPIhmg1xv0KZ8yeVcU+WJth0pIvwq+t4vlZbwhm/t2ah8O7hWnbaGV/MZUcj0/wFuiad98yk2MLGciV6XIIq+MMIEWjrrt933wAgzEB8vgn9acrDloJNvqx25uNMpDbmoNXJ8+/P3UDkp465jmejVd/6bRaObXplu2zTv9wDO48ZpsaACP bprieto@MacBook-Pro.local
  ```

Seleccione y copie todo el texto y péguelo en la ventana emergente de la siguiente manera:

![Digital Ocean New SSH Key](../../img/digital_ocean/new_ssh.png)

Tenga en cuenta que habrá dos pequeños checks verdes. Si no están ahí, vuelva a intentar copiar el texto porque probablemente omitió algo. Dé a su clave un nombre significativo, como **CONSUL_key** y haga clic en el botón "Add SSH Key" (Añadir clave SSH).

Al utilizar una clave SSH en lugar de una combinación de usuario/contraseña para acceder a su servidor, será mucho más seguro, ya que sólo alguien con la clave SSH puede acceder al servidor.

Ahora en la sección "Choose a hostname" cambie el valor por defecto por algo más significativo, como **consulserver** por ejemplo.

![Digital Ocean hostname](../../img/digital_ocean/hostname.png)

En la parte inferior de la página verás un resumen de tus opciones. Compruebe que todo está bien y haga clic en el botón grande verde "Crear".

![Digital Ocean create](../../img/digital_ocean/create.png)

Tardará unos minutos, y al final tendrá un brillante nuevo servidor. Se verá así en la página de Digital Ocean:

![Digital Ocean server](../../img/digital_ocean/server.png)

4. Configuración del nuevo servidor

Para entrar en su nuevo servidor, copie la dirección IP del servidor y en la ventana de su terminal escriba:

  ```
  ssh root@your-copied-ip-address
  ```

Verá un mensaje de bienvenida y una indicación como ésta:

  ```
  root@consulserver:~#
  ```

Lo primero que debe hacer es actualizar el servidor, escribiendo estos comandos:

  ```
  apt update
  apt upgrade -y
  ```

Si el proceso de actualización le pregunta algo, simplemente acepte la opción predeterminada.

En este momento estamos conectados con el usuario root, lo cual es una mala práctica que podría comprometer la seguridad del servidor. Así que necesitamos crear un nuevo usuario para administrar nuestro servidor:

  ```
  adduser jupiter
  ```

Estoy usando jupiter como nombre de usuario, debería cambiar eso por lo que sea que tenga sentido para usted. Introduzca una contraseña cuando se le pida y deje vacías el resto de las opciones.

Démosle a este usuario derechos de superadministración:

  ```
  usermod -aG sudo jupiter
  ```

**Recuerde cambiar jupiter** por cualquier nombre de usuario que haya elegido en el paso anterior.

Ahora tenemos que dar las claves del servidor al nuevo usuario. No cierre la ventana de la terminal del servidor, porque puede bloquearse si hay un error.

Abra otra ventana de terminal local (no en el servidor) y escriba:

```
ssh-copy-id jupiter@your-copied-ip-address
```

Introduzca su nueva contraseña de usuario cuando se le solicite. Recuerde cambiar "jupiter" para su nombre de usuario y "su dirección IP copiada" para la dirección IP de su servidor.

Compruebe que su usuario puede iniciar sesión escribiendo:

  ```
  ssh jupiter@your-copied-ip-address
  ```

Debería ver la página de bienvenida del servidor y un mensaje como este:

  ```
  jupiter@consulserver:~$
  ```

Note que el nombre de usuario en el prompt no es "root", sino su nombre de usuario. Así que todo está bien y ahora podemos bloquear la cuenta root del acceso externo y también dejar de permitir el acceso con contraseña para que sólo las personas con claves SSH puedan iniciar sesión.

Escriba el siguiente comando para editar el archivo de configuración SSH del servidor:

  ```
  sudo nano /etc/ssh/sshd_config
  ```

Busque la línea "PasswordAuthentication yes" y cámbiela por "PasswordAuthentication no". Escriba Control-K para cerrar el editor nano y escriba:

  ```
  sudo service ssh restart
  ```

Ya casi estamos, sólo tenemos que instalar algún software necesario para ANSIBLE escribiendo:

  ```
  sudo apt-get -y install python-simplejson
  ```

5. Ejecutar el instalador

En el terminal de su máquina local, escriba:

  ```
  git clone https://github.com/consul/installer 
  cd installer
  cp hosts.example hosts
  ```

Edite el archivo de hosts para introducir la dirección IP de su servidor escribiendo "nano hosts" y cambiando "remote-server-ip-address" por la dirección IP de su servidor. Escriba Control-k para guardar y cerrar el editor.

Ahora por fin estamos listos para iniciar el instalador. Escriba:

  ```
  sudo ansible-playbook -v consul.yml -i hosts
  ```

Deberías ver algunos mensajes de ANSIBLE mientras se ejecuta la instalación de CONSUL. Mientras puede tomar un café..., esto puede tardar un rato.

Cuando todo haya terminado, vaya a su navegador y escriba su dirección IP en la dirección URL. ¡Deberías ver tu nuevo sitio web **CONSUL** en funcionamiento! 🎉
Hay un usuario de administración predeterminado con **nombre de usuario admin@consul.dev y contraseña 12345678**, por lo que sólo tiene que iniciar sesión y empezar a trabajar con CONSUL.
