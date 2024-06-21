# Installing Consul Democracy on a Digital Ocean VPS

These instructions will help you register and buy a server in Digital Ocean to install Consul Democracy.

First you need to [sign up](https://cloud.digitalocean.com/registrations/new) and provide your personal information.

Once you are logged in, you need to create a Droplet (that’s the name that Digital Ocean uses for a Virtual Server). Click on the “Create” green button at the top of the page and select "Droplets":

![Digital Ocean Droplets](../../img/digital_ocean/droplets.png)

In the next page, you need to select Ubuntu (it should be pre-selected) and change the version **from 18.04 x64 to 16.04 x64**.

![Digital Ocean Choose an image](../../img/digital_ocean/image.png)

In the "Choose a size" section select the **$80/mo 16GB/6CPUs** option if this is going to be a production server. If you are just setting up a test system with a few users the cheapest $5/mo option can be enough.

![Digital Ocean Choose a size](../../img/digital_ocean/size.png)

Leave the rest of the options with their defaults until “Choose a datacenter”. Select the one that will be geographically closer to your users. If you are in the EU, select either Frankfurt or Amsterdam data centers.

![Digital Ocean Choose a region](../../img/digital_ocean/region.png)

In the "Add you SSH keys" section click "New SSH Key" button.

![Digital Ocean Add your SSH Keys](../../img/digital_ocean/ssh_keys.png)

In the pop up window that appears you need to copy and paste the public key that we [generated in the previous step](generating_ssh_key.md). To see the content of this key in the terminal window type:

  ```
  cat ~/.ssh/id_rsa.pub
  ```

You should see a text like this:

  ```
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy/BXU0OsK8KLLXpd7tVnqDU+d4ZS2RHQmH+hv0BFFdP6PmUbKdBDigRqG6W3QBexB2DpVcb/bmHlfhzDlIHJn/oki+SmUYLSWWTWuSeF/1N7kWf9Ebisk6hiBkh5+i0oIJYvAUsNm9wCayQ+i3U3NjuB25HbgtyjR3jDPIhmg1xv0KZ8yeVcU+WJth0pIvwq+t4vlZbwhm/t2ah8O7hWnbaGV/MZUcj0/wFuiad98yk2MLGciV6XIIq+MMIEWjrrt933wAgzEB8vgn9acrDloJNvqx25uNMpDbmoNXJ8+/P3UDkp465jmejVd/6bRaObXplu2zTv9wDO48ZpsaACP your_username@your_computer_name
  ```

Select and copy all the text and paste it in the pop-up window like this:

![Digital Ocean New SSH Key](../../img/digital_ocean/new_ssh.png)

Please note that there will be two little green checks. If they are not there, retry copying the text because you probably left something out. Give your key a meaningful name, like **Consul_Democracy_key** and click "Add SSH Key" button.

By using an SSH key instead of a user/password combination to access your server, it will be much more secure, as only someone with the private SSH key can access the server.

Now in the "Choose a hostname" section change the default for something more meaningful, like **consuldemocracyserver** for example.

![Digital Ocean hostname](../../img/digital_ocean/hostname.png)

At the bottom of the page you’ll see a summary of your options. Check that everything is OK and click the big green "Create" button.

![Digital Ocean create](../../img/digital_ocean/create.png)

It will take a few minutes, and at the end you will have a shiny new server. It will look like this in the Digital Ocean page:

![Digital Ocean server](../../img/digital_ocean/server.png)

Next to setup Consul Democracy in the server check the [installer's README](https://github.com/consuldemocracy/installer)
