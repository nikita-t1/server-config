# Introduction
With [watchtower](https://containrrr.dev/watchtower/) you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry. Watchtower will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially.

# Docker Compose
``` yaml
version: "3"

services:
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
    networks:
      default:
        ipv4_address: 192.168.80.5

networks:
  default:
    name: shared-docker-network
    external: true
```