# Introduction

WireGuard is a lightweight Virtual Private Network (VPN) that supports IPv4 and IPv6 connections. A VPN allows you to
traverse untrusted networks as if you were on a private network

> This Guide sets up WireGuard to connect a peer to the WireGuard Server in order to access
> services <span style="color:brown;font-weight: bold">on the server only</span>.

# Install WireGuard

``` bash
sudo apt install wireguard
```

# Generate Keys

Create the private key for WireGuard and change its permissions using the following commands:

``` bash
wg genkey | sudo tee /etc/wireguard/private.key

sudo chmod go= /etc/wireguard/private.key
```

The ```sudo chmod go=...``` command removes any permissions on the file for users and groups other than the root user to
ensure that only it can access the private key.

You should receive a single line of ```base64``` encoded output, which is the private key. A copy of the output is also
stored in the ```/etc/wireguard/private.key``` file for future reference by the tee portion of the command.

The next step is to create the corresponding public key, which is derived from the private key. Use the following
command to create the public key file:

``` bash
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```

This command consists of three individual commands that are chained together using the | (pipe) operator:

- ```sudo cat /etc/wireguard/private.key```: this command reads the private key file and outputs it to the standard
  output stream.

- ```wg pubkey```: the second command takes the output from the first command as its standard input and processes it to
  generate a public key.

- ```sudo tee /etc/wireguard/public.key```: the final command takes the output of the public key generation command and
  redirects it into the file named /etc/wireguard/public.key.

When you run the command you will again receive a single line of base64 encoded output, which is the public key for your
WireGuard Server.

# Creating a WireGuard Server Configuration

Create a new configuration file using nano or your preferred editor by running the following command:

``` bash
sudo nano /etc/wireguard/wg0.conf
```

Add the following lines to the file, substituting your private key in place of the
highlighted ```base64_encoded_private_key_goes_here``` value. You can also change the ListenPort line if you would like
WireGuard to be available on a different port:

``` yaml
[Interface]
PrivateKey = base64_encoded_private_key_goes_here
Address = 10.8.0.1/24, 
ListenPort = 51820
SaveConfig = true
```

The SaveConfig line ensures that when a WireGuard interface is shutdown, any changes will get saved to the configuration
file.

You now have an initial server configuration that you can build upon depending on how you plan to use your WireGuard VPN
server.

# Starting the WireGuard Server

WireGuard can be configured to run as a systemd service using its built-in wg-quick script.

Using a systemd service means that you can configure WireGuard to start up at boot so that you can connect to your VPN
at any time as long as the server is running. To do this, enable the wg-quick service for the wg0 tunnel that you’ve
defined by adding it to systemctl:

``` bash
sudo systemctl enable wg-quick@wg0.service
```

> Notice that the command specifies the name of the tunnel ```wg0``` device name as a part of the service name. This
> name maps to the ```/etc/wireguard/wg0.conf``` configuration file. This approach to naming means that you can create as
> many separate VPN tunnels as you would like using your server.
>
> For example, you could have a tunnel device and name of ```prod``` and its configuration file would
> be ```/etc/wireguard/prod.conf```. Each tunnel configuration can contain > different IPv4, IPv6, and client firewall
> settings. In this way you can support multiple different peer connections, each with their own unique IP addresses and >
> routing rules.

Now start the service:

``` bash
sudo systemctl start wg-quick@wg0.service
```

Double check that the WireGuard service is active with the following command. You should see active (running) in the
output:

``` bash
sudo systemctl status wg-quick@wg0.service
```

> ```
> ● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
>      Loaded: loaded (/lib/systemd/system/wg-quick@.service; enabled; vendor preset: enabled)
>      Active: active (exited) since Wed 2021-08-25 15:24:14 UTC; 5s ago
>        Docs: man:wg-quick(8)
>              man:wg(8)
>              https://www.wireguard.com/
>              https://www.wireguard.com/quickstart/
>              https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
>              https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
>     Process: 3245 ExecStart=/usr/bin/wg-quick up wg0 (code=exited, status=0/SUCCESS)
>    Main PID: 3245 (code=exited, status=0/SUCCESS)
> 
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] wg setconf wg0 /dev/fd/63
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] ip -4 address add 10.8.0.1/24 dev wg0
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] ip -6 address add fd0d:86fa:c3bc::1/64 dev wg0
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] ip link set mtu 1420 up dev wg0
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] ufw route allow in on wg0 out on eth0
> Aug 25 15:24:14 wg0 wg-quick[3279]: Rule added
> Aug 25 15:24:14 wg0 wg-quick[3279]: Rule added (v6)
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
> Aug 25 15:24:14 wg0 wg-quick[3245]: [#] ip6tables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
> Aug 25 15:24:14 wg0 systemd[1]: Finished WireGuard via wg-quick(8) for wg0.
> ```
The output shows the ip commands that are used to create the virtual wg0 device and assign it the IPv4 and IPv6
addresses that you added to the configuration file. You can use these rules to troubleshoot the tunnel, or with the wg
command itself if you would like to try manually configuring the VPN interface.

