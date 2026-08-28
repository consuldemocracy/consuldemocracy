# Create a deploy user

[The installer](https://github.com/consuldemocracy/installer) by default connects as the `root` user only to create a `deploy` user. This `deploy` user is the one who installs all libraries. If you do not have `root` access, please ask your system administrator to follow these instructions to create a user manually.

You could create a user called `deploy` or any other name. **In this example, we are going to create a user named `jupiter`**.

```bash
adduser jupiter
```

**Remember to replace `jupiter` with whatever username makes sense for you**. Input a password when prompted, and leave the rest of the options empty.

Let's create a `wheel` group and add the user `jupiter` to this group.

```bash
sudo groupadd wheel
sudo usermod -a -G wheel jupiter
```

**Remember to replace "jupiter" with the username you chose earlier.**

Now let's give sudo privileges to the `wheel` group and allow it to not use a password. This is important to ensure the installer doesn't stall waiting for a password.

First we open the sudoers file:

```bash
sudo visudo -f /etc/sudoers
```

And we add this line at the end:

```text
%wheel ALL=(ALL) NOPASSWD: ALL
```

Now we need to give the keys of the server to the new user. Don't close the server terminal window, because you can lock yourself out of your server if there is a mistake.

Let's create the necessary directory in the server to upload the public key:

```bash
su jupiter
cd ~
mkdir .ssh
cd .ssh
nano authorized_keys
```

Make sure you have [generated a public key](generating_ssh_key.md) in your local terminal.

Open another local terminal window (not in the server) and type:

```bash
cat ~/.ssh/id_rsa.pub
```

Copy the content of your public key to the file `authorized_keys` that should still be open in the server.

Test that your user can log in by typing:

```bash
ssh jupiter@your-copied-ip-address
```

You should see the server welcome page and a prompt like this:

```bash
jupiter@consuldemocracyserver:~$
```

Note the username at the prompt is not "root", but your username. So everything is fine and we can now block the root account from outside access and also stop allowing password access so only people with SSH keys can log in.

Type the following command to edit the SSH config file of the server:

```bash
sudo nano /etc/ssh/sshd_config
```

Look for the "PasswordAuthentication yes" line and change it to "PasswordAuthentication no". Type `Control+X` to close the nano editor and type:

```bash
sudo service ssh restart
```
