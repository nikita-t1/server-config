# Introduction
[Nginx Proxy Manager](https://nginxproxymanager.com/) enables you to easily forward to your websites running at home or otherwise, including free SSL, without having to know too much about Nginx or Letsencrypt.

# Deploy Nginx Proxy Manager
Open the Portainer Web UI.
From the menu select Stacks, click Add stack, give the stack a descriptive name then select Web editor.
Paste the following in the Web Editor:
``` yaml
version: "3"

services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    container_name: nginx-proxy-manager
    ports:
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '127.0.0.1:81:81' # Local Admin Web Port
      # Add any other Stream port you want to expose
      # - '21:21' # FTP

      # Uncomment this if IPv6 is not enabled on your host
      # DISABLE_IPV6: 'true'

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt

    networks:
      default:
        ipv4_address: 192.168.80.3

networks:
  default:
    name: shared-docker-network
    external: true
```

# Log In
Because the Container is only available locally you need to setup and activate your WireGuard Connection as descripted in [Step 13 (WireGuard)](13_wireguard.md) and then you can open the Admin Web UI by typing ```192.168.80.3:81``` in your browser.

The default Credentials for the fitst login are:
```
Email:    admin@example.com
Password: changeme
```
Immediately after logging in with this default user you will be asked to modify your details and change your password.

---
[Full Setup Instructions](https://nginxproxymanager.com/setup/)  
[Add a new stack](https://docs.portainer.io/user/docker/stacks/add)