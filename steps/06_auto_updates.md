---
title: "Automate Critical Security Patches and Updates for your Server"
description: "Automatically update and secure your server by installing and configuring `unattended-upgrades`, `apt-listchanges`, and `apticron`."
---

# {{ $frontmatter.title }}

## Introduction

It is important to keep a server updated with the latest critical security patches and updates. Otherwise you're at risk
of known security vulnerabilities that bad-actors could use to gain unauthorized access to your server.

Unless you plan on checking your server every day, you'll want a way to automatically update the system and/or get
emails about available updates.

You don't want to do all updates because with every update there is a risk of something breaking. It is important to do
the critical updates but everything else can wait until you have time to do it manually.

## Install
To set up automatic updates, you can run the following command in your terminal:

``` bash
sudo apt install unattended-upgrades apt-listchanges apticron
```

- **`unattended-upgrades`** to automatically do system updates you want (i.e. critical security updates)
- **`apt-listchanges`** to get details about package changes before they are installed/upgraded
- **`apticron`** to get emails for pending package updates

::: info
We will use unattended-upgrades to apply critical security patches. We can also apply stable updates since they've
already been thoroughly tested by the Debian community.
:::

## Configure unattended-upgrades

Now we need to configure unattended-upgrades to automatically apply the updates. This is typically done by editing the
files ```/etc/apt/apt.conf.d/20auto-upgrades``` and ```/etc/apt/apt.conf.d/50unattended-upgrades``` that were created by
the packages. However, because these file may get overwritten with a future update, we'll create a new file instead.

Create the file ```/etc/apt/apt.conf.d/51myunattended-upgrades```

``` bash
sudo nano /etc/apt/apt.conf.d/51myunattended-upgrades
```

and add this:

```
// Enable the update/upgrade script (0=disable)
APT::Periodic::Enable "1";

// Do "apt-get update" automatically every n-days (0=disable)
APT::Periodic::Update-Package-Lists "1";

// Do "apt-get upgrade --download-only" every n-days (0=disable)
APT::Periodic::Download-Upgradeable-Packages "1";

// Do "apt-get autoclean" every n-days (0=disable)
APT::Periodic::AutocleanInterval "7";

// Send report mail to root
//     0:  no report             (or null string)
//     1:  progress report       (actually any string)
//     2:  + command outputs     (remove -qq, remove 2>/dev/null, add -d)
//     3:  + trace on    APT::Periodic::Verbose "2";
APT::Periodic::Unattended-Upgrade "1";

// Automatically upgrade packages from these
Unattended-Upgrade::Origins-Pattern {
      "o=Debian,a=stable";
      "o=Debian,a=stable-updates";
      "origin=Debian,codename=${distro_codename},label=Debian-Security";
};

// You can specify your own packages to NOT automatically upgrade here
Unattended-Upgrade::Package-Blacklist {
};

// Run dpkg --force-confold --configure -a if a unclean dpkg state is detected to true to ensure that updates get installed even when the system got interrupted during a previous run
Unattended-Upgrade::AutoFixInterruptedDpkg "true";

//Perform the upgrade when the machine is running because we wont be shutting our server down often
Unattended-Upgrade::InstallOnShutdown "false";

// Send an email to this address with information about the packages upgraded.
Unattended-Upgrade::Mail "root";

// Always send an e-mail
Unattended-Upgrade::MailReport "on-change";

// Remove all unused dependencies after the upgrade has finished
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Remove any new unused dependencies after the upgrade has finished
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

// Automatically reboot WITHOUT CONFIRMATION if the file /var/run/reboot-required is found after the upgrade.
Unattended-Upgrade::Automatic-Reboot "true";

// Automatically reboot even if users are logged in.
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
```

Run a dry-run of unattended-upgrades to make sure your configuration file is okay:

``` bash
sudo unattended-upgrade -d --dry-run
```

If everything is okay, you can let it run whenever it's scheduled to or force a run with ```unattended-upgrade -d```.

The current schedule can be viewed in:

``` bash
/etc/apt/apt.conf.d/20auto-upgrades
```

With the default beeing:

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

Which means that Unattended Upgrade will run every 1 day. If the number is "0" then unattended upgrades are disabled.

## Configure apt-listchanges

Configure apt-listchanges to your liking:

``` bash
sudo dpkg-reconfigure apt-listchanges
```

## Configure apticron
Open the `apticron` config file located in `/usr/lib/apticron/apticron.conf` and change the following 2 lines:

```
EMAIL="root"  // [!code --]
EMAIL="bob.yourdomain.com" // [!code ++]
```
```
NOTIFY_NO_UPDATES="0" // [!code --]
NOTIFY_NO_UPDATES="1" // [!code ++]
```

To see if it works, you can send a mail with apticron with the following command:

``` bash
sudo apticron
```

Sample Report

```
apticron report [Wed, 17 Mar 2010 10:44:39 +0100] 
========================================================================

apticron has detected that some packages need upgrading on: 

	apticron.test.de 
	[ 192.168.1.8 ]

The following packages are currently pending an upgrade:

	libcupsys2 1.3.7-1ubuntu3.9

========================================================================

Package Details:

Lese Changelogs...
--- Änderungen für cupsys (libcupsys2) --- cupsys (1.3.7-1ubuntu3.9) hardy-proposed; urgency=low

   * debian/patches/fix-lpstat.dpatch: Fix lpstat to work correctly against
     CUPS 1.4 servers. (LP: #497606)

 -- Evan Broder <broder@mit.edu>  Wed, 03 Mar 2010 18:06:14 -0500

========================================================================

You can perform the upgrade by issuing the command:

	aptitude dist-upgrade

as root on apticron.test.de

It is recommended that you simulate the upgrade first to confirm that the actions that would be taken are reasonable. The upgrade may be simulated by issuing the command:

	aptitude -s -y dist-upgrade

--
apticron
```

---
::: details Sources:  
[Unattended upgrades](https://github.com/mvo5/unattended-upgrades)  
[Automatic Security Updates and Alerts](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#automatic-security-updates-and-alerts)  
[Debian / Ubuntu Linux: Send Automatic Email Notification When Security Upgrades Available](https://www.cyberciti.biz/faq/apt-get-apticron-send-email-upgrades-available/)
:::
