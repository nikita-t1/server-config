---
title: "Install and Configure Portainer"
description: "Learn how to install and configure Portainer to manage your Docker Containers."
---

# {{ $frontmatter.title }}

## Introduction

[Portainer](https://www.portainer.io/) is a containerized web app for managing containerized apps. It gives you a user
interface to manage your containerized applications for both local and cloud environments. This reduces the need for
command line interfaces.

## Deployment

First, create the volume that Portainer Server will use to store its database:

``` bash
docker volume create portainer_data
```

Then, download and install the Portainer Server container:

``` bash
docker run -d -p 127.0.0.1:9443:9443 --network shared-docker-network --ip 192.168.80.2 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
```

::: info
If your Server only has a IPv6 Address use the following command:

``` bash
docker run -d -p 127.0.0.1:9443:9443 --network shared-docker-network --ip 192.168.80.2 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data registry.ipv6.docker.com/portainer/portainer-ce:latest
```  

See [docker-with-ipv6](docker.md#docker-with-ipv6)
:::

::: tip
By default, Portainer generates and uses a self-signed SSL certificate to secure port 9443. Alternatively you can
provide your own SSL
certificate [during installation](https://docs.portainer.io/advanced/ssl#using-your-own-ssl-certificate-on-docker-standalone)
or [vie Portainer UI](https://docs.portainer.io/admin/settings#ssl-certificate) after installation is complete.
:::

Portainer Server has now been installed. You can check to see whether the Portainer Server container has started by
running `docker ps`:
> ```
> root@server:~# docker ps
> CONTAINER ID   IMAGE                          COMMAND                  CREATED       STATUS       PORTS                                                                                  NAMES             
> de5b28eb2fa9   portainer/portainer-ee:latest  "/portainer"             2 weeks ago   Up 9 days   0.0.0.0:8000->8000/tcp,  :::8000->8000/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp   portainer
> ```

## Log In

<!-- ~~Because the Container runs only on localhost, we need to find out the internal IP of the Container to connect to it.
This command returns the IP Address of the Docker Container running Portainer~~

~~``` bashdocker inspect -f '{{range.NetworkSettings.Networks}} {{.IPAddress}}{{end}}' portainer```~~ -->

Because the Container is only available locally you need to set up and activate your WireGuard Connection as described
in [Step 13 (WireGuard)](wireguard.md) and then you can open the Portainer Web UI by typing `192.168.80.2:9443`
in your browser.

---
::: details Sources:  
[Portainer unter Docker installieren](https://www.ionos.de/digitalguide/server/konfiguration/portainer-unter-docker-installieren/)  
[Install Portainer with Docker on Linux](https://docs.portainer.io/start/install/server/docker/linux)  
[Uncomplicated Firewall (UFW) is not blocking anything when using Docker](https://askubuntu.com/questions/652556/uncomplicated-firewall-ufw-is-not-blocking-anything-when-using-docker)  
[How to get a Docker container's IP address from the host](https://stackoverflow.com/questions/17157721/how-to-get-a-docker-containers-ip-address-from-the-host)  
[Docker und ufw](https://gnulinux.ch/docker-und-ufw)
:::
