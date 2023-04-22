# Introduction
The communication between docker containers takes place using docker networks. Docker networks also play an important role to expose docker container ports to the host system. There are different types of docker network drivers for different purposes.

To be able to assign static IP's to the containers you should create such a network.
To be able to access these IP's (only) throught WireGuard, the network should match the IP Range you explicitly allowed during your WireGuard Configuration. If you followed this whole tutorial this range should be: ```192.168.80.0/24 ```

# Create docker network
The neccessary Docker network can be created by using the following command:
``` bash
sudo docker network create --driver=bridge --subnet=192.168.80.0/24 --gateway=192.168.80.1 shared-docker-network
```
> This will allow for IP's in the range from ```192.168.80.1``` to ```192.168.80.254```

---
Sources:  
[How to create and manage docker networks and docker volumes](https://webdock.io/en/docs/how-guides/docker-guides/how-to-create-and-manage-docker-networks-and-docker-volumes)  
[Join an existing network from a docker container in docker compose](https://poopcode.com/join-to-an-existing-network-from-a-docker-container-in-docker-compose/)  
[https://stackoverflow.com/questions/38088279/communication-between-multiple-docker-compose-projects](https://stackoverflow.com/questions/38088279/communication-between-multiple-docker-compose-projects)

