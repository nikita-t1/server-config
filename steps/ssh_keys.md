---
title: "Set up SSH keys for secure communication"
description: "Learn how to setup SSH keys between your client machine and Ubuntu server to securely administer and communicate with servers through an encrypted protocol."
---

# {{ $frontmatter.title }}

## Introduction

SSH, or secure shell, is an encrypted protocol used to administer and communicate with servers. When working with an
Ubuntu server, chances are you will spend most of your time in a terminal session connected to your server through SSH.

## Setup SSH Keys [Client]

The first step is to create a key pair on the client machine (usually your computer):

``` bash
ssh-keygen -b 4096
```

After entering the command, you should see the following output:

> ```
> Generating public/private rsa key pair.
> Enter file in which to save the key (/your_home/.ssh/id_rsa):
> ```

Press enter to save the key pair into the .ssh/ subdirectory in your home directory, or specify an alternate path.

> ```
> Enter passphrase (empty for no passphrase):
> ```

Here you optionally may enter a secure passphrase, which is highly recommended. A passphrase adds an additional layer of
security to prevent unauthorized users from logging in.

> ```
 > Your identification has been saved in /your_home/.ssh/id_rsa
 > Your public key has been saved in /your_home/.ssh/id_rsa.pub
 > The key fingerprint is:
 > SHA256:/hk7MJ5n5aiqdfTVUZr+2Qt+qCiS7BIm5Iv0dxrc3ks user@host
 > The key's randomart image is:
 > +---[RSA 3072]----+
 > |                .|
 > |               + |
 > |              +  |
 > | .           o . |
 > |o       S   . o  |
 > | + o. .oo. ..  .o|
 > |o = oooooEo+ ...o|
 > |.. o *o+=.*+o....|
 > |    =+=ooB=o.... |
 > +----[SHA256]-----+
 > ```

To display the content of your id_rsa.pub key, type this into your local computer:

``` bash
cat ~/.ssh/id_rsa.pub
```

You will see the key’s content, which should look something like this:

> ```
> ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqql6MzstZYh1TmWWv11q5O3pISj2ZFl9HgH1JLknLLx44+tXfJ7mIrKNxOOwxIxvcBF8PXSYvobFYEZjGIVCEAjrUzLiIxbyCoxVyle7Q+bqgZ8SeeM8wzytsY+dVGcBxF6N4JS+zVk5eMcV385gG3Y6ON3EG112n6d+SMXY0OEBIcO6x+PnUSGHrSgpBgX7Ks1r7xqFa7heJLLt2wWwkARptX7udSq05paBhcpB0pHtA1Rfz3K2B+ZVIpSDfki9UVKzT8JUmwW6NNzSgxUfQHGwnW7kj4jp4AT0VZk3ADw497M2G/12N0PPB5CnhHf7ovgy6nL1ikrygTKRFmNZISvAcywB9GVqNAVE+ZHDSCuURNsAInVzgYo9xgJDW8wUw2o8U77+xiFxgI5QSZX3Iq7YLMgeksaO4rBJEa54k8m5wEiEE1nUhLuJ0X/vh2xPff6SQ1BL/zkOhvJCACK6Vb15mDOeCSq54Cr7kvS46itMosi/uS66+PujOO+xt/2FWYepz6ZlN70bRly57Q06J+ZJoc9FfBCbCyYH7U/ASsmY095ywPsBo1XQ9PqhnN1/YOorJ068foQDNVpm146mUpILVxmq41Cj55YKHEazXGsdBIbXWhcrRf4G2fJLRcGUr9q8/lERo9oxRm5JFX6TCmj6kmiFqv+Ow9gI0x8GvaQ== demo@test
> ```

## Copy Key to Server [Server]

Create ```~/.ssh``` directory (if it doesn't exist)

``` bash
mkdir -p ~/.ssh
```

Create or modify the authorized_keys file within this directory. You can add the contents of your `id_rsa.pub` file to
the
end of the `authorized_keys` file, creating it if necessary, using this command:

``` bash
echo public_key_string >> ~/.ssh/authorized_keys
```

In the above command, substitute the public_key_string with the output from the ```cat ~/.ssh/id_rsa.pub``` command that
you executed on your local system. It should start with ```ssh-rsa AAAA....```

## Set Permissions

Finally, we’ll ensure that the` ~/.ssh` directory and authorized_keys file have the appropriate permissions set:

``` bash
chmod -R go= ~/.ssh
```

This recursively removes all “group” and “other” permissions for the `~/.ssh/` directory.

If you’re using the root account to set up keys for a user account, it’s also important that the `~/.ssh` directory
belongs to the user and not to root:

``` bash
chown -R newuser:newuser ~/.ssh
```

In this tutorial our user is named `newuser`, but you should substitute the appropriate username into the above command.

## Disable Password Authentication

Now that your new user can log in using SSH keys, you can increase your server’s security by disabling password-only
logins. This means that remote logins cannot use a password to authenticate.

Open up the SSH daemon’s configuration file:

``` bash
sudo nano /etc/ssh/sshd_config
```

Inside the file, search for a directive called ```PasswordAuthentication``` and change it to `no`
This will disable your ability to log in via SSH using account passwords:

```
PasswordAuthentication yes // [!code --]
PasswordAuthentication no // [!code ++]
```

To actually activate these changes, we need to restart the sshd service:

``` bash
sudo systemctl restart ssh
```

---
::: details Sources:  
[How to Set Up SSH Keys on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-22-04)
:::
