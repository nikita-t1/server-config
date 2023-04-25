# Introduction

Docker is an application that simplifies the process of managing application processes in containers. Containers let you
run your applications in resource-isolated processes. They’re similar to virtual machines, but containers are more
portable, more resource-friendly, and more dependent on the host operating system.

# Install

The Docker installation package available in the official Ubuntu repository **may not be the latest version**.  
For this reason, the following command is not recommended:
~~```sudo apt-get install docker.io```~~

To ensure we get the latest version, we’ll install Docker from the official Docker repository. To do that, we’ll add a
new package source, add the GPG key from Docker to ensure the downloads are valid, and then install the package.

First, update your existing list of packages:

``` bash
sudo apt update
```

Next, install a few prerequisite packages which let apt use packages over HTTPS:

``` bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

Then add the GPG key for the official Docker repository to your system:

``` bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

Add the Docker repository to APT sources:

``` bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update your existing list of packages again for the addition to be recognized:

``` bash
sudo apt update
```

Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:

``` bash
apt-cache policy docker-ce
```

You’ll see output like this, although the version number for Docker may be different:
> ```
> docker-ce:
>   Installed: (none)
>   Candidate: 5:20.10.14~3-0~ubuntu-jammy
>   Version table:
>      5:20.10.14~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.13~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
> ```

Notice that docker-ce is not installed, but the candidate for installation is from the Docker repository for Ubuntu
22.04 (jammy).

Finally, install Docker:

``` bash
sudo apt install docker-ce
```

Docker should now be installed, the daemon started, and the process enabled to start on boot. Check that it’s running:

``` bash
sudo systemctl status docker
```

The output should be similar to the following, showing that the service is active and running:
> ```
> ● docker.service - Docker Application Container Engine
>      Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
>      Active: active (running) since Fri 2022-04-01 21:30:25 UTC; 22s ago
> TriggeredBy: ● docker.socket
>        Docs: https://docs.docker.com
>    Main PID: 7854 (dockerd)
>       Tasks: 7
>      Memory: 38.3M
>         CPU: 340ms
>      CGroup: /system.slice/docker.service
>              └─7854 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
> ```
Installing Docker now gives you not just the Docker service (daemon) but also the docker command line utility, or the
Docker client.

# Executing the Docker Command Without Sudo

By default, the docker command can only be run the root user or by a user in the docker group, which is automatically
created during Docker’s installation process. If you attempt to run the docker command without prefixing it with sudo or
without being in the docker group, you’ll get an output like this:
> ``` bash
> docker: Cannot connect to the Docker daemon. Is the docker daemon running on this host?.
> See 'docker run --help'.
> ```
If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:

``` bash
sudo usermod -aG docker ${USER}
```

To apply the new group membership, log out of the server and back in, or type the following:

``` bash
su - ${USER}
```

You will be prompted to enter your user’s password to continue.

Confirm that your user is now added to the docker group by typing:

``` bash
groups
```

> ```
> sammy sudo docker
> ```
If you need to add a user to the docker group that you’re not logged in as, declare that username explicitly using:

    sudo usermod -aG docker username

The rest of this article assumes you are running the docker command as a user in the docker group. If you choose not to,
please prepend the commands with sudo.

Let’s explore the docker command next.

# Using the Docker Command

Using docker consists of passing it a chain of options and commands followed by arguments. The syntax takes this form:

``` bash
docker [option] [command] [arguments]
```

To view all available subcommands, type:

``` bash
docker
```

As of Docker version 20.10.14, the complete list of available subcommands includes:
> ```
>   attach      Attach local standard input, output, and error streams to a running container
>   build       Build an image from a Dockerfile
>   commit      Create a new image from a container's changes
>   cp          Copy files/folders between a container and the local filesystem
>   create      Create a new container
>   diff        Inspect changes to files or directories on a container's filesystem
>   events      Get real time events from the server
>   exec        Run a command in a running container
>   export      Export a container's filesystem as a tar archive
>   history     Show the history of an image
>   images      List images
>   import      Import the contents from a tarball to create a filesystem image
>   info        Display system-wide information
>   inspect     Return low-level information on Docker objects
>   kill        Kill one or more running containers
>   load        Load an image from a tar archive or STDIN
>   login       Log in to a Docker registry
>   logout      Log out from a Docker registry
>   logs        Fetch the logs of a container
>   pause       Pause all processes within one or more containers
>   port        List port mappings or a specific mapping for the container
>   ps          List containers
>   pull        Pull an image or a repository from a registry
>   push        Push an image or a repository to a registry
>   rename      Rename a container
>   restart     Restart one or more containers
>   rm          Remove one or more containers
>   rmi         Remove one or more images
>   run         Run a command in a new container
>   save        Save one or more images to a tar archive (streamed to STDOUT by default)
>   search      Search the Docker Hub for images
>   start       Start one or more stopped containers
>   stats       Display a live stream of container(s) resource usage statistics
>   stop        Stop one or more running containers
>   tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
>   top         Display the running processes of a container
>   unpause     Unpause all processes within one or more containers
>   update      Update configuration of one or more containers
>   version     Show the Docker version information
>   wait        Block until one or more containers stop, then print their exit codes
> ```
To view system-wide information about Docker, use:

``` bash
docker info
```

# Docker with IPv6

As described in [docker/hub-feedback#1945](https://github.com/docker/hub-feedback/issues/1945), Docker Hub doesn't
currently support pulling images over IPv6, which prevents users on an IPv6-only network from interacting with Docker
Hub

This feature is currently in **beta** and you need an account on [DockerHub](https://hub.docker.com/) to use it.

If you are on a network with IPv6 support, you can begin using the IPv6-only endpoint registry.ipv6.docker.com! To login
to this new endpoint simply run the following command (using your regular Docker hub credentials):

```
docker login registry.ipv6.docker.com
```

Once logged in, add the IPv6-only endpoint to the image you wish to push/pull. For example, if you wish to pull the
official ubuntu image instead of running the following:  
~~```docker pull ubuntu:latest```~~  
you will run:

```
docker pull registry.ipv6.docker.com/library/ubuntu:latest
```

> Note: ```library``` will only be used for official images, replace this with a namespace when applicable.

This endpoint is only supported for push/pulls for Docker Hub Registry with the Docker CLI, Docker Desktop is not
supported. The Docker Hub website and other systems will see updates for IPv6 in the future based on what we learn here.

Please note this new endpoint is only a **beta – there is no guarantee of functionality or uptime and it will be removed
in the future**. Do not use this endpoint for anything other than testing.

---
Sources:  
[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)  
[How To Install and Use Docker on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04)  
[How do I install Docker on Ubuntu 16.04 LTS?](https://askubuntu.com/a/938701)

[Docker Hub registry: Add support for pulling images over IPv6 #89 ](https://github.com/docker/roadmap/issues/89)  
[Beta IPv6 Support on Docker Hub Registry](https://www.docker.com/blog/beta-ipv6-support-on-docker-hub-registry/)
