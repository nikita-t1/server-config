---
title: "Configure Fail2ban to Secure Your Server"
description: "Learn how to configure and use Fail2ban to prevent potential intrusions by monitoring network traffic/logs and blocking suspicious activity."
---

# {{ $frontmatter.title }}

## Introduction

Fail2ban monitors the logs of your applications (like SSH and Apache) to detect and prevent potential intrusions.

It will monitor network traffic/logs and prevent intrusions by blocking suspicious activity (e.g. multiple successive
failed connections in a short time-span).

## Install

``` bash
sudo apt install fail2ban
```

## Configuration

Fail2ban is configured through several files located within a hierarchy under the ```/etc/fail2ban/``` directory.

By default, fail2ban ships with a `jail.conf` file. However, this can be overwritten in updates, so you should copy this
file to a `jail.local` file and make adjustments there.

``` bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

Now you can begin making configuration changes. Open the file in nano or your favorite text editor:

``` bash
sudo nano /etc/fail2ban/jail.local
```

Change the following:
> ``` bash
> bantime = 10min // [!code --]
> bantime = 24h // [!code ++]
> 
> findtime = 10 min // [!code --]
> findtime = 24h // [!code ++]
> 
> maxretry = 5 // [!code --]
> maxretry = 3 // [!code ++]
> ...
> banaction = iptables // [!code --]
> banaction = ufw // [!code ++]
> ```

- **`ignoreip`**: This parameter identifies IP addresses that should be ignored by the banning system. By default, this is
  just set to ignore traffic coming from the machine itself, so that you don’t fill up your own logs or lock yourself
  out.
- **`bantime`**: This parameter sets the length of a ban, in seconds. The default is 10 minutes.
- **`findtime`**: This parameter sets the window that Fail2ban will pay attention to when looking for repeated failed
  authentication attempts. The default is set to 10 minutes, which means that the software will count the number of
  failed attempts in the last 10 minutes.
- **`maxretry`**: This sets the number of failed attempts that will be tolerated within the findtime window before a ban
  is instituted.
- **`banaction`**: This tells fail2ban to use ufw as the banaction.

## Service Specific Sections

Next is the portion of the configuration file that deals with individual services. These are specified by section
headers, like ```[sshd]```.

Each of these sections needs to be enabled individually by adding an ```enabled = true``` line under the header, with
their other settings.

You can see what kind of filters are available by looking into that directory:

``` bash
ls /etc/fail2ban/filter.d
```

If you see a file that looks related to a service you are using, you should open it with a text editor. Most of the
files are fairly well commented and you should be able to at least tell what type of condition the script was designed
to guard against. Most of these filters have appropriate (disabled) sections in the ```jail.conf``` file that we can
enable in the ```jail.local``` file if desired.

For instance, imagine that you are serving a website using Nginx and realize that a password-protected portion of your
site is getting slammed with login attempts. You can tell fail2ban to use the ```nginx-http-auth.conf``` file to check
for this condition within the ```/var/log/nginx/error.log``` file.

This is actually already set up in a section called ```[nginx-http-auth]``` in your ```/etc/fail2ban/jail.conf``` file.
You would just need to add the enabled parameter:

```
/etc/fail2ban/jail.local

. . .
[nginx-http-auth]

enabled = true
. . .
```

## SSH Section

In the SSH Section:

- set ```enabled=true```

> On Debian, the Fail2Ban protection for the SSH service is the only one already enabled due to the content of
> the ```"/etc/fail2ban/jail.d/defaults-debian.conf"``` file, but it is not wrong if you use the ```"enabled"```
> parameter
> in your ```"jail.local"``` file to ```"true"``` anyway.

- set your SSH Port so that fail2ban knows which port to watch
- add ```banaction = ufw``` to tell fail2ban to use the ufw as the banaction

::: code-group
``` ssh-config [/etc/fail2ban/jail.local]
[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
#mode   = normal
enabled = true
banaction = ufw
port    = ssh,22222
logpath = %(sshd_log)s
backend = %(sshd_backend)s
```
:::

## Start fail2ban

When you are finished editing, save and close the file. At this point, you can enable your Fail2ban service so that it
will run automatically from now on. First, run systemctl enable:

``` bash
sudo systemctl enable fail2ban
```

Then, start it manually for the first time with systemctl start:

``` bash
sudo systemctl start fail2ban
```

You can verify that it’s running with systemctl status:

::: code-group
``` bash [Command]
sudo systemctl status fail2ban
```

> ``` yaml [Output]
> ● fail2ban.service - Fail2Ban Service
>      Loaded: loaded (/lib/systemd/system/fail2ban.service; enabled; vendor preset: enab>
>      Active: active (running) since Mon 2022-06-27 19:25:15 UTC; 3s ago
>        Docs: man:fail2ban(1)
>    Main PID: 39396 (fail2ban-server)
>       Tasks: 5 (limit: 1119)
>      Memory: 12.9M
>         CPU: 278ms
>      CGroup: /system.slice/fail2ban.service
>              └─39396 /usr/bin/python3 /usr/bin/fail2ban-server -xf start
> 
> Jun 27 19:25:15 fail2ban22 systemd[1]: Started Fail2Ban Service.
> Jun 27 19:25:15 fail2ban22 fail2ban-server[39396]: Server ready
> ```
:::
To restart fail2ban after a config change run:

``` bash
sudo systemctl restart fail2ban
```

All actions and measures taken by fail2ban are logged in the file ```/var/log/fail2ban.log```.  
To view the log file, use the following command

``` bash
sudo less /var/log/fail2ban.log
```

## Check Status

To check the status:

``` bash
sudo fail2ban-client status
```

> ```
>    Status
>    |- Number of jail:      1
>    `- Jail list:   sshd
>```

``` bash
sudo fail2ban-client status sshd
```

> ```
>    Status for the jail: sshd
>    |- Filter
>    |  |- Currently failed: 0
>    |  |- Total failed:     0
>    |  `- File list:        /var/log/auth.log
>    `- Actions
>       |- Currently banned: 0
>       |- Total banned:     0
>       `- Banned IP list:
>```

---
Sources:  
[How To Protect SSH with Fail2Ban on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-22-04)  
[Server absichern mit Fail2ban](https://www.ionos.de/hilfe/sicherheit/dedicated-server/server-absichern-mit-fail2ban/)  
[SSH-Server unter Linux mit Fail2Ban absichern](https://www.bennetrichter.de/anleitungen/ssh-server-fail2ban-linux/)  
[fail2ban](https://wiki.ubuntuusers.de/fail2ban/)  
[Fail2Ban Configuration](https://manpages.debian.org/testing/fail2ban/jail.conf.5.en.html)  
[Application Intrusion Detection And Prevention With Fail2Ban](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#application-intrusion-detection-and-prevention-with-fail2ban)
