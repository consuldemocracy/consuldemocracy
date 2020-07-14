# Vagrant

## Vagrant

Install [Vagrant](https://www.vagrantup.com/) and setup a virtual machine with [Linux](prerequisites.md)

Vagrant is compatible for [Debian](debian.md) and [Ubuntu](ubuntu.md).

### Browser configuration

To access the application through the brower at `localhost:3000` we must forward a port and run the rails server with a binding option:

### Port forwarding

Open the Vagrant configuration file:

```text
nano Vagranfile
```

Find this line:

```text
# config.vm.network "forwarded_port", guest: 80, host: 8080
```

And change it for this configuration:

```text
config.vm.network "forwarded_port", guest: 3000, host: 3000
```

Reload your virtual machine:

```text
vagrant reload
```

## Running the rails server

In your virtual machine, run the application server, binding to your local ip address:

```text
bin/rails s -b 0.0.0.0
```

Now you should be able to see the application running in your browser at url `localhost:3000`! :tada:

