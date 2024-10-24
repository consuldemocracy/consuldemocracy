# Instalando Consul Democracy en un VPS de Digital Ocean

Estas instrucciones te ayudarán a registrarte y comprar un servidor en Digital Ocean para instalar Consul Democracy.

Primero necesitas [registrarte](https://cloud.digitalocean.com/registrations/new) y proporcionar tu información personal.

Una vez que hayas iniciado sesión, deberás crear un _Droplet_ (este es el nombre que Digital Ocean utiliza para un servidor en la nube) siguiendo esta [guía](https://docs.digitalocean.com/products/droplets/how-to/create/) y configurarlo teniendo en cuenta los siguientes consejos:

## Región

Para evitar latencia en el servicio, selecciona la región que esté geográficamente más cerca de vuestros usuarios.

## Imagen

En esta sección recomendamos seleccionar ubuntu con la última versión soportada por el instalador, que en este caso sería la **24.04**.

## Tamaño

En la sección "Elegir un tamaño" si el objetivo es crear un servidor para producción recomendamos elegir una opción que al menos tenga **16GB de RAM**. Si por el contrario estás configurando un sistema de pruebas o un entorno de staging con unos pocos usuarios, la opción más barata puede ser suficiente.

## Autenticación

En la sección "Elegir un método de autenticación" seleccionaremos _SSH Key_ y pulsaremos el botón _New SSH Key_ para añadir nuestra clave

En la ventana emergente que aparece es necesario copiar y pegar la clave pública que [generamos en el paso anterior](generating_ssh_key.md). Para ver el contenido de esta clave en la ventana del terminal, escribe:

```bash
cat ~/.ssh/id_rsa.pub
```

Deberías ver un texto como este:

```text
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy/BXU0OsK8KLLXpd7tVnqDU+d4ZS2RHQmH+hv0BFFdP6PmUbKdBDigRqG6W3QBexB2DpVcb/bmHlfhzDlIHJn/oki+SmUYLSWWTWuSeF/1N7kWf9Ebisk6hiBkh5+i0oIJYvAUsNm9wCayQ+i3U3NjuB25HbgtyjR3jDPIhmg1xv0KZ8yeVcU+WJth0pIvwq+t4vlZbwhm/t2ah8O7hWnbaGV/MZUcj0/wFuiad98yk2MLGciV6XIIq+MMIEWjrrt933wAgzEB8vgn9acrDloJNvqx25uNMpDbmoNXJ8+/P3UDkp465jmejVd/6bRaObXplu2zTv9wDO48ZpsaACP your_username@your_computer_name
```

Selecciona todo el texto, pégalo en la ventana emergente en el campo _SSH Key content_, añade un nombre significativo como por ejemplo **Consul_Democracy_key** y clica sobre el botón _Add SSH Key_.

Al utilizar una clave SSH en lugar de una combinación de usuario/contraseña para acceder a tu servidor, será mucho más seguro, ya que sólo alguien con la clave privada SSH puede acceder al servidor.

## Nombre del host

Ahora en la sección "Ultimar detalles" cambia el valor por defecto del campo _Hostname_ por algo más significativo, como **consuldemocracyserver** por ejemplo.

En la parte inferior de la página verás un resumen de tus opciones. Comprueba que todo está bien y haz clic en el botón grande verde "Crear".

Tardará unos minutos, y al final tendrás un brillante nuevo servidor.

Lo siguiente es configurar Consul Democracy en el servidor. Por favor [lee estas instrucciones](https://github.com/consuldemocracy/installer).
