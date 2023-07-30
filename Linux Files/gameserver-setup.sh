#!/bin/bash
# GSS Script - Gameserver Setup: Simply download after installing debian on a machine and this script will do the rest!
# Warning: This script assumes the user to be root or have root rights!

#General Variables
work="\e[44;97m[WORK]\e[39;49;1m"
done="\e[1A\e[42;30m[DONE]\e[39;49;1m"
done2="\e[2A\e[42;30m[DONE]\e[39;49;1m"
error="\e[41;97;1m[ERROR]"
warning="\e[103;30;1m[WARNING]\e[39;49;1m"
text="\e[107;90m"
reset="\e[0m"
stretchToEol="\x1B[K"

#Check if the system is debian or debian-based
if [[ $(lsb_release -d | grep "Debian") ]]; then
    echo -e $text"OS Type is Debian-based."$stretchToEol $reset
else
    echo -e $error "The operating system is not Debian, aborting!"$stretchToEol $reset
    exit 1
fi

#Check if user is root or has sudo rights
if [[ $EUID -eq 0 ]]; then
  su=
else
  if grep -q "$USER" /etc/sudoers; then
    su=sudo
  else
    echo -e $error "You do not have sudo rights!"$stretchToEol $reset
    exit 1
  fi
fi

#Install updates and basic tools
echo -e $work "Updating packages and downloading basic tools..."$stretchToEol $reset
$su apt update -y >> /dev/null 2>&1 
$su apt upgrade -y >> /dev/null 2>&1 
$su apt install -y vim wget htop git curl apache2 zip unzip ufw net-tools certbot software-properties-common >> /dev/null 2>&1 
echo -e $done "Updating packages and downloading basic tools..."$stretchToEol $reset

#Enable root login over ssh and set the port to 2222 for security reasons
echo -e $work "Enabling root login over ssh and set the port to 2222..."$stretchToEol $reset
$su sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
$su sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
$su service ssh restart
echo -e $done "Enabling root login over ssh and set the port to 2222..."$stretchToEol $reset

#Install Pufferpanel
echo -e $work "Installing Pufferpanel..."$stretchToEol $reset
if [[ $(lsb_release -d | grep "Debian GNU/Linux 12") ]]; then
export os=debian
export dist=bullseye
curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | $su bash
elif [[ $(lsb_release -d | grep "Debian GNU/Linux 11") ]]; then
curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | $su bash
fi
$su apt-get install pufferpanel >> /dev/null 2>&1 
$su systemctl enable pufferpanel >> /dev/null 2>&1 
$su pufferpanel user add
$su systemctl enable --now pufferpanel >> /dev/null 2>&1 
echo -e $done "Installing Pufferpanel..."$stretchToEol $reset

#Add rules to ufw
echo -e $work "Configuring the firewall..."$stretchToEol $reset
$su ufw allow 80/tcp >> /dev/null 2>&1 
$su ufw allow 8080/tcp >> /dev/null 2>&1 
$su ufw allow 443/tcp >> /dev/null 2>&1 
$su ufw allow 25565/tcp >> /dev/null 2>&1 
$su ufw allow 5657/tcp >> /dev/null 2>&1 
$su ufw allow 2222/tcp >> /dev/null 2>&1 
$su ufw enable >> /dev/null 2>&1 
echo -e $done "Configuring the firewall..."$stretchToEol $reset

#Install Java 17 for minecraft servers
echo -e $work "Installing Java 17..."$stretchToEol $reset
#$su add-apt-repository ppa:openjdk-r/ppa >> /dev/null 2>&1 <<<<<<<<<<<<<<< This is probably not necessary so it is commented out.
$su apt update >> /dev/null 2>&1 
$su apt install openjdk-17-jdk -y >> /dev/null 2>&1 
if [[ $(java -version 2>&1 | grep "openjdk version") ]]; then
  echo -e $text"Installed java version is Java $(java -version 2>&1 | head -1 | cut -d '"' -f2)"$stretchToEol $reset
else
  echo -e $error "Something went wrong during the installation of Java 17, aborting!"$stretchToEol $reset
  exit 1
fi
echo -e $done2 "Installing Java 17..."$stretchToEol $reset

echo -e $text"Would you like to configure the webserver? ($warning Requires DNS Record!$reset) (y/N)"$stretchToEol $reset
read -rp $text"Press Enter for default (y): "$reset answer3
answer3=${answer3:-y}
if [[ $answer3 =~ "y" ]]; then
  $su a2enmod proxy
  $su a2enmod proxy_http
  $su a2enmod proxy_balancer
  $su a2enmod lbmethod_byrequests
  $su systemctl restart apache2
    echo -e "Would you like to enable SSL for the Webpanel? (y/N)"
    read -rp $text"Press Enter for default (y): "$reset answer2
    answer2=${answer2:-y}
    if [[ $answer2 =~ "y" ]]; then
      read -rp $text"Please input the FQDN for the webpanel: "$reset fqdn 
      cat << EOF | tee -a /etc/apache2/sites-available/"$fqdn".conf
<VirtualHost *:80>
        ServerName $fqdn
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI}
</VirtualHost>
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName $fqdn

        ProxyPreserveHost On
        SSLProxyEngine On
        ProxyPass / http://localhost:8080/
        ProxyPassReverse / http://localhost:8080/

        RewriteEngine on
        RewriteCond %{HTTP:Upgrade} websocket [NC]
        RewriteCond %{HTTP:Connection} upgrade [NC]
        RewriteRule .* ws://localhost:8080%{REQUEST_URI} [P]

        SSLEngine on
        SSLCertificateFile /etc/letsencrypt/live/$fqdn/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/$fqdn/privkey.pem
    </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF
    else
      read -rp $text"Please input the FQDN for the webpanel: "$reset fqdn 
      cat << EOF | tee -a /etc/apache2/sites-available/"$fqdn".conf
<VirtualHost *:80>
    ServerName $fqdn
    ProxyPreserveHost On
    ProxyRequests Off
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
</VirtualHost>
EOF
    fi
    apache2ctl configtest
    apache2ctl reload
fi


#Optional configuration for rclone and onedrive:
echo -e "$warning This is only for advanced users as this is not fully automatable!$stretchToEol $reset"
echo -e "Would you like to install all necessary packages for offsite server backups using onedrive? (y/N)"
read -rp "Press Enter for default (y): " answer0
answer0=${answer0:-y}
if [[ $answer0 =~ "y" ]]; then
  echo -e "Please follow the instructions listed in this article starting at step 3: https://itsfoss.com/use-onedrive-linux-rclone/"
  apt install rclone firefox firefox-esr browsh -y
  echo -e "Done. You can use browsh [onedrive login link] to connect your microsoft account to rclone!"
  mkdir /root/onedrive
  echo -e "Created new directory /root/onedrive for usage in rclone."
  echo -e "The script will end here for further configuration of rclone."
  exit 0
fi

echo -e "$warning The following only works if you have installed rclone and configured it to be used with onedrive!$stretchToEol $reset"
echo -e "Would you like to configure rclone to be run at startup and auto-connect? (y/N)"
read -rp "Press Enter for default (y): " answer1
answer1=${answer1:-y}
if [[ $answer1 =~ "y" ]]; then
  cat << EOF | tee -a /etc/systemd/system/rclonemount.service
[Unit]
Description=rclonemount
AssertPathIsDirectory=/root/onedrive
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount \
        --config=/root/.config/rclone/rclone.conf \
        --vfs-cache-mode writes \
        onedrive:Gameserver_Backup /root/OneDrive
ExecStop=/bin/fusermount -u /root/OneDrive
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
systemctl start rclonemount 
status=$(systemctl status rclonemount.service | grep -E "Active: (failed|dead)")
    if [[ "$status" == "Active: failed" ]]; then
      echo -e $error "The rclonemount.service was unable to start, please check the rclone config!"$stretchToEol $reset
      exit 1
    else
      systemctl enable rclonemount.service
      systemctl daemon-reload
    fi
fi
