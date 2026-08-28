# Installing Consul Democracy on a Digital Ocean VPS

These instructions will help you register and buy a server in Digital Ocean to install Consul Democracy.

First you need to [sign up](https://cloud.digitalocean.com/registrations/new) and provide your personal information.

Once you have logged in, you'll need to create a Droplet (this is the name Digital Ocean uses for a cloud server) following this [guide](https://docs.digitalocean.com/products/droplets/how-to/create/) and configure it with the following recommendations:

## Region

In the "Choose Region" section, to avoid latency in the service, select the region that is geographically closest to your users.

## Image

In this "Choose an Image" section, we recommend selecting Ubuntu with the latest version supported by the installer, which in this case would be **24.04**.

## Size

In the "Choose Size" section, if the goal is to create a production server, we recommend choosing an option with at least **16GB of RAM**. If you are setting up a testing system or a staging environment with just a few users, the cheapest option may be sufficient.

## Authentication

In the "Choose Authentication Method" section, select "SSH Key" and click the "New SSH Key" button to add your key.

In the pop up window that appears you need to copy and paste the public key that we [generated in the previous step](generating_ssh_key.md). To see the content of this key in the terminal window type:

```bash
cat ~/.ssh/id_rsa.pub
```

You should see a text like this:

```text
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy/BXU0OsK8KLLXpd7tVnqDU+d4ZS2RHQmH+hv0BFFdP6PmUbKdBDigRqG6W3QBexB2DpVcb/bmHlfhzDlIHJn/oki+SmUYLSWWTWuSeF/1N7kWf9Ebisk6hiBkh5+i0oIJYvAUsNm9wCayQ+i3U3NjuB25HbgtyjR3jDPIhmg1xv0KZ8yeVcU+WJth0pIvwq+t4vlZbwhm/t2ah8O7hWnbaGV/MZUcj0/wFuiad98yk2MLGciV6XIIq+MMIEWjrrt933wAgzEB8vgn9acrDloJNvqx25uNMpDbmoNXJ8+/P3UDkp465jmejVd/6bRaObXplu2zTv9wDO48ZpsaACP your_username@your_computer_name
```

Select all the text, paste it into the pop-up window in the "SSH Key content" field, add a meaningful name such as **Consul_Democracy_key**, and click the Add SSH Key button.

By using an SSH key instead of a user/password combination to access your server, it will be much more secure, as only someone with the private SSH key can access the server.

## Hostname

Now, in the "Finalize Details" section, change the default value of the Hostname field to something more meaningful, like **consuldemocracyserver**.

At the bottom of the page you’ll see a summary of your options. Check that everything is OK and click the big green "Create" button.

It will take a few minutes, and at the end you will have a shiny new server. It will look like this in the Digital Ocean page:

Next to setup Consul Democracy in the server check the [installer's README](https://github.com/consuldemocracy/installer).
