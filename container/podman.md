---
title: Podman
description: Podman is a daemonless container engine for developing, managing, and running Open Container Initiative (OCI) containers and container images on your Linux System.
---

# {{ $frontmatter.title }}

## Introduction

Podman is a daemonless container engine for developing, managing, and running Open Container Initiative (OCI) containers and container images on your Linux System.

It supports running containers as a non-root user, which makes it more secure than Docker.

Podman provides a Docker-compatible command-line frontend that can simply alias the Docker CLI to Podman. Podman also provides a Docker-compatible RESTful API.

## Installation

Podman is available in the official repositories of most Linux distributions. You can install it using the package manager of your distribution.

### Ubuntu

``` bash
sudo apt update
sudo apt install podman
```

## Quadlet

Quadlet lets you run your Podman containers as systemd services. This is especially useful for running containers in the background and automatically starting them after a server reboot.

First, you create the directory `~/.config/containers/systemd`. Then, you place your `.container` file(s) inside it.

### Example

``` ini
[Container]
Image=docker.io/library/postgres:16
AutoUpdate=registry
PublishPort=5432:5432
Volume=%h/volumes/test-db:/var/lib/postgresql/data:Z
Environment=POSTGRES_PASSWORD=CHANGE_ME

[Service]
Restart=always

[Install]
WantedBy=default.target
```

### Explanation
It is a normal systemd service file but with the special section `[Container]`.
Almost all these options map to command line options that can be used to create a container with Podman (`podman create`). 

The ones that we are interested in for the example are the following:

- `Image` specifies the image (with tag) to use
- `AutoUpdate`=registry maps to `--label "io.containers.autoupdate=registry"`
- `PublishPort` maps to `-p`
- `Volume` maps to `-v`
- `Environment` maps to `-e`

It is important to use the systemd specifier %h instead of ~ for the user home directory.

In the `[Service]` section, we use the Restart option and set it to always restart the container (unless stopped manually).

To automatically start the container on boot, we set the WantedBy option in the `[Install]` section to default.target.

::: info
Setting `WantedBy` to `multi-user.target` doesn't work in the case of rootless containers.
`multi-user.target` is not defined in the user mode in systemd. 

You can verify this by running the command `systemctl --user status multi-user.target`. 
It is only defined in the system mode (`systemctl status multi-user.target` without `--user`).
:::

### Refresh systemd

For systemd to discover the new service file, run:
```bash
systemctl --user daemon-reload
```

Now, you can start the container with 
```bash 
systemctl --user start test-db.service
```

You can check the status of the container service by running 
```bash
systemctl --user status test-db.service
```

You can also verify that the Podman container is running by running 
```bash
podman ps
```
You should find the container `systemd-test-db`.

### Start systemd service

To start the systemd service, run 
```bash
systemctl --user start test-db.service
```

## Configuration

### Enable Linger
Since we use user services for systemd, we have to enable the linger for our user to start the containers without the user being logged in:
```bash 
loginctl enable-linger 
```

::: info
When lingering is enabled for a user, the systemd user instance for that user is started at boot and remains active,
allowing any units in that user's systemd directories, that are configured to start at boot, to be launched.
:::

### Use Ports below 1024

By default, ports less than 1024 are reserved for root users for security reasons and rootless users are not allowed to use them.
But if you want to use ports below 1024, you can change the default value by making changes to the file /etc/sysctl.conf.

Run the command `sysctl net.ipv4.ip_unprivileged_port_start=xxx` as root user(or as any privileged user) and now the rootless user can use any port higher than the value specified in the above command.


One other way to do this is to manually add the entry to the file `/etc/sysctl.conf`. Add the below lines to the file,
`net.ipv4.ip_unprivileged_port_start=xxx`
where `xxx` is the port number from which the rootless user can start using the ports.

After adding the above line, run the command `sysctl -p` to apply the changes.

## Updating Containers

Podman ships with a built-in feature to automatically update containers. 

You can enable this feature by setting the `AutoUpdate` option in the `.container` file to `registry`.

``` ini
[Container]
AutoUpdate=registry
```

To manually update a container, run 
```bash
systemctl --user start podman-auto-update.service
```

The update service is by default only enabled for root containers.
To enable it for rootless containers, run 
```bash  
systemctl --user enable podman-auto-update.service
```

The update service is triggered daily at midnight by the podman-auto-update.timer systemd timer.
The timer is also disabled by default for rootless containers. To enable it, run 
```bash
systemctl --user enable podman-auto-update.timer
```
```bash
systemctl --user start podman-auto-update.timer
```

The timer can be altered for custom time-based updates if desired.




::: details Sources:  
[ Rootless podman is unable to use host ports less than 1024 ](https://access.redhat.com/solutions/7044059)  
[ Quadlet: Running Podman containers under systemd ](https://mo8it.com/blog/quadlet/)  
[ Using Traefik with Podman ](https://blog.cthudson.com/2023-11-02-running-traefik-with-podman/)  
[ Deploying a multi-container application using Podman and Quadlet ](https://www.redhat.com/sysadmin/multi-container-application-podman-quadlet)  
[ systemd/User ](https://wiki.archlinux.org/title/Systemd/User#Automatic_start-up_of_systemd_user_instances)  
[ Podman - Quadlets ](https://blog.while-true-do.io/podman-quadlets/)  
[ Podlet ](https://github.com/containers/podlet/)  
[ podman-systemd.unit ](https://docs.podman.io/en/stable/markdown/podman-systemd.unit.5.html)  
:::
