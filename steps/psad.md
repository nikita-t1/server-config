---
title: Port Scan Attack Detector (PSAD)
description: Port Scan Attack Detector (PSAD) is a collection of lightweight system daemons that run on Linux system and analyze iptables log messages to detect port scans and other suspicious traffic.
---

# {{ $frontmatter.title }}

## Introduction

PSAD also known as Port Scan Attack Detector is a collection of lightweight system daemons that run on Linux system and
analyze iptables log messages to detect port scans and other suspicious traffic.

PSAD is used to change an Intrusion Detection System into an Intrusion Prevention System. PSAD uses Snort rules for the
detection of intrusion events.

It is specially designed to work with Linux iptables/firewalld to detect suspicious traffic such as, port scans,
backdoors and botnet command.

## Install psad

``` bash
sudo apt install psad
```

## Configure psad to Detect Scans

Open the main psad configuration file with root privileges:

``` bash
sudo nano /etc/psad/psad.conf
```

The first things you should modify are at the top of the file. You should change the `EMAIL_ADDRESSES` parameter to match
the email addresses you would like to notify when a report is generated. You should also modify the `HOSTNAME` to match
your server's hostname so that it references the correct machine:

::: code-group
``` [/etc/psad/psad.conf]

EMAIL_ADDRESSES     address1@domain.com, address2@other.com;
HOSTNAME            Node1;
```
:::
::: code-group
``` [/etc/psad/psad.conf]

ENABLE_PSADWATCHD Y;
ENABLE_AUTO_IDS Y;
ENABLE_AUTO_IDS_EMAILS Y;
EXPECT_TCP_OPTIONS Y;
```
:::

## Configure ufw for psad

Now we need to make some changes to ufw so it works with psad by telling `ufw` to log all traffic so `psad` can analyze it.

Make backups:

``` bash
sudo cp --archive /etc/ufw/before.rules /etc/ufw/before.rules-COPY-$(date +"%Y%m%d%H%M%S")
sudo cp --archive /etc/ufw/before6.rules /etc/ufw/before6.rules-COPY-$(date +"%Y%m%d%H%M%S")
```

Edit the files:

- /`etc/ufw/before.rules`
- `/etc/ufw/before6.rules`

And add this at the end but <a style="color:goldenrod;">before</a> the `COMMIT` line:

::: code-group
``` [/etc/ufw/before.rules]
# log all traffic so psad can analyze
-A INPUT -j LOG --log-tcp-options --log-prefix "[IPTABLES] "
-A FORWARD -j LOG --log-tcp-options --log-prefix "[IPTABLES] "
```
``` [/etc/ufw/before6.rules]
# log all traffic so psad can analyze
-A INPUT -j LOG --log-tcp-options --log-prefix "[IPTABLES] "
-A FORWARD -j LOG --log-tcp-options --log-prefix "[IPTABLES] "
```
:::

::: tip
We're adding a log prefix to all the iptables logs. We'll need this
for [seperating iptables logs to their own file](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#ns-separate-iptables-log-file).

For example:

```
...

# log all traffic so psad can analyze
-A INPUT -j LOG --log-tcp-options --log-prefix "[IPTABLES] "
-A FORWARD -j LOG --log-tcp-options --log-prefix "[IPTABLES] "

# don't delete the 'COMMIT' line or these rules won't be processed
COMMIT
```
:::


Now we need to reload/restart ufw and psad for the changes to take effect:

``` bash
sudo ufw reload

sudo psad -R
sudo psad --sig-update
sudo psad -H
```

Analyze iptables rules for errors:

``` bash
sudo psad --fw-analyze
```

```
[+] Parsing INPUT chain rules.
[+] Parsing INPUT chain rules.
[+] Firewall config looks good.
[+] Completed check of firewall ruleset.
[+] Results in /var/log/psad/fw_check
[+] Exiting.
```

## Status

Check the status of psad:

``` bash
sudo psad --Status
```

```
[-] psad: pid file /var/run/psad/psadwatchd.pid does not exist for psadwatchd on vm
[+] psad_fw_read (pid: 3444)  %CPU: 0.0  %MEM: 2.2
    Running since: Sat Feb 16 01:03:09 2019

[+] psad (pid: 3435)  %CPU: 0.2  %MEM: 2.7
    Running since: Sat Feb 16 01:03:09 2019
    Command line arguments: [none specified]
    Alert email address(es): root@localhost

[+] Version: psad v2.4.3

[+] Top 50 signature matches:
        [NONE]

[+] Top 25 attackers:
        [NONE]

[+] Top 20 scanned ports:
        [NONE]

[+] iptables log prefix counters:
        [NONE]

    Total protocol packet counters:

[+] IP Status Detail:
        [NONE]

    Total scan sources: 0
    Total scan destinations: 0

[+] These results are available in: /var/log/psad/status.out
```

---
::: details Sources:  
[iptables Intrusion Detection And Prevention with PSAD](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#iptables-intrusion-detection-and-prevention-with-psad)  
[How To Use psad to Detect Network Intrusion Attempts on an Ubuntu VPS](https://www.digitalocean.com/community/tutorials/how-to-use-psad-to-detect-network-intrusion-attempts-on-an-ubuntu-vps)  
:::
