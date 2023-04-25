---
title: "Secure Your SSH Login by Changing Default Settings"
description: "Configure your SSH settings for increased security by adjusting settings like login grace time, max authentication tries, and root login permissions, and monitor your SSH login activity through the /var/log/auth.log file."
---

# {{ $frontmatter.title }}

## SSH Login Log

To access the SSH login log file, enter the following command in the terminal:

``` bash
cat /var/log/auth.log
```

This file will contain information about successful and failed login attempts, which can be helpful for monitoring and
troubleshooting.

## SSH Config

To configure SSH settings, you'll need to edit the OpenSSH SSH daemon configuration file. You can do this open the
main ```OpenSSH SSH daemon configuration file```  with root privileges:

``` bash
sudo nano /etc/ssh/sshd_config
```

Once you have the file open, you can make changes to various settings to enhance the security of your SSH connections.
Here are some key settings to consider changing:

### Port Number

By changing the default SSH port, you can make it harder for attackers to discover your server's SSH service.

```bash

# Specifies the port number that sshd(8) listens on.
Port 22 // [!code --]
Port 2002 // [!code ++]

```

### LoginGraceTime

Setting a shorter LoginGraceTime can reduce the window of opportunity for attackers attempting to brute force your SSH
login.

``` bash
# The server disconnects after this time if the user has not successfully logged in. 
# If the value is 0, there is no time limit. 
LoginGraceTime 120 // [!code --]
LoginGraceTime 20 // [!code ++]
```

### MaxAuthTries

By setting a lower value for MaxAuthTries, you can prevent attackers from making multiple login attempts.

``` bash
# Specifies the maximum number of authentication attempts permitted per connection. 
MaxAuthTries 6 // [!code --]
MaxAuthTries 2 // [!code ++]
```

### MaxSessions

Setting a lower value for MaxSessions can help prevent resource exhaustion attacks.

``` bash
# Specifies the maximum number of open shell, login or subsystem (e.g. sftp) sessions permitted per network connection. 
MaxSessions 10 // [!code --]
MaxSessions 3 // [!code ++]
```

### MaxStartups

By setting a lower value for MaxStartups, you can limit the number of unauthenticated connections to your SSH daemon,
which can help prevent denial of service attacks.

``` bash
# Specifies the maximum number of concurrent unauthenticated connections to the SSH daemon.
# Additional connections will be dropped until authentication succeeds or the LoginGraceTime expires for a connection.
# The default is 10:30:100.

# Alternatively, random early drop can be enabled by specifying the three colon separated values “start:rate:full” (e.g. "10:30:60"). 
# sshd(8) will refuse connection attempts with a probability of “rate/100” (30%) if there are currently “start” (10) unauthenticated connections.
# The probability increases linearly and all connection attempts are refused if the number of unauthenticated connections reaches “full” (60).
MaxStartups 10 // [!code --]
MaxStartups 1 // [!code ++]
```

### PermitRootLogin

Disabling PermitRootLogin can prevent attackers from logging in as the root user, which can help prevent certain types
of attacks.

``` bash
# Specifies whether root can log in using ssh(1). 
# The argument must be “yes”, “prohibit-password”, “without-password”, “forced-commands-only”, or “no”.  
# If this option is set to “no”, root is not allowed to log in.
PermitRootLogin prohibit-password // [!code --]
PermitRootLogin no // [!code ++]
```

## Reload SSH
After making changes to the sshd_config file, reload the SSH service:
``` bash
service sshd restart
```

---
Sources:  
[sshd_config](https://manpages.ubuntu.com/manpages/xenial/man5/sshd_config.5.html)  
[OpenSSH Konfiguration](https://www.thomas-krenn.com/de/wiki/OpenSSH_Konfiguration)

Nice Discussion:  
[Moving your SSH port isn’t security by obscurity](https://news.ycombinator.com/item?id=24542104)
