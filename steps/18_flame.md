# Introduction

[Flame](https://github.com/pawelmalak/flame) is self-hosted startpage for your server. Flame is very easy to setup and
use. With built-in editors, it allows you to setup your very own application hub in no time - no file editing necessary.

![flame](/img/flame.bmp)

# Docker Compose

``` yaml
version: '3.6'

services:
  flame:
    image: pawelmalak/flame
    container_name: flame
    volumes:
      - ./data:/app/data
    ports:
      - 127.0.0.1:5005:5005
    environment:
      - PASSWORD=<PASSWORD>
    restart: unless-stopped
    networks:
      default:
        ipv4_address: 192.168.80.4
        
networks:
  default:
    name: shared-docker-network
    external: true
```
