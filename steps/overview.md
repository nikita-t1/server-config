---
title: Overview
description: "Overview of the steps in this tutorial."
---

# {{ $frontmatter.title }}

In this tutorial, we will cover a variety of topics related to configuring a Linux server. We will start by setting up
[Cloudflare DNS](cloudflare_dns.md) for our server, which provides a secure and reliable way to manage DNS records.

Next, we will create an [unprivileged user](add_unprivileged_user.md), to run our server processes, which helps to
improve security. We will then
configure [SSH settings](ssh_security_settings.md) and enable [MFA (multi-factor authentication)](ssh_totp.md) for
SSH to further enhance server security, including setting up [SSH keys](ssh_keys.md) for secure login.

We will also set up an [SMTP mail server](msmtp.md) to enable email notifications for system events, as well
as [automate unattended
updates](auto_updates.md) to keep our system up-to-date.

To improve our command line experience, we will explore some [awesome shell utilities](install_software.md),
including some popular tools that
can boost productivity and make it easier to work with the command line.

We will also configure [uncomplicated firewall](ufw.md) and implement [Cloudflare WAF](ufw_cloudflare.md) (Web
Application Firewall) to help protect
our server from common web application attacks.

To prevent unauthorized access to our server, we will use a [port scan attack detector](psad.md)
and [Fail2ban](fail2ban.md), a tool that can
automatically block IP addresses that have been identified as malicious.

Finally, we will explore some additional topics that can be useful for server administrators, including configuring the
[.bashrc file](bash_config.md), setting up a [WireGuard VPN](wireguard.md), and using [Docker](docker.md)
and [Portainer](portainer.md) to manage containerized applications.

By the end of this tutorial, you will have a solid understanding of how to configure a Linux server and implement best
practices for security and system management.

::: info
While many of the Steps in this Documentation are self-contained it is recommended to view them all in the order they
are listed
:::
