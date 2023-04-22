---
title: "How to set up Multi-Factor Authentication for SSH on Linux"
description: "Set up multi-factor authentication for SSH with Google's PAM and TOTP for added security"
---

# {{ $frontmatter.title }}

## Introduction

SSH uses passwords for authentication by default, and most SSH hardening instructions recommend using an SSH key
instead. However, this is still only a single factor. If a bad actor has compromised your computer, then they can use
your key to compromise your servers as well.

In this tutorial, we’ll set up multi-factor authentication to combat that. Multi-factor authentication (MFA) requires
more than one factor in order to authenticate, or log in. This means a bad actor would have to compromise multiple
things, like both your computer and your phone, to get in.

## Installing Google’s PAM

PAM, which stands for Pluggable Authentication Module, is an authentication infrastructure used on Linux systems to
authenticate a user. Because Google made an OATH-TOTP app, they also made a PAM that generates TOTPs and is fully
compatible with any OATH-TOTP app.

``` bash
sudo apt-get install libpam-google-authenticator
```

With the PAM installed, we’ll use a helper app that comes with the PAM to generate a TOTP key for the user you want to
add a second factor to.
::: info
This key is generated on a user-by-user basis, not system-wide. This means every user that wants to use a TOTP auth
app will need to log in and run the helper app to get their own key.
:::

## Configure Google’s PAM

Run the initialization app:

``` bash
google-authenticator
```

After you run the command, you’ll be asked a few questions. The first one asks if authentication tokens should be
time-based.
> ```
> Do you want authentication tokens to be time-based (y/n) 
> ```

::: info
**This PAM allows for time-based or sequential-based tokens. Using sequential-based tokens mean the code starts at a
certain point and then increments the code after every use. Using time-based tokens mean the code changes randomly after
a certain time elapses. We’ll stick with time-based because that is what apps like Google Authenticator anticipate, so
answer `y` for yes.**
:::

After answering this question, a lot of output will scroll past, including a large QR code. At this point, use your
authenticator app on your phone to scan the QR code or manually type in the secret key. If the QR code is too big to
scan, you can use the URL above the QR code to get a smaller version. Once it’s added, you’ll see a six digit code that
changes every 30 seconds in your app.

The remaining questions inform the PAM how to function. We’ll go through them one by one.
> ```
> Do you want me to update your "~/.google_authenticator" file (y/n) y
> ```
This writes the key and options to the .google_authenticator file. If you say no, the program quits and nothing is
written, which means the authenticator won’t work.

> ```
> Do you want to disallow multiple uses of the same authentication
> token? This restricts you to one login about every 30s, but it increases
> your chances to notice or even prevent man-in-the-middle attacks (y/n) y
> ```
By answering yes here, you are preventing a replay attack by making each code expire immediately after use. This
prevents an attacker from capturing a code you just used and logging in with it.
> ```
> By default, tokens are good for 30 seconds and in order to compensate for
> possible time-skew between the client and the server, we allow an extra
> token before and after the current time. If you experience problems with poor
> time synchronization, you can increase the window from its default
> size of 1:30min to about 4min. Do you want to do so (y/n) n
> ```
Answering yes here allows up to 8 valid codes in a moving four minute window. By answering no, you limit it to 3 valid
codes in a 1:30 minute rolling window. Unless you find issues with the 1:30 minute window, answering no is the more
secure choice.
> ```
> If the computer that you are logging into isn't hardened against brute-force
> login attempts, you can enable rate-limiting for the authentication module.
> By default, this limits attackers to no more than 3 login attempts every 30s.
> Do you want to enable rate-limiting (y/n) y
> ```
Rate limiting means a remote attacker can only attempt a certain number of guesses before being blocked. If you haven’t
previously configured rate limiting directly into SSH, doing so now is a great hardening technique.

Now that Google’s PAM is installed and configured, the next step is to configure SSH to use your TOTP key. We’ll need to
tell SSH about the PAM and then configure SSH to use it.

## Configuring OpenSSH

Too begin open up the sshd configuration file for editing using nano or your favorite text editor.

``` bash
sudo nano /etc/pam.d/sshd
```

Add the following line to the bottom of the file.
> ```
> ...
> # Standard Un*x password updating.
> @include common-password
> auth required pam_google_authenticator.so nullok
> ```

::: info
The nullok word at the end of the last line tells the PAM that this authentication method is optional. This allows
users without a OATH-TOTP token to still log in using their SSH key. Once all users have an OATH-TOTP token, you can
remove nullok from this line to make MFA mandatory.
:::

