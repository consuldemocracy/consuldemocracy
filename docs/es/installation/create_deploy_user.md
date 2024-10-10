# Crear un usuario para hacer la instalación

[El instalador](https://github.com/consuldemocracy/installer) de forma predeterminada se conecta como el usuario `root` sólo para crear un usuario `deploy`. Este usuario `deploy` es el que instala todas las librerías. Si no tienes acceso `root`, por favor pide a tu administrador de sistemas que siga estas instrucciones para crear un usuario manualmente.

Puedes crear un usuario llamado `deploy` o utilizar cualquier otro nombre. **En este ejemplo, vamos a crear un usuario llamado `jupiter`**.

```bash
adduser jupiter
```

**Recuerda cambiar "jupiter" por el nombre de usuario que elijas.** Introduce una contraseña cuando se te pida y deja vacías el resto de las opciones.

Ahora, crearemos un grupo `wheel` y añadiremos al usuario `jupiter` al grupo.

```bash
sudo groupadd wheel
sudo usermod -a -G wheel jupiter
```

**Recuerda cambiar "jupiter" por cualquier nombre de usuario que hayas elegido en el paso anterior.**

A continuación, configuraremos el grupo `wheel` para que tenga derechos de superadministración sin necesidad de usar contraseña. **Esto es importante para que el instalador no se quede esperando una contraseña.**

Primero, debemos abrir el archivo `sudoers`:

```bash
sudo visudo -f /etc/sudoers
```

Y añadimos esta línea al final del archivo:

```text
%wheel ALL=(ALL) NOPASSWD: ALL
```

Ahora tenemos que dar las claves del servidor al nuevo usuario. No cierres la ventana de la terminal del servidor, porque puedes bloquearte si hay un error.

Escribe los siguientes comandos para crear el archivo necesario donde subir la clave pública:

```bash
su jupiter
cd ~
mkdir .ssh
cd .ssh
nano authorized_keys
```

Asegúrate de que has [generado una clave pública](generating_ssh_key.md) en tu terminal local.

Abre otra ventana de terminal local (no en el servidor) y escribe:

```bash
cat ~/.ssh/id_rsa.pub
```

Copia el contenido de ese comando al archivo `authorized_keys` que debería seguir abierto en el servidor.

Comprueba que el usuario puede iniciar sesión escribiendo:

```bash
ssh jupiter@your-copied-ip-address
```

Deberías ver la página de bienvenida del servidor y un mensaje como este:

```bash
jupiter@consuldemocracyserver:~$
```

Nota que el nombre de usuario en el prompt no es `root`, sino el nombre de usuario que elegiste, lo que indica que todo está bien. Ahora podemos bloquear la cuenta `root` del acceso externo y también dejar de permitir el acceso con contraseña para que sólo las personas con claves SSH puedan iniciar sesión.

Escribe el siguiente comando para editar el archivo de configuración SSH del servidor:

```bash
sudo nano /etc/ssh/sshd_config
```

Busca la línea "PasswordAuthentication yes" y cámbiala por "PasswordAuthentication no". Escribe `Control+X` para cerrar el editor nano y escribe:

```bash
sudo service ssh restart
```
