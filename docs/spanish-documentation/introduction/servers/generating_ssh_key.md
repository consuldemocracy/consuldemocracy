# Generación de claves SSH

Estas instrucciones le ayudarán a generar una clave pública con la que podrá conectarse al servidor sin necesidad de utilizar una contraseña.

En la ventana del terminal, escriba:

```text
  ssh-keygen
```

Cuando se le pida el archivo en el que guardar la clave, sólo tiene que pulsar ENTER para dejar el valor predeterminado. Cuando se le pida una frase de contraseña, pulse ENTER de nuevo para dejarla vacía. Al final debería ver un mensaje como este:

```text
  Your identification has been saved in /your_home/.ssh/id_rsa. 
  Your public key has been saved in /your_home/.ssh/id_rsa.pub.
```

Tome nota de la ubicación del archivo **id\_rsa.pub**, porque necesitará el contenido de este archivo más adelante.