Save and close the file.

Next, we’ll configure SSH to support this kind of authentication. Open the SSH configuration file for editing.

```bash
sudo nano /etc/ssh/sshd_config
```

Look for `ChallengeResponseAuthentication` and set its value to `yes`.
> ```
> ...
> # Change to yes to enable challenge-response passwords (beware issues with
> # some PAM modules and threads)
> ChallengeResponseAuthentication no // [!code --]
> ChallengeResponseAuthentication yes // [!code ++]
> ...
> ```
Look also for `KbdInteractiveAuthentication` and set its value also to `yes`.
> ```
> ...
> KbdInteractiveAuthentication no // [!code --]
> KbdInteractiveAuthentication yes // [!code ++]
> ...
> ```

Save and close the file, then restart SSH to reload the configuration files. Restarting the `sshd` service won’t
close open connections, so you won’t risk locking yourself out with this command.

``` bash
sudo systemctl restart sshd.service
```
::: tip
To test that everything’s working so far, open another terminal and try logging in over SSH. If you’ve previously
created an SSH key and are using it, you’ll notice you didn’t have to type in your user’s password or the MFA
verification code. This is because an SSH key overrides all other authentication options by default. Otherwise, you
should have gotten a password and verification code prompt.
:::

Next, to enable an SSH key as one factor and the verification code as a second, we need to tell SSH which factors to use
and prevent the SSH key from overriding all other types.

## Making SSH Aware of MFA

Reopen the sshd configuration file.

``` bash
sudo nano /etc/ssh/sshd_config
```

Add the following line at the bottom of the file. This tells SSH which authentication methods are required. This line
tells SSH we need a SSH key and either a password or a verification code (or all three).
> ```
> ...
> UsePAM yes
> AuthenticationMethods publickey,password publickey,keyboard-interactive
> ```

Also reenable `PasswordAuthentication`, as you will be using this password as a factor

```
PasswordAuthentication no // [!code --]
PasswordAuthentication yes // [!code ++]
```

> Otherwise the `sshd.service` will fail restarting

Save and close the file.

Next, open the PAM sshd configuration file again.

``` bash
sudo nano /etc/pam.d/sshd
```

Find the line `@include common-auth` and comment it out by adding a `#` character as the first character on the
line. This tells PAM not to prompt for a password.
> ```
> ...
> # Standard Un*x authentication.
> #@include common-auth
> ...
> ```
Save and close the file, then restart SSH.

``` bash
sudo systemctl restart sshd.service
```

Now try logging into the server again with a different session. Unlike last time, SSH should ask for your verification
code. Upon entering it, you’ll be logged in. Even though you don’t see any indication that your SSH key was used, your
login attempt used two factors.
> If you want to verify, you can add `-v` (for verbose) after the SSH command

### Adding a Third Factor (Optional)

In the [previous Step](#making-ssh-aware-of-mfa), we listed the approved types of authentication in the sshd_config
file:

- `publickey` (SSH key)
- `password publickey` (password)
- `keyboard-interactive` (verification code)

Although we listed three different factors, with the options we’ve chosen so far, they only allow for an SSH key and the
verification code. If you’d like to have all three factors (SSH key, password, and verification code), one quick change
will enable all three.

Open the PAM `sshd` configuration file.

``` bash
sudo nano /etc/pam.d/sshd
```

Locate the line you commented out previously, `#@include common-auth`, and uncomment the line by removing
the `#` character.
```
#@include common-auth // [!code --]
@include common-auth // [!code ++]
```
Save and close the file.
Now once again, restart SSH.

``` bash
sudo systemctl restart sshd.service
```

By enabling the option ```@include common-auth```, PAM will now prompt for a password in addition the checking for an
SSH key and asking for a verification code, which we had working previously. Now we can use something we know (password)
and two different types of things we have (SSH key and verification code) over two different channels.

---
Sources:  
[How To Set Up Multi-Factor Authentication for SSH on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04)  
[SSH-Login mit 2-Faktor-Authentifizierung absichern](https://www.thomas-krenn.com/de/wiki/SSH-Login_mit_2-Faktor-Authentifizierung_absichern)  
[https://www.credativ.de/blog/howtos/zwei-faktor-authentisierung-fuer-openssh-und-openvpn/](https://www.credativ.de/blog/howtos/zwei-faktor-authentisierung-fuer-openssh-und-openvpn/)
