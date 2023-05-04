---
title: "Install and Configure msmtp for Sending Emails in Linux"
description: "Configure and install the SMTP client msmtp to send emails from the command line using the terminal."
---

# {{ $frontmatter.title }}

## Introduction

msmtp is an SMTP client that helps send mails from Mutt and other mail user agents. It transmits mails to an SMTP
server, which in turn takes care of further delivery.

## Install msmtp
To install msmtp, you can run the following command in your terminal:
``` bash
sudo apt-get install msmtp msmtp-mta mailutils
```

The `msmtp` package contains the SMTP client, while `msmtp-mta` and `mailutils` packages provide the necessary utilities for sending and receiving mail.

## Configuration

Create an **Systemwide** MSMTP configuration in the following file

``` bash
sudo nano /etc/msmtprc
```
:::info
**With this configuration only the root user can send mails**
:::

The Content of the Configuration File should be the following:

Fields marked with `# TODO` have to be replaced with your own Values

::: code-group
``` [/etc/msmtprc]
# Set default values for all following accounts.
defaults

# Use the mail submission port 587 instead of the SMTP port 25.
port 587

# Always use TLS.
tls on

# Set a list of trusted CAs for TLS. The default is to use system settings, but
# you can select your own file.
#tls_trust_file /etc/ssl/certs/ca-certificates.crt

# If you select your own file, you should also use the tls_crl_file command to
# check for revoked certificates, but unfortunately getting revocation lists and
# keeping them up to date is not straightforward.
#tls_crl_file ~/.tls-crls

# Mail account
# TODO: Use your own mail address // [!code focus]
account bob@meindedomain.de // [!code focus]

# Host name of the SMTP server
# TODO: Use the host of your own mail account // [!code focus]
host smtp.meindedomain.de // [!code focus]

# This is especially important for mail providers like 
# Ionos, 1&1, GMX and web.de
set_from_header on

# As an alternative to tls_trust_file/tls_crl_file, you can use tls_fingerprint
# to pin a single certificate. You have to update the fingerprint when the
# server certificate changes, but an attacker cannot trick you into accepting
# a fraudulent certificate. Get the fingerprint with
# $ msmtp --serverinfo --tls --tls-certcheck=off --host=smtp.freemail.example
#tls_fingerprint 00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33

# Envelope-from address
# TODO: Use your own mail address // [!code focus]
from bob@meindedomain.de // [!code focus]

# Authentication. The password is given using one of five methods, see below.
auth on

# TODO: Use your own user name fpr the mail account // [!code focus]
user bob@meindedomain.de // [!code focus]

# Password method 1: Add the password to the system keyring, and let msmtp get
# it automatically. To set the keyring password using Gnome's libsecret:
# $ secret-tool store --label=msmtp \
#   host smtp.freemail.example \
#   service smtp \
#   user joe.smith

# Password method 2: Store the password in an encrypted file, and tell msmtp
# which command to use to decrypt it. This is usually used with GnuPG, as in
# this example. Usually gpg-agent will ask once for the decryption password.
#passwordeval gpg2 --no-tty -q -d ~/.msmtp-password.gpg

# Password method 3: Store the password directly in this file. Usually it is not
# a good idea to store passwords in plain text files. If you do it anyway, at
# least make sure that this file can only be read by yourself.
# TODO: Use the password of your own mail account // [!code focus]
password pAssW0Rd123 // [!code focus]

# Password method 4: Store the password in ~/.netrc. This method is probably not
# relevant anymore.

# Password method 5: Do not specify a password. Msmtp will then prompt you for
# it. This means you need to be able to type into a terminal when msmtp runs.

# Set a default account
# TODO: Use your own mail address // [!code focus]
account default: bob@meindedomain.de // [!code focus]

# Map local users to mail addresses (for crontab)
aliases /etc/aliases
```
:::

> TODO -> Move to Password method 2

To be able to send mails as a nonroot user you can now copy the file to your home folder

``` bash
sudo cp /etc/msmtprc ~/.msmtprc
```

Next we make sure that not everyone has access to the files (especially important if the password is stored directly in
the configuration):

``` bash
sudo chmod 600 /etc/msmtprc
chmod 600 ~/.msmtprc
```

Finally, an alias is created so that the recipient address of the root account (or the account that will later be used
to send e-mail) is known. This is specified in the file that is also listed at the very end of the configuration of
msmtp:

``` bash
sudo nano /etc/aliases
```

The recipient address of the root account is now specified here. E-Mails will now be sent to this address if, for
example, a cron job should fail. In addition, a general "fallback recipient address" is specified if system messages do
not occur in the context of the root account:

::: code-group
``` [/etc/aliases]
root: admin@meinedomain.de
default: admin@meinedomain.de
```
:::

## Set As Default Mail Program

Before a first test mail can be sent, the mail program must be defined:

``` bash
sudo nano /etc/mail.rc
```

The content looks like this:

::: code-group
``` [/etc/mail.rc]
set sendmail="/usr/bin/msmtp -t"
```
:::

## Send Mail

After msmtp has been configured, e-mails can now be sent easily via the command line:

``` bash
echo "Content of email" | mail -s "Subject" test@mail.de
```

---
::: details Sources:  
[Linux: Einfach E-Mails versenden mit msmtp](https://decatec.de/linux/linux-einfach-e-mails-versenden-mit-msmtp/)  
[Raspberry Pi – E-Mails versenden mit msmtp](https://goneuland.de/raspberry-pi-e-mails-versenden-mit-msmtp/)  
[MSMTP - E-Mails einfach versenden unter Linux](https://www.laub-home.de/wiki/MSMTP_-_E-Mails_einfach_versenden_unter_Linux)
:::
