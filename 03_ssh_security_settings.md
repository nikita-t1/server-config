## SSH Login Log
``` bash
/var/log/auth.log
```

## SSH Config

Open the main ```OpenSSH SSH daemon configuration file```  with root privileges:
``` bash
sudo nano /etc/ssh/sshd_config
```

Change the following Settings:

Port Number 
``` bash
# Specifies the port number that sshd(8) listens on. 
# The default is 22.
Port 2202
```
LoginGraceTime 
``` bash
# The server disconnects after this time if the user has not successfully logged in. 
# If the value is 0, there is no time limit. 
# The default is 120 seconds.
LoginGraceTime 20
```
MaxAuthTries 
``` bash
# Specifies the maximum number of authentication attempts permitted per connection. 
# The default is 6.
MaxAuthTries 2
```
MaxSessions 
``` bash
# Specifies the maximum number of open shell, login or subsystem (e.g. sftp) sessions permitted per network connection. 
# The default is 10.
MaxSessions 3
```
MaxStartups 
``` bash
# Specifies the maximum number of concurrent unauthenticated connections to the SSH daemon.
# Additional connections will be dropped until authentication succeeds or the LoginGraceTime expires for a connection.
# The default is 10:30:100.

# Alternatively, random early drop can be enabled by specifying the three colon separated values “start:rate:full” (e.g. "10:30:60"). 
# sshd(8) will refuse connection attempts with a probability of “rate/100” (30%) if there are currently “start” (10) unauthenticated connections.
# The probability increases linearly and all connection attempts are refused if the number of unauthenticated connections reaches “full” (60).
MaxStartups 1
```
  
PermitRootLogin 
``` bash
# Specifies whether root can log in using ssh(1). 
# The argument must be “yes”, “prohibit-password”, “without-password”, “forced-commands-only”, or “no”.  
# The default is “prohibit-password”.

# If this option is set to “no”, root is not allowed to log in.
PermitRootLogin no
```

### Reload SSH
``` bash
service sshd restart
```

---
Sources:  
[sshd_config](https://manpages.ubuntu.com/manpages/xenial/man5/sshd_config.5.html)  
[OpenSSH Konfiguration](https://www.thomas-krenn.com/de/wiki/OpenSSH_Konfiguration)


Nice Discussion:  
[Moving your SSH port isn’t security by obscurity](https://news.ycombinator.com/item?id=24542104)