---
title: "Set Up a Firewall with UFW on Linux"
description: "Learn how to secure your network with UFW, a simplified firewall management interface that configures iptables rules to allow or deny traffic to/from ports."
---

# {{ $frontmatter.title }}

## Introduction

UFW, or Uncomplicated Firewall, is a simplified firewall management interface that hides the complexity of lower-level
packet filtering technologies such as ```iptables``` and ```nftables```. If you’re looking to get started securing your
network, and you’re not sure which tool to use, UFW may be the right choice for you.

## Firewall With UFW (Uncomplicated Firewall)

The Linux kernel provides capabilities to monitor and control network traffic. These capabilities are exposed to the
end-user through firewall utilities. Think of UFW as a front-end to iptables. It simplifies the process of managing the
iptables rules that tell the Linux kernel what to do with network traffic.

UFW works by letting you configure rules that:

- allow or deny
- input or output traffic
- to or from ports

Install UFW

``` bash
sudo apt install ufw
```

## Traffic Rules

Allow all outgoing traffic

``` bash
sudo ufw default allow outgoing comment 'allow all outgoing traffic'
```

Deny all incoming traffic

``` bash
sudo ufw default deny incoming comment 'deny all incoming traffic'
```

Allow specified incoming traffic

``` bash
sudo ufw limit 22/tcp comment 'allow SSH connections in' # Allow SSH
sudo ufw allow 80/tcp comment 'allow HTTP traffic out' # Allow HTTP
sudo ufw allow https comment 'allow HTTPS traffic out' # Allow HTTPS
sudo ufw allow out 587/tcp comment 'open TLS port 587 for use with SMPT to send e-mails' # Allow SMTP through TLS
```

::: info
If you use the port number by itself, it effects tcp and udp as well
:::

## Status

Start ufw

``` bash
sudo ufw enable
```

> ```
> Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
> Firewall is active and enabled on system startup
> ```

Status

``` bash
sudo ufw status verbose
```

> ```
> Status: active
> Logging: on (low)
> Default: deny (incoming), deny (outgoing), disabled (routed)
> New profiles: skip
>
> To                         Action      From
> --                         ------      ----
> 22/tcp                     LIMIT IN    Anywhere                   # allow SSH connections in
> 22/tcp (v6)                LIMIT IN    Anywhere (v6)              # allow SSH connections in
>
> 53                         ALLOW OUT   Anywhere                   # allow DNS calls out
> 123                        ALLOW OUT   Anywhere                   # allow NTP out
> 80/tcp                     ALLOW OUT   Anywhere                   # allow HTTP traffic out
> 443/tcp                    ALLOW OUT   Anywhere                   # allow HTTPS traffic out
> 21/tcp                     ALLOW OUT   Anywhere                   # allow FTP traffic out
> 587/tcp (Mail submission)  ALLOW OUT   Anywhere                   # allow mail out
> 43/tcp                     ALLOW OUT   Anywhere                   # allow whois
> 53 (v6)                    ALLOW OUT   Anywhere (v6)              # allow DNS calls out
> 123 (v6)                   ALLOW OUT   Anywhere (v6)              # allow NTP out
> 80/tcp (v6)                ALLOW OUT   Anywhere (v6)              # allow HTTP traffic out
> 443/tcp (v6)               ALLOW OUT   Anywhere (v6)              # allow HTTPS traffic out
> 21/tcp (v6)                ALLOW OUT   Anywhere (v6)              # allow FTP traffic out
> 587/tcp (Mail submission (v6)) ALLOW OUT   Anywhere (v6)              # allow mail out
> 43/tcp (v6)                ALLOW OUT   Anywhere (v6)              # allow whois
> ```

## Using IPv6 with UFW

If your Virtual Private Server (VPS) is configured for IPv6, ensure that UFW is configured to support IPv6 so that it
configures both your IPv4 and IPv6 firewall rules. To do this, open the UFW configuration file in your preferred text
editor.

``` bash
sudo nano /etc/default/ufw
```

Confirm that IPV6 is set to yes:

```
# Set to yes to apply rules to support IPv6 (no means only IPv6 on loopback
# accepted). You will need to 'disable' and then 'enable' the firewall for
# the changes to take affect.
IPV6=no // [!code --]
IPV6=yes // [!code ++]
…
```

Now restart your firewall by first disabling it:

``` bash
sudo ufw disable
```

> ```
> Output
> Firewall stopped and disabled on system startup
> ```

Then enable it again:

``` bash
sudo ufw enable
```

> ```
> Output
> Firewall is active and enabled on system startup
> ```

---
::: details Sources:  
[How To Set Up a Firewall with UFW on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-22-04)  
[How To Setup a Firewall with UFW on an Ubuntu and Debian Cloud Server](https://www.digitalocean.com/community/tutorials/how-to-setup-a-firewall-with-ufw-on-an-ubuntu-and-debian-cloud-server)  
[The Network](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#the-network)
:::