With the server configured and running, the next step is to configure your client machine as a WireGuard Peer and
connect to the WireGuard Server.

# Configuring a WireGuard Peer

## Windows

Download the WireGuard Client from the official source: [wireguard.com](https://www.wireguard.com/install/)

Once you install the client, you will want to click the arrow next to “Add Tunnel”, then
click ```Add empty tunnnel....```

What’s nice about this is the GUI creates a public and private key for us automatically.

![](img/generatedKeys.bmp)

The final Config should the look something linke this:

```
[Interface]
PrivateKey = abcdefghijklmnopqrstuvwxyz1234567890=+
Address = 10.8.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = YOUR_SERVER_PUBLIC_KEY
AllowedIPs = 192.168.80.0/24
Endpoint = YOUR_SERVER_WAN_IP:51820
```

Here is what each field means:

```[Interface]```
This is where we will configure the following properties for the client’s virtual interface:

- ```PrivateKey```: This is your CLIENT **private** key that is generated (never share this)

- ```Address```: The IP address for our virtual interface for the client. This must be on the same subnet as the server
  and unique across every device on the virutal network. **Increment this for every additional Client you add.
  10.8.0.2/24 --> 10.8.0.3/24**

- ```DNS```: These are the DNS servers in which your connection will use. You can do fancy things with this, but in this
  example we are just going to set this to CloudFlare’s DNS servers.

```[Peer]```
These are properties set to connect to our server

- ```PublicKey```: This is your SERVER **public** key that is generated. On our server, we will save this value at
  “/etc/wireguard/keys/server.key.pub“. It is safe to share a public key, but NEVER share the private key

- ```AllowedIPs```: Setting this to 0.0.0.0/0 is saying that we want ALL traffic from our client to route through our
  VPN interface
  > I Set this to ```192.168.80.0/24``` because all the Docker containers that i want to reach will be on this net

- ```Endpoint```: This is the WAN (or Internet) IP address of where your client should connect to. This will be the
  WAN (Internet) IP of our server.

Click on ```Save``` and then your done on the Client-Side

### Adding the Peer’s Public Key to the WireGuard Server

It would be kind of pointless to have our VPN server allow anyone to connect. This is where our public & private keys
come into play.

- Each client’s **public** key needs to be added to the SERVER’S configuration file
- The server’s **public** key added to the CLIENT’S configuration file

By both the client and the server knowing each other’s public key, a few awesome things happen here:

- Random trolls won’t be able to join your VPN network (because it authenticates the key — much more secure than a
  password)
- You are prevented from being victim to a man-in-the-middle attack

This is why it is also important to NEVER SHARE your private key. If someone gets a hold of that, your connection can be
compromised.

Once you have each keypair created, configuring is quite simple. ON YOUR SERVER you will run this command:

``` bash
sudo wg set wg0 peer YOUR_CLIENT_PUBLIC_KEY allowed-ips YOUR_CLIENT_VPN_IP
```

> ```
>sudo wg set wg0 peer OFAYwzdKei7wm4XHDCILSY|IMH3fGrO5FF7a3Qj+bCw= allowed-ips 10.8.0.2
>```

## Wireguard Status

Once you have run the command to add the peer, check the status of the tunnel on the server using the wg command:

``` bash 
sudo wg
```

> ``` bash
> interface: wg0
>   public key: UIV0r6S6mvno5b17H4sDxPAgRVqq60pyXsa6xb58Z2w=
>   private key: (hidden)
>   listening port: 51820
> peer: ShTWRMynKlWCSCGHhzobpt9RTFE6w0G1WiC3b1RM7k8=
>   endpoint: 149.224.63.255:60969
>   allowed ips: 10.8.0.2/32
>   latest handshake: 1 hour, 1 minute, 50 seconds ago
>     transfer: 5.03 MiB received, 22.76 MiB sent
> ```
>
Notice how the peer line shows the WireGuard Peer’s public key, and the IP addresses, or ranges of addresses that it is
allowed to use to assign itself an IP.

Now that you have defined the peer’s connection parameters on the server, the next step is to start the tunnel on the
peer.

---
Sources:  
[How To Set Up WireGuard on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-20-04#step-6-starting-the-wireguard-server)  
[Getting started with WireGuard VPN: Important Concepts](https://serversideup.net/getting-started-with-wireguard-vpn-important-concepts/)  
[How to configure a WireGuard Windows 10 VPN client](https://serversideup.net/how-to-configure-a-wireguard-windows-10-vpn-client/)  
[WireGuard Endpoints and IP Addresses](https://www.procustodibus.com/blog/2021/01/wireguard-endpoints-and-ip-addresses/)  
[How to Set Up WireGuard VPN on Ubuntu 20.04](https://linuxize.com/post/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/)
[Route only local LAN traffic through wireguard](https://archive.ph/wJJbO)  
[Assign static IP to Docker container](https://stackoverflow.com/questions/27937185/assign-static-ip-to-docker-container)
