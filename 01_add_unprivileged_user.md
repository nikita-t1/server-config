# Introduction
While running as the root user gives you complete control over a system and its users, it is also dangerous and possibly destructive. For common system administration tasks, it’s a better idea to add an unprivileged user and carry out those tasks without root privileges. You can also create additional unprivileged accounts for any other users you may have on your system. Each user on a system should have their own separate account.

For tasks that require administrator privileges, there is a tool installed on Ubuntu systems called sudo. Briefly, sudo allows you to run a command as another user, including users with administrative privileges. In this guide, you’ll learn how to create user accounts, assign sudo privileges, and delete users.

# Create new User
``` bash
sudo adduser newuser
```
You will be required to respond to a series of questions:
- Assign and confirm a password for the new user.
- Enter any additional information about the new user. This is optional and can be skipped by pressing ENTER if you don’t wish to utilize these fields.
- Finally, you’ll be asked to confirm that the information you provided was correct. Press Y to continue.

# Grant User Sudo Privileges
If your new user should have the ability to execute commands with root (administrative) privileges, you will need to give the new user access to ```sudo```.

In order to add the user to a new group, you can use the usermod command:
``` bash
usermod -aG sudo newuser
```
The -aG option tells usermod to add the user to the listed groups.

# Login
login as this newly created user
``` bash
ssh newuser@<IP-ADDRESS>
```

---
Sources:  
[How to Add and Delete Users on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-add-and-delete-users-on-ubuntu-20-04)