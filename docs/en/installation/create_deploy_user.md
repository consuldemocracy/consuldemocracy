# Create a deploy user

[The installer](https://github.com/consul/installer) by default connects as the `root` user only to create a `deploy` user. This `deploy` user is the one who installs all libraries. If you do not have `root` access, please ask your system administrator to follow these instructions to create a user manually.

You could create a user called `deploy` or any other name. As as example, we are going to create a user named `jupiter`.

  ```
  adduser jupiter
  ```

I'm using jupiter as the user name, you should change that for whatever makes sense to you. Input a password when prompted, and just leave empty the rest of the options.

Let's create a `wheel` group and add the user `jupiter` to this group.

  ```
  sudo groupadd wheel
  sudo usermod -a -G wheel jupiter
  ```

Now let's give sudo privileges to the `wheel` group and allow it to not use a password, this is important so that the installer doesn't get stalled waiting for a password.

First we open the sudoers file:

```
sudo visudo -f /etc/sudoers
```

And we add this line at the end:

```
%wheel ALL=(ALL) NOPASSWD: ALL
```

Now we need to give the keys of the server to the new user. Don’t close the server terminal window, because you can lock yourself out of your server if there is a mistake.

Let's create the necessary directory in the server to upload the public key:

```
su jupiter
cd ~
mkdir .ssh
cd .ssh
nano authorized_keys
```

Make sure you have [generated a public key](generating_ssh_key.md) in your local terminal.

Open another local terminal window (not in the server) and type:

```
cat ~/.ssh/id_rsa.pub
```

Copy the content of your public key to the file authorized_keys that should still be open in the server.

Test that your user can log in by typing:

  ```
  ssh jupiter@your-copied-ip-address
  ```

You should see the server welcome page and a prompt like this:

  ```
  jupiter@consuldemocracyserver:~$
  ```

Note the username at the prompt is not "root", but your username. So everything is fine and we can now block the root account from outside access and also stop allowing password access so only people with SSH keys can log in.

Type the following command to edit the SSH config file of the server:

  ```
  sudo nano /etc/ssh/sshd_config
  ```

Look for the "PasswordAuthentication yes" line and change it to "PasswordAuthentication no". Type Control-K to close the nano editor and type:

  ```
  sudo service ssh restart
  ```
