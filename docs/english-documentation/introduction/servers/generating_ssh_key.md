# Generating SSH Key

These instructions will help you generate a public key with which you can connect to the server without using a password.

In the terminal window, type:

```text
  ssh-keygen
```

When prompted for the file in which to save the key just press ENTER to leave the default. When prompted for a passphrase, just press ENTER again to leave this empty. At the end you should see a message like this:

```text
  Your identification has been saved in /your_home/.ssh/id_rsa. 
  Your public key has been saved in /your_home/.ssh/id_rsa.pub.
```

Take note of the **id\_rsa.pub** file location, because you’ll need the content of this file later.

