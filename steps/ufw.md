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

UFW is installed by default on Ubuntu. If it has been uninstalled for some reason, you can install it with following
command:

``` bash
sudo apt install ufw
```

## Default Traffic Rules

If you’re just getting started with your firewall, the first rules to define are your default policies. These rules
control how to handle traffic that does not explicitly match any other rules.

By default, UFW is set to deny all
incoming connections and allow all outgoing connections. This means anyone trying to reach your server would not be able
to connect, while any application within the server would be able to reach the outside world.

Allow all outgoing traffic by running the command:

``` bash
sudo ufw default allow outgoing comment 'allow all outgoing traffic'
```

Deny all incoming traffic by running the command:

``` bash
sudo ufw default deny incoming comment 'deny all incoming traffic'
```

These commands set the defaults to deny incoming and allow outgoing connections. These firewall defaults alone might
suffice for a personal computer, but servers typically need to respond to incoming requests from outside users. We’ll
look into that next.

## Allowing Specific Traffic

If we enabled our UFW firewall now, it would deny all incoming connections. This means that we will need to create rules
that explicitly allow legitimate incoming connections — SSH or HTTP connections, for example — if we want our server to
respond to those types of requests. If you’re using a cloud server, you will probably want to allow incoming SSH
connections, so you can connect to and manage your server.

### Allow SSH Connections

To configure your server to allow incoming SSH connections, you can use this command:
`sudo ufw allow 22/tcp comment 'allow SSH connections in`

::: tip
ufw has the ability to deny connections from an IP address that has attempted to initiate 6 or more connections in the
last 30 seconds. This is useful for protecting against brute-force login attempts.
To enable rate limiting we would
simply replace the `allow` parameter with the `limit` parameter
:::

``` bash
sudo ufw limit 22/tcp comment 'allow SSH connections in'
```

::: info
If your SSH server is running on port `2222`, you could allow connections with the same syntax, but replace it with port
`2222`:  
`sudo ufw limit 2222/tcp comment 'allow SSH connections in'`

**Please note that if you use the port number by itself, it effects tcp and udp as well**
:::

### Allow HTTP and HTTPS Connections

To configure your server to allow incoming HTTP and HTTPS connections, you can use these commands:

``` bash
sudo ufw allow 80/tcp comment 'allow HTTP traffic out' # Allow HTTP
sudo ufw allow 443/tcp comment 'allow HTTPS traffic out' # Allow HTTPS
```

## Enable UFW

To enable UFW, use this command:

::: code-group

``` bash
sudo ufw enable
```

``` [output]
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
```

:::

You will receive a warning that says the command may disrupt existing SSH connections. You already set up a firewall
rule that allows SSH connections, so it should be fine to continue. Respond to the prompt with `y` and hit `ENTER`.

The firewall is now active. Run the `sudo ufw status verbose` command to see the rules that are set.

::: code-group

``` bash
sudo ufw status verbose
```

``` bash [output]
Status: active
Logging: on (low)
Default: deny (incoming), deny (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     LIMIT IN    Anywhere                   # allow SSH connections in
22/tcp (v6)                LIMIT IN    Anywhere (v6)              # allow SSH connections in

53                         ALLOW OUT   Anywhere                   # allow DNS calls out
123                        ALLOW OUT   Anywhere                   # allow NTP out
80/tcp                     ALLOW OUT   Anywhere                   # allow HTTP traffic out
443/tcp                    ALLOW OUT   Anywhere                   # allow HTTPS traffic out
21/tcp                     ALLOW OUT   Anywhere                   # allow FTP traffic out
587/tcp (Mail submission)  ALLOW OUT   Anywhere                   # allow mail out
43/tcp                     ALLOW OUT   Anywhere                   # allow whois
53 (v6)                    ALLOW OUT   Anywhere (v6)              # allow DNS calls out
123 (v6)                   ALLOW OUT   Anywhere (v6)              # allow NTP out
80/tcp (v6)                ALLOW OUT   Anywhere (v6)              # allow HTTP traffic out
443/tcp (v6)               ALLOW OUT   Anywhere (v6)              # allow HTTPS traffic out
21/tcp (v6)                ALLOW OUT   Anywhere (v6)              # allow FTP traffic out
43/tcp (v6)                ALLOW OUT   Anywhere (v6)              # allow whois
```

:::

## Using IPv6 with UFW

If your Virtual Private Server (VPS) is configured for IPv6, ensure that UFW is configured to support IPv6 so that it
configures both your IPv4 and IPv6 firewall rules. To do this, open the UFW configuration file in your preferred text
editor.

``` bash
sudo nano /etc/default/ufw
```

Confirm that IPV6 is set to yes:

::: code-group
``` bash [/etc/default/ufw]
# Set to yes to apply rules to support IPv6 (no means only IPv6 on loopback
# accepted). You will need to 'disable' and then 'enable' the firewall for
# the changes to take affect.
IPV6=no // [!code --]
IPV6=yes // [!code ++]
```
:::

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
