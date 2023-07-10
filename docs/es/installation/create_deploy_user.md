# Crear un usuario para hacer la instalación

[El instalador](https://github.com/consul/installer) de forma predeterminada se conecta como el usuario `root` sólo para crear un usuario `deploy`. Este usuario `deploy` es el que instala todas las librerías. Si no tiene acceso `root`, por favor pídale a su administrador de sistemas que siga estas instrucciones para crear un usuario manualmente.

Puede crear un usuario llamado `deploy` o utilizar cualquier otro nombre. Como ejemplo, vamos a crear un usuario llamado `jupiter`.

  ```
  adduser jupiter
  ```

Estoy usando jupiter como nombre de usuario, debería cambiar eso por lo que sea que tenga sentido para usted. Introduzca una contraseña cuando se le pida y deje vacías el resto de las opciones.

Creemos un grupo `wheel` y añadamos al usuario `jupiter` al grupo.

  ```
  sudo groupadd wheel
  sudo usermod -a -G wheel jupiter
  ```

**Recuerde cambiar jupiter** por cualquier nombre de usuario que haya elegido en el paso anterior.

Ahora démosle al grupo `wheel` derechos de superadministración sin necesidad de usar contraseña, esto es importante para que el instalador no se quede parado esperando una contraseña.

Primero debemos abrir el archivo `sudoers`:

```
sudo visudo -f /etc/sudoers
```

Y añadimos esta línea al final del archivo:

```
%wheel ALL=(ALL) NOPASSWD: ALL
```

Ahora tenemos que dar las claves del servidor al nuevo usuario. No cierre la ventana de la terminal del servidor, porque puede bloquearse si hay un error.

Y escriba los siguientes comandos para crear el archivo necesario donde subir la clave pública:

```
su jupiter
cd ~
mkdir .ssh
cd .ssh
nano authorized_keys
```

Asegúrese que ha [generado una clave pública](generating_ssh_key.md) en su terminal local.

Abra otra ventana de terminal local (no en el servidor) y escriba:

```
cat ~/.ssh/id_rsa.pub
```

Copie el contenido de ese comando al archivo `authorized_keys` que debería seguir abierto en el servidor.

Compruebe que su usuario puede iniciar sesión escribiendo:

  ```
  ssh jupiter@your-copied-ip-address
  ```

Debería ver la página de bienvenida del servidor y un mensaje como este:

  ```
  jupiter@consuldemocracyserver:~$
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
