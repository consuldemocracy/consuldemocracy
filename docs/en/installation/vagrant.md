# Vagrant

Install [Vagrant](https://www.vagrantup.com/) and setup a virtual machine with [Linux](prerequisites.md)

Vagrant is compatible for [Debian](/en/installation/debian.md) and [Ubuntu](/en/installation/ubuntu.md).

## Browser configuration

To access the application through the browser at `localhost:3000` we must forward a port and run the rails server with a binding option:

## Port forwarding
Open the Vagrant configuration file:

```
nano Vagranfile
```

Find this line:

```
# config.vm.network "forwarded_port", guest: 80, host: 8080
```

And change it for this configuration:

```
config.vm.network "forwarded_port", guest: 3000, host: 3000
```

Reload your virtual machine:

```
vagrant reload
```

# Running the rails server

In your virtual machine, run the application server, binding to your local ip address:

```
bin/rails s -b 0.0.0.0
```

Now you should be able to see the application running in your browser at url `localhost:3000`! :tada:
