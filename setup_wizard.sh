#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

BASE_URL="https://nikita-t1.github.io/server-config"

echo -e "${ORANGE}--------------------------------------------------${NC}"
echo -e "${ORANGE}               <-- server-config -->              ${NC}"
echo -e "${ORANGE}--------------------------------------------------${NC}"
echo -e "\n"

# --------------------------------------------------
# Ask the User for permission to run download and run the latest version of Gum
# --------------------------------------------------
echo "To provide a better experience, this script uses Gum to display the output in a nice way."
echo "Gum is a terminal UI that provides a better experience for command-line applications."
echo "Gum is required to run this script."
read -p "$(echo -e "${ORANGE}Download and Run the latest version of Gum? (Y/n) ${NC}")" -n 1 -r RUN_GUM
if [[ $RUN_GUM =~ ^[Yy]?$ ]]; then
  echo -e "${ORANGE}Downloading Gum${NC}"
  # Find the latest release of Gum and download it
  GUM_DOWNLOAD_URL_BUT_WITH_TRAILING_QUOTATION=$(curl https://api.github.com/repos/charmbracelet/gum/releases/latest | grep -oh 'https://github.com/charmbracelet/gum/releases/download/.*Linux_x86_64.tar.gz"')
  GUM_DOWNLOAD_URL=${GUM_DOWNLOAD_URL_BUT_WITH_TRAILING_QUOTATION:0:-1}

  EXTRACTION_DIR="${GUM_DOWNLOAD_URL##*/}"
  EXTRACTION_DIR="${EXTRACTION_DIR%%.tar.gz}"

  curl -L -o /tmp/gum.tar.gz $GUM_DOWNLOAD_URL
  tar -xvf /tmp/gum.tar.gz -C /tmp

  chmod +x /tmp/${EXTRACTION_DIR}/gum
  sudo mv /tmp/${EXTRACTION_DIR}/gum /usr/local/bin/gum

  gum log --structured --time="timeonly" --level info "Gum successfully installed."

else
  echo -e "${RED}Gum is required to run this script. Exiting...${NC}"
  exit 1
fi

# --------------------------------------------------
# Section: Update System
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Update System${NC}"
echo -e "${ORANGE}This Section is mandatory${NC}"
sleep 5
echo -e "sudo apt update"
sudo apt update
read -p "$(echo -e "${ORANGE}Also run sudo apt upgrade? (Y/n) ${NC}")" -n 1 -r UPGRADE
if [[ $UPGRADE =~ ^[Yy]?$ ]]; then
  echo "Yes"
  sudo apt upgrade
fi

echo -e "\n"

# --------------------------------------------------
# Section: Create Unprivileged User
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Unprivileged User${NC}"
echo -e "${BLUE}${BASE_URL}/steps/add_unprivileged_user${NC}"
echo -e "${ORANGE}This Section is mandatory${NC}"
sleep 5
read -p "$(echo -e "${ORANGE}Enter the name of the user you want to create: ${NC}")" USERNAME
echo -e "${BLUE}Creating user $USERNAME${NC}"
sudo adduser "$USERNAME"
sudo usermod -aG sudo "$USERNAME"
echo -e "\n"

# --------------------------------------------------
# Section: Login with SSH Keys
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Login with SSH Keys${NC}"
echo -e "${BLUE}${BASE_URL}/steps/ssk_keys${NC}"
echo -e "${ORANGE}This Section is mandatory${NC}"
sleep 5
sudo mkdir -p /home/"$USERNAME"/.ssh
read -p "$(echo -e "${ORANGE}Enter the public key you want to use: ${NC}")" SSH_KEY
echo -e "${BLUE}Adding public key to authorized_keys: ${SSH_KEY} ${NC}"
echo "$SSH_KEY" >>/home/"$USERNAME"/.ssh/authorized_keys
echo -e ""
echo -e "Changing permissions on authorized_keys"
sudo chmod -R go= /home/"$USERNAME"/.ssh
echo -e "Changing ownership on authorized_keys"
sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
echo -e "\n"

# --------------------------------------------------
# Section: Configure SSH Settings
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Configure SSH Settings${NC}"
echo -e "${BLUE}${BASE_URL}/steps/ssh_security_settings${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_SSH_SETTINGS
if [[ $RUN_SSH_SETTINGS =~ ^[Yy]?$ ]]; then
  read -p "$(echo -e "${ORANGE}Enter the port you want to use for SSH: ${NC}")" SSH_PORT

  echo -e "${BLUE}Changing SSH port to ${SSH_PORT}${NC}"
  sudo sed -i "s/#\?Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config

  echo -e "Disabling Password Authentication"
  sed -i -e '/#\?PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config

  echo -e "Disabling Root Login"
  sed -i -e '/#\?PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config

  echo -e "Reduce LoginGraceTime to 20 seconds"
  sed -i -e '/^#LoginGraceTime/s/^.*$/LoginGraceTime 20/' /etc/ssh/sshd_config

  echo -e "Reduce MaxAuthTries to 2"
  sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config

  echo -e "Reduce MaxSessions to 3"
  sed -i -e '/^#MaxSessions/s/^.*$/MaxSessions 3/' /etc/ssh/sshd_config

  echo -e "Reduce MaxStartups to 1"
  sed -i -e '/^#MaxStartups/s/^.*$/MaxStartups 1/' /etc/ssh/sshd_config

  echo -e "Restarting SSH Service"
  # check if the system is debian based, because the service name is different
  # https://www.reddit.com/r/Ubuntu/comments/1cl5qiq/comment/lbhrihx/
  if [[ -f /etc/debian_version ]]; then
        sudo systemctl restart ssh
  else
        sudo systemctl restart sshd
  fi

fi

echo -e "\n"

# --------------------------------------------------
# Section: TOTP for SSH
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: MFA for SSH${NC}"
echo -e "${BLUE}${BASE_URL}/steps/ssh_totp${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_MFA_SSH
if [[ $RUN_MFA_SSH =~ ^[Yy]?$ ]]; then
  echo -e "${ORANGE}!!! TODO !!!${NC}"
  sleep 3
fi

echo -e "\n"

# --------------------------------------------------
# Section: Install Uncomplicated Firewall
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Uncomplicated Firewall${NC}"
echo -e "${BLUE}${BASE_URL}/steps/ufw${NC}"
echo -e "${ORANGE}This Section is mandatory${NC}"
sleep 5
echo -e "Install ufw"
sudo apt install ufw -y

echo -e "Allow all outgoing traffic"
sudo ufw default allow outgoing comment 'allow all outgoing traffic'

echo -e "Deny all incoming traffic"
sudo ufw default deny incoming comment 'deny all incoming traffic'

echo -e "Allow SSH Port"
sudo ufw limit "${SSH_PORT}"/tcp comment 'allow SSH connections in' # Allow SSH

read -p "$(echo -e "${ORANGE}Block Port 80? (Y/n) ${NC}")" -n 1 -r BLOCK_PORT_80
if [[ $BLOCK_PORT_80 =~ ^[Yy]?$ ]]; then
  echo -e "Block Port 80"
  sudo ufw deny 80/tcp comment 'deny HTTP traffic in' # Deny HTTP
fi

echo -e "Enable UFW"
sudo ufw enable

echo -e "Enable IPv6 Support"
sed -i 's/IPV6=no/IPV6=yes/g' /etc/default/ufw

echo -e "Restart Firewall"
sudo ufw disable
sudo ufw enable

echo -e "\n"

# --------------------------------------------------
# Section: Cloudflare WAF
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Cloudflare WAF ${NC}"
echo -e "${BLUE}${BASE_URL}/steps/ufw_cloudflare${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_CLOUDFLARE_WAF
if [[ $RUN_CLOUDFLARE_WAF =~ ^[Yy]?$ ]]; then

  echo -e "Allow Cloudflare IPs on Port 443"
  for ip in $(curl https://www.cloudflare.com/ips-v4); do sudo ufw allow from "$ip" to any port 443 comment 'allow Cloudflare IPs'; done
  for ip in $(curl https://www.cloudflare.com/ips-v6); do sudo ufw allow from "$ip" to any port 443 comment 'allow Cloudflare IPs'; done

  echo -e ""
  echo -e "Deny IPs not from Cloudflare on Port 443"
  sudo ufw deny 443/tcp comment 'deny HTTPS traffic outside of Cloudflare'
fi

echo -e "\n"

# --------------------------------------------------
# Section: SMTP Mail Server
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: SMTP Mail Server${NC}"
echo -e "${BLUE}${BASE_URL}/steps/msmtp${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_SMTP_MAIL
if [[ $RUN_SMTP_MAIL =~ ^[Yy]?$ ]]; then
  sleep 5
  echo -e "Install msmtprc"
  sudo apt install msmtp msmtp-mta mailutils -y
  read -p "$(echo -e "${ORANGE}Enter your E-Mail Address: ${NC}")" EMAIL_ACCOUNT
  read -p "$(echo -e "${ORANGE}Enter your E-Mail Password: ${NC}")" EMAIL_PASSWORD
  read -p "$(echo -e "${ORANGE}Enter your SMTP E-Mail Host: ${NC}")" EMAIL_HOST
  echo -e "Creating msmtprc with the following settings:"
  echo -e "${BLUE}Account: ${EMAIL_ACCOUNT}${NC}"
  echo -e "${BLUE}Password: ${EMAIL_PASSWORD}${NC}"
  echo -e "${BLUE}Host: ${EMAIL_HOST}${NC}"

  echo "
  # Set default values for all following accounts.
  defaults

  # Use the mail submission port 587 instead of the SMTP port 25.
  port 587

  # Always use TLS.
  tls on

  # Set a list of trusted CAs for TLS. The default is to use system settings, but
  # you can select your own file.
  #tls_trust_file /etc/ssl/certs/ca-certificates.crt

  # If you select your own file, you should also use the tls_crl_file command to
  # check for revoked certificates, but unfortunately getting revocation lists and
  # keeping them up to date is not straightforward.
  #tls_crl_file ~/.tls-crls

  # Mail account
  account ${EMAIL_ACCOUNT}

  # Host name of the SMTP server
  host ${EMAIL_HOST}

  # This is especially important for mail providers like
  # Ionos, 1&1, GMX and web.de
  set_from_header on

  # As an alternative to tls_trust_file/tls_crl_file, you can use tls_fingerprint
  # to pin a single certificate. You have to update the fingerprint when the
  # server certificate changes, but an attacker cannot trick you into accepting
  # a fraudulent certificate. Get the fingerprint with
  # $ msmtp --serverinfo --tls --tls-certcheck=off --host=smtp.freemail.example
  #tls_fingerprint 00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33

  # Envelope-from address
  from ${EMAIL_ACCOUNT}

  # Authentication. The password is given using one of five methods, see below.
  auth on

  user ${EMAIL_ACCOUNT}

  # Password method 1: Add the password to the system keyring, and let msmtp get
  # it automatically. To set the keyring password using Gnome's libsecret:
  # $ secret-tool store --label=msmtp \
  #   host smtp.freemail.example \
  #   service smtp \
  #   user joe.smith

  # Password method 2: Store the password in an encrypted file, and tell msmtp
  # which command to use to decrypt it. This is usually used with GnuPG, as in
  # this example. Usually gpg-agent will ask once for the decryption password.
  #passwordeval gpg2 --no-tty -q -d ~/.msmtp-password.gpg

  # Password method 3: Store the password directly in this file. Usually it is not
  # a good idea to store passwords in plain text files. If you do it anyway, at
  # least make sure that this file can only be read by yourself.
  password ${EMAIL_PASSWORD}

  # Password method 4: Store the password in ~/.netrc. This method is probably not
  # relevant anymore.

  # Password method 5: Do not specify a password. Msmtp will then prompt you for
  # it. This means you need to be able to type into a terminal when msmtp runs.

  # Set a default account
  account default: ${EMAIL_ACCOUNT}

  # Map local users to mail addresses (for crontab)
  aliases /etc/aliases
  " >>/etc/msmtprc

  echo -e "Creating aliases file"
  echo "root: ${EMAIL_ACCOUNT}" >>/etc/aliases
  echo "default: ${EMAIL_ACCOUNT}" >>/etc/aliases

  echo -e "Copy msmtprc file to /home/${USERNAME}/.msmtprc"
  sudo cp /etc/msmtprc /home/"$USERNAME"/.msmtprc

  echo -e "Changing permissions on msmtprc"
  sudo chmod 600 /etc/msmtprc
  sudo chmod 600 /home/"$USERNAME"/.msmtprc
  sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.msmtprc

  echo -e "Set as default mailer"
  echo "set sendmail=\"/usr/bin/msmtp -t\"" >>/etc/mail.rc

  echo -e "Send Test E-Mail"
  echo "This is a test email" | mail -s "Test E-Mail" "$EMAIL_ACCOUNT"
fi

echo -e "\n"

# --------------------------------------------------
# Section: Unattended Updates
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Unattended Updates${NC}"
echo -e "${BLUE}${BASE_URL}/steps/auto_updates${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_AUTO_UPDATES
if [[ $RUN_AUTO_UPDATES =~ ^[Yy]?$ ]]; then
  echo -e "Install unattended-upgrades, apt-listchanges, apticron"
  sudo apt install unattended-upgrades apt-listchanges apticron -y

  echo -e "Create 51-unattended-upgrades file"
  echo "
  // Enable the update/upgrade script (0=disable)
  APT::Periodic::Enable \"1\";

  // Do \"apt-get update\" automatically every n-days (0=disable)
  APT::Periodic::Update-Package-Lists \"1\";

  // Do \"apt-get upgrade --download-only\" every n-days (0=disable)
  APT::Periodic::Download-Upgradeable-Packages \"1\";

  // Do \"apt-get autoclean\" every n-days (0=disable)
  APT::Periodic::AutocleanInterval \"7\";

  // Send report mail to root
  //     0:  no report             (or null string)
  //     1:  progress report       (actually any string)
  //     2:  + command outputs     (remove -qq, remove 2>/dev/null, add -d)
  //     3:  + trace on    APT::Periodic::Verbose \"2\";
  APT::Periodic::Unattended-Upgrade \"1\";

  // Automatically upgrade packages from these
  Unattended-Upgrade::Origins-Pattern {
        \"o=Debian,a=stable\";
        \"o=Debian,a=stable-updates\";
        \"origin=Debian,codename=\${distro_codename},label=Debian-Security\";
  };

  // You can specify your own packages to NOT automatically upgrade here
  Unattended-Upgrade::Package-Blacklist {
  };

  // Run dpkg --force-confold --configure -a if a unclean dpkg state is detected to true to ensure that updates get installed even when the system got interrupted during a previous run
  Unattended-Upgrade::AutoFixInterruptedDpkg \"true\";

  //Perform the upgrade when the machine is running because we wont be shutting our server down often
  Unattended-Upgrade::InstallOnShutdown \"false\";

  // Send an email to this address with information about the packages upgraded.
  Unattended-Upgrade::Mail \"root\";

  // Always send an e-mail
  Unattended-Upgrade::MailReport \"on-change\";

  // Remove all unused dependencies after the upgrade has finished
  Unattended-Upgrade::Remove-Unused-Dependencies \"true\";

  // Remove any new unused dependencies after the upgrade has finished
  Unattended-Upgrade::Remove-New-Unused-Dependencies \"true\";

  // Automatically reboot WITHOUT CONFIRMATION if the file /var/run/reboot-required is found after the upgrade.
  Unattended-Upgrade::Automatic-Reboot \"true\";

  // Automatically reboot even if users are logged in.
  Unattended-Upgrade::Automatic-Reboot-WithUsers \"false\";
  " >>/etc/apt/apt.conf.d/51-unattended-upgrades

  echo -e "Dry run of unattended-upgrades"
  sudo unattended-upgrades --dry-run --debug
  sleep 5

  echo -e "${BLUE}Configure apt-listchanges (A Dialog will appear in 10 seconds)${NC}"
  sleep 10
  sudo dpkg-reconfigure apt-listchanges

  echo -e "Configure apticron (Please Wait)"

  if [ ! -v EMAIL_ACCOUNT ]; then # If $EMAIL_ACCOUNT is not set
    # Ask for E-Mail Address
    read -p "$(echo -e "${ORANGE}Enter your E-Mail Address: ${NC}")" EMAIL_ACCOUNT
  fi
  sed -i "s/EMAIL=\"root\"/EMAIL=\"${EMAIL_ACCOUNT}\"/g" /usr/lib/apticron/apticron.conf
  sed -i 's/NOTIFY_NO_UPDATES="0"/NOTIFY_NO_UPDATES="1"/g' /usr/lib/apticron/apticron.conf
  sudo apticron
fi

echo -e "\n"

# --------------------------------------------------
# Section: Port Scan Attack Detector
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Port Scan Attack Detector${NC}"
echo -e "${BLUE}${BASE_URL}/steps/psad${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_PSAD
if [[ $RUN_PSAD =~ ^[Yy]?$ ]]; then
  echo -e "Install psad"
  sudo apt install psad -y

  echo -e "Configure psad"
  if [ ! -v EMAIL_ACCOUNT ]; then # If $EMAIL_ACCOUNT is not set
    # Ask for E-Mail Address
    read -p "$(echo -e "${ORANGE}Enter your E-Mail Address: ${NC}")" EMAIL_ACCOUNT
  fi
  sed -i "/^EMAIL_ADDRESSES / s/.*/EMAIL_ADDRESSES     ${EMAIL_ACCOUNT};/" /etc/psad/psad.conf
  sed -i '/^HOSTNAME / s/.*/HOSTNAME            Node1;/' /etc/psad/psad.conf
  sed -i '/^ENABLE_PSADWATCHD / s/.*/ENABLE_PSADWATCHD Y;/' /etc/psad/psad.conf
  sed -i '/^ENABLE_AUTO_IDS  / s/.*/ENABLE_AUTO_IDS Y;/' /etc/psad/psad.conf
  sed -i '/^ENABLE_AUTO_IDS_EMAILS / s/.*/ENABLE_AUTO_IDS_EMAILS Y;/' /etc/psad/psad.conf
  sed -i '/^EXPECT_TCP_OPTIONS / s/.*/EXPECT_TCP_OPTIONS Y;/' /etc/psad/psad.conf

  echo -e "Create Backup of before.rules"
  cp --archive /etc/ufw/before.rules /etc/ufw/before.rules-COPY-"$(date +"%Y%m%d%H%M%S")"
  cp --archive /etc/ufw/before6.rules /etc/ufw/before6.rules-COPY-"$(date +"%Y%m%d%H%M%S")"

  echo -e "Configure UFW for psad"
  sed -i '/COMMIT/d' /etc/ufw/before.rules  # $ means the last line, and d means delete:
  sed -i '/COMMIT/d' /etc/ufw/before6.rules # Remove the COMMIT Line
  sleep 2
  echo '-A INPUT -j LOG --log-tcp-options --log-prefix "[IPTABLES] "' >>/etc/ufw/before.rules
  echo '-A INPUT -j LOG --log-tcp-options --log-prefix "[IPTABLES] "' >>/etc/ufw/before6.rules
  echo '-A FORWARD -j LOG --log-tcp-options --log-prefix "[IPTABLES] "' >>/etc/ufw/before.rules
  echo '-A FORWARD -j LOG --log-tcp-options --log-prefix "[IPTABLES] "' >>/etc/ufw/before6.rules
  echo 'COMMIT' >>/etc/ufw/before.rules
  echo 'COMMIT' >>/etc/ufw/before6.rules

  echo -e "Reload ufw"
  sudo ufw reload

  echo -e "Start psad"
  sudo psad -R
  sudo psad --sig-update
  sudo psad -H
fi

echo -e "\n"

# --------------------------------------------------
# Section: Fail2Ban
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Fail2Ban${NC}"
echo -e "${BLUE}${BASE_URL}/steps/fail2ban${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_FAIL2BAN
if [[ $RUN_FAIL2BAN =~ ^[Yy]?$ ]]; then
  echo -e "Install fail2ban"
  sudo apt install fail2ban -y

  echo -e "Copy jail.conf to jail.local"
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

  echo -e "Configure fail2ban"

  echo -e "Increase bantime to 1 day"
  sed -i 's/bantime  = 10m/bantime  = 24h/' /etc/fail2ban/jail.local

  echo -e "Increase findtime to 1 day"
  sed -i 's/findtime  = 10m/findtime  = 24h/' /etc/fail2ban/jail.local

  echo -e "Decrease maxretry to 3"
  sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local

  echo -e "Change banaction to ufw"
  sed -i 's/banaction = iptables-multiport/banaction = ufw/' /etc/fail2ban/jail.local

  echo -e "Configure SSH Jail"
  if [ ! -v SSH_PORT ]; then # If $SSH_PORT is not set
    # Ask for SSH_PORT
    read -p "$(echo -e "${ORANGE}Enter your SSH Port: ${NC}")" SSH_PORT
  fi
  sed -i '/^\[sshd\]$/a\enabled = true\nbanaction = ufw' /etc/fail2ban/jail.local
  sed -i "s/port    = ssh/port    = ssh,${SSH_PORT}/" /etc/fail2ban/jail.local

  echo -e "Enable and Start fail2ban"
  systemctl enable fail2ban
  systemctl start fail2ban
fi

echo -e "\n"

# --------------------------------------------------
# Section: WireGuard VPN
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: WireGuard VPN ${NC}"
echo -e "${BLUE}${BASE_URL}/steps/wireguard${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_WIREGUARD
if [[ $RUN_WIREGUARD =~ ^[Yy]?$ ]]; then
  echo -e "Install WireGuard"
  sudo apt install wireguard -y

  echo -e "Generate WireGuard Private Key"
  wg genkey >>/etc/wireguard/private.key
  sudo chmod go= /etc/wireguard/private.key
  sleep 3

  echo -e "Generate WireGuard Public Key"
  sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
  sleep 3

  echo -e "Create WireGuard Config"
  echo "[Interface]" >>/etc/wireguard/wg0.conf
  echo "PrivateKey = $(sudo cat /etc/wireguard/private.key)" >>/etc/wireguard/wg0.conf
  echo "Address = 10.8.0.1/24" >>/etc/wireguard/wg0.conf
  echo "ListenPort = 51820" >>/etc/wireguard/wg0.conf
  echo "SaveConfig = true" >>/etc/wireguard/wg0.conf

  echo -e "Configure WireGuard Client"
  echo -e "${GREEN}WireGuard Server Public Key: $(sudo cat /etc/wireguard/public.key)${NC}"
  read -p "Enter your WireGuard Client's public key: " WIREGUARD_PUBLIC_KEY
  echo "" >>/etc/wireguard/wg0.conf
  echo "[Peer]" >>/etc/wireguard/wg0.conf
  echo "PublicKey = ${WIREGUARD_PUBLIC_KEY}" >>/etc/wireguard/wg0.conf
  read -p "Enter your WireGuard client IP address: " WIREGUARD_CLIENT_IP
  echo "AllowedIPs = ${WIREGUARD_CLIENT_IP}/32" >>/etc/wireguard/wg0.conf

  echo -e "Configure WireGuard Firewall"
  sudo ufw allow 51820/udp

  echo -e "Enable WireGuard"
  sudo systemctl enable wg-quick@wg0.service

  echo -e "Start WireGuard"
  sudo systemctl start wg-quick@wg0.service

  echo -e "Wireguard Status"
  sudo wg show
  sleep 5
fi

echo -e "\n"

# --------------------------------------------------
# Section: Awesome Shell
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Awesome Shell${NC}"
echo -e "${BLUE}${BASE_URL}/steps/install_software${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_AWESOME_SHELL
if [[ $RUN_AWESOME_SHELL =~ ^[Yy]?$ ]]; then
  echo -e "\n"
  echo -e "Install ${ORANGE}neofetch${NC}"
  sleep 2
  sudo apt install neofetch -y

  echo -e "\n"
  echo -e "Install ${ORANGE}exa${NC}"
  sleep 2
  sudo apt install exa -y
  echo "alias ls='exa -la --icons --headers'" >>/home/"$USERNAME"/.bashrc

  echo -e "\n"
  echo -e "Install ${ORANGE}bat${NC}"
  sleep 2
  sudo apt install bat -y
  echo "alias bat='batcat'" >>/home/"$USERNAME"/.bashrc

  echo -e "\n"
  echo -e "Install ${ORANGE}micro${NC}"
  sleep 2
  sudo apt install micro -y

  echo -e "\n"
  echo -e "Install ${ORANGE}htop${NC}"
  sleep 2
  sudo apt install htop -y

  echo -e "\n"
  echo -e "Install ${ORANGE}thefuck${NC}"
  sleep 2
  sudo apt install python3-dev python3-pip python3-setuptools -y
  pip3 install thefuck
  echo "eval $(thefuck --alias)" >>/home/"$USERNAME"/.bashrc

  echo -e "\n"
  echo -e "Install ${ORANGE}fd${NC}"
  sleep 2
  sudo apt install fd-find

  echo -e "\n"
  echo -e "Install ${ORANGE}tldr${NC}"
  sleep 2
  pip3 install tldr

  echo -e "\n"
  echo -e "Install ${ORANGE}nvm${NC}"
  sleep 2
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  echo "export NVM_DIR=\"$HOME/.nvm\"" >>/home/"$USERNAME"/.bashrc
  echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"  # This loads nvm" >>/home/"$USERNAME"/.bashrc
  echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"  \# This loads nvm bash_completion" >>/home/"$USERNAME"/.bashrc
  source /root/.bashrc
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm install v18.16.0
fi

echo -e "\n"

# --------------------------------------------------
# Section: .bashrc File
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: .bashrc File${NC}"
echo -e "${BLUE}${BASE_URL}/steps/bash_config${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_BASHRC
if [[ $RUN_BASHRC =~ ^[Yy]?$ ]]; then

  echo -e "Add Timestamp to .bashrc"
  echo "export HISTTIMEFORMAT=\"%F %T \"" >>/root/.bashrc
  echo "export HISTTIMEFORMAT=\"%F %T \"" >>/home/"${USERNAME}"/.bashrc

  echo -e "Create Custom Bash Prompt"
  touch /home/"${USERNAME}"/.bashrc
  echo "
### PS1 SETTINGS =======================================================

# show more git info in PS1
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWSTASHSTATE=true

# colors
export PS1_GREY=\"\[\$(tput bold; tput setaf 0)\]\"
export PS1_GREEN=\"\[\$(tput bold; tput setaf 2)\]\"
export PS1_YELLOW=\"\[\$(tput bold; tput setaf 3)\]\"
export PS1_MAGENTA=\"\[\$(tput bold; tput setaf 5)\]\"
export PS1_CYAN=\"\[\$(tput bold; tput setaf 6)\]\"
export PS1_WHITE=\"\[\$(tput bold; tput setaf 7)\]\"
export PS1_RESET=\"\[\$(tput sgr0)\]\"

BRACKET_COLOR=\"\[\033[38;5;35m\]\"
CLOCK_COLOR=\"\[\033[38;5;35m\]\"
JOB_COLOR=\"\[\033[38;5;33m\]\"
PATH_COLOR=\"\[\033[38;5;33m\]\"
LINE_BOTTOM=\"\342\224\200\"
LINE_BOTTOM_CORNER=\"\342\224\224\"
LINE_COLOR=\"\[\033[38;5;248m\]\"
LINE_STRAIGHT=\"\342\224\200\"
LINE_UPPER_CORNER=\"\342\224\214\"
END_CHARACTER=\"|\"
FIRST_LINE=\"\$LINE_COLOR\$LINE_UPPER_CORNER\$LINE_STRAIGHT\$LINE_STRAIGHT\"
SECOND_LINE=\"\$LINE_COLOR\$LINE_BOTTOM_CORNER\$LINE_STRAIGHT\$LINE_BOTTOM\"
END_LINE=\"\$LINE_COLOR\$LINE_STRAIGHT\$LINE_STRAIGHT\$END_CHARACTER\"
LOGGED_IN_USER=\"\${PS1_MAGENTA}\u\"
WORKING_DIR=\"\${PS1_GREEN}\w\"

TIME=\"\$BRACKET_COLOR[\$CLOCK_COLOR\t\$BRACKET_COLOR]\"

# function to set PS1
function _bash_prompt(){
    # git info
    local GIT_INFO=\$(git branch &>/dev/null && echo \"\${PS1_CYAN}git\${PS1_WHITE}:\$(__git_ps1 '%s')\")

    # add <esc>k<esc>\ to PS1 if screen is running
    # see man(1) screen, section TITLES for more
    if [[ \"\$TERM\" == screen* ]]; then
        local SCREEN_ESC='\[\ek\e\\\]'
    else
        local SCREEN_ESC=''
    fi

    # finally, set PS1
    PS1=\"\n\$FIRST_LINE \${PS1_GREY}logged in as \$LOGGED_IN_USER \${PS1_GREY}on\${PS1_YELLOW} \h \${PS1_GREY}at \$CLOCK_COLOR\t \${GIT_INFO}\
        \n\$SECOND_LINE \$WORKING_DIR \${SCREEN_ESC}\${PS1_WHITE}> \"
}

# call _bash_prompt() each time the prompt is refreshed
export PROMPT_COMMAND=_bash_prompt
" >/home/${USERNAME}/.bash_prompt

  echo "source ~/.bash_prompt" >>/home/"${USERNAME}"/.bashrc
fi

echo -e "\n"

# --------------------------------------------------
# Section: Docker
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Docker ${NC}"
echo -e "${BLUE}${BASE_URL}/steps/docker${NC}"
read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_DOCKER
if [[ $RUN_DOCKER =~ ^[Yy]?$ ]]; then
  echo -e "Install Docker"
  sudo apt install apt-transport-https ca-certificates curl gnupg -y
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

  echo -e "Add ${USERNAME} to Docker group"
  sudo usermod -aG docker "${USERNAME}"

  echo -e "Create Docker Network"
  read -p "Enter the name of the Docker network: " DOCKER_NETWORK_NAME
  echo -e "Enter the IP Subnet of the Docker network:"
  echo -e "Subnet is based on Network Class C and the CIDR notation is /24"
  echo -e "Example: ${GREEN}192.168.80${NC} | will allow for IP's in the range from 192.168.80.1 to 192.168.80.254"
  echo -e "${RED}Do not use the same IP Subnet as your home network${NC}"
  echo -e "${RED}Do not Input a full IP Address. Three Dots only!${NC}"
  read -p "Enter the IP Subnet of the Docker network: " DOCKER_NETWORK_IP
  sudo docker network create --driver=bridge --subnet="${DOCKER_NETWORK_IP}".0/24 --gateway="${DOCKER_NETWORK_IP}".1 "${DOCKER_NETWORK_NAME}"
fi

echo -e "\n"

# --------------------------------------------------
# Section: Portainer
# --------------------------------------------------
sleep 5
echo -e "${PURPLE}Section: Portainer ${NC}"
echo -e "${BLUE}${BASE_URL}/steps/portainer${NC}"
if [[ $RUN_DOCKER =~ ^[Yy]?$ ]]; then

  read -p "$(echo -e "${ORANGE}Run this Section? (Y/n) ${NC}")" -n 1 -r RUN_PORTAINER
  if [[ $RUN_PORTAINER =~ ^[Yy]?$ ]]; then

    echo -e "Install Portainer"
    sudo docker volume create portainer_data

    echo -e "Create Portainer Container"
    sudo docker run -d \
      -p 127.0.0.1:9443:9443 \
      --name=portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      --network="${DOCKER_NETWORK_NAME}" \
      --ip "${DOCKER_NETWORK_IP}".2 \
      portainer/portainer-ce:latest

      echo -e "Portainer is now available at ${GREEN}https://${DOCKER_NETWORK_IP}.2:9443${NC}"
  fi
else echo -e "${RED}Skipping Section${NC}"; fi

echo -e "\n"
# --------------------------------------------------

echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${RED}Thank You for traveling with Deutsche Bahn${NC}"
echo ""
echo -e "${GREEN}Please Reboot your system${NC}"
