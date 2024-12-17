# Generación de claves SSH

Estas instrucciones te ayudarán a generar una clave pública con la que podrás conectarte al servidor sin necesidad de utilizar una contraseña.

En la ventana del terminal, escribe:

```bash
ssh-keygen
```

Cuando se te pida el archivo en el que guardar la clave, solo tienes que pulsar ENTER para dejar el valor predeterminado. Cuando se te pida una frase de contraseña, pulsa ENTER de nuevo para dejarla vacía. Al final deberías ver un mensaje como este:

```text
Your identification has been saved in /your_home/.ssh/id_rsa. 
Your public key has been saved in /your_home/.ssh/id_rsa.pub.
```

Toma nota de la ubicación del archivo **id_rsa.pub**, porque necesitarás el contenido de este archivo más adelante.
