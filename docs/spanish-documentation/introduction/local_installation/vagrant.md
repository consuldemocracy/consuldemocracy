# Vagrant

## Vagrant

Instale [Vagrant](https://www.vagrantup.com/) y configure una máquina virtual con [Linux](https://github.com/consul/docs/tree/90f5b9355c5e7b3fc2ffae0e9c963b792ea00d92/es/installation/prerequisites.md)

Vagrant es compatible para [Debian](debian.md) y [Ubuntu](ubuntu.md).

### Browser configuration

Para acceder a la aplicación a través del navegador en la url `localhost:3000` debe enrutar el puerto de la aplicación y ejectuar el servidor de la aplicación con la opción `-b`:

### Enrutar el puerto de la aplicación

Abra el archivo de configuración de Vagrant:

```text
nano Vagranfile
```

Encuentre esta línea:

```text
# config.vm.network "forwarded_port", guest: 80, host: 8080
```

Cámbiela por esta:

```text
config.vm.network "forwarded_port", guest: 3000, host: 3000
```

Recargue la máquina virtual:

```text
vagrant reload
```

## Ejecutar el servidor

En su máquina virtual, debe ejecutar la aplicación enlanzándola a su IP local:

```text
bin/rails s -b 0.0.0.0
```

Ahora debería ver la aplicación desde el navegardor en la url `localhost:3000` :tada:

