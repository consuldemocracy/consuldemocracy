# Instalando Consul Democracy en un VPS de Digital Ocean

Estas instrucciones le ayudaran a registrarse y comprar un servidor en Digital Ocean para instalar Consul Democracy.

Primero necesita [registrarse](https://cloud.digitalocean.com/registrations/new) y proporcionar su información personal.

Una vez que haya iniciado sesión, deberá crear un Droplet (ese es el nombre que Digital Ocean utiliza para un Servidor Virtual). Haga clic en el botón verde "Crear" en la parte superior de la página y seleccione "Droplets":

![Digital Ocean Droplets](../../img/digital_ocean/droplets.png)

En la página siguiente, debe seleccionar Ubuntu (debería estar preseleccionado) y cambiar la versión **de 18.04 x64 a 16.04 x64**.

![Digital Ocean Choose an image](../../img/digital_ocean/image.png)

En la sección "Elegir un tamaño" seleccione la opción **$80/mo 16GB/6CPUs** si va a ser un servidor de producción. Si está configurando un sistema de prueba con unos pocos usuarios, la opción más barata de $5/mes puede ser suficiente.

![Digital Ocean Choose a size](../../img/digital_ocean/size.png)

Deje el resto de las opciones con sus valores por defecto hasta "Elegir un centro de datos". Seleccione el que esté geográficamente más cerca de sus usuarios. Si se encuentra en la UE, seleccione los centros de datos de Frankfurt o Amsterdam.

![Digital Ocean Choose a region](../../img/digital_ocean/region.png)

En la sección "Añadir claves SSH" pulse el botón "Nueva clave SSH".

![Digital Ocean Add your SSH Keys](../../img/digital_ocean/ssh_keys.png)

En la ventana emergente que aparece es necesario copiar y pegar la clave pública que [generamos en el paso anterior](generating_ssh_key.md). Para ver el contenido de esta clave en la ventana del terminal, escriba:

  ```
  cat ~/.ssh/id_rsa.pub
  ```

Debería ver un texto como este:

  ```
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy/BXU0OsK8KLLXpd7tVnqDU+d4ZS2RHQmH+hv0BFFdP6PmUbKdBDigRqG6W3QBexB2DpVcb/bmHlfhzDlIHJn/oki+SmUYLSWWTWuSeF/1N7kWf9Ebisk6hiBkh5+i0oIJYvAUsNm9wCayQ+i3U3NjuB25HbgtyjR3jDPIhmg1xv0KZ8yeVcU+WJth0pIvwq+t4vlZbwhm/t2ah8O7hWnbaGV/MZUcj0/wFuiad98yk2MLGciV6XIIq+MMIEWjrrt933wAgzEB8vgn9acrDloJNvqx25uNMpDbmoNXJ8+/P3UDkp465jmejVd/6bRaObXplu2zTv9wDO48ZpsaACP your_username@your_computer_name
  ```

Seleccione y copie todo el texto y péguelo en la ventana emergente de la siguiente manera:

![Digital Ocean New SSH Key](../../img/digital_ocean/new_ssh.png)

Tenga en cuenta que habrá dos pequeños checks verdes. Si no están ahí, vuelva a intentar copiar el texto porque probablemente omitió algo. Dé a su clave un nombre significativo, como **Consul_Democracy_key** y haga clic en el botón "Add SSH Key" (Añadir clave SSH).

Al utilizar una clave SSH en lugar de una combinación de usuario/contraseña para acceder a su servidor, será mucho más seguro, ya que sólo alguien con la clave privada SSH puede acceder al servidor.

Ahora en la sección "Choose a hostname" cambie el valor por defecto por algo más significativo, como **consuldemocracyserver** por ejemplo.

![Digital Ocean hostname](../../img/digital_ocean/hostname.png)

En la parte inferior de la página verás un resumen de tus opciones. Compruebe que todo está bien y haga clic en el botón grande verde "Crear".

![Digital Ocean create](../../img/digital_ocean/create.png)

Tardará unos minutos, y al final tendrá un brillante nuevo servidor. Se verá así en la página de Digital Ocean:

![Digital Ocean server](../../img/digital_ocean/server.png)

Lo siguiente es configurar Consul Democracy en el servidor. Por favor [leer estas instrucciones](https://github.com/consul/installer)
