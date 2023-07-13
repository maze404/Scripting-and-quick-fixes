#!/bin/bash
# GSS Script - Gameserver Setup: Simply download after installing debian on a machine and this script will do the rest!
# Warning: This script assumes the user to be root or have root rights!

#Check if the system is debian or debian-based
if [[ $(lsb_release -d) != "Debian" ]]; then
    echo "The operating system is not Debian, aborting!"
    exit 1
fi

#Check if user is root or has sudo rights
if [[ $EUID -eq 0 ]]; then
  su=
else
  if grep -q "$USER" /etc/sudoers; then
    su=sudo
  else
    echo "You do not have sudo rights!"
    exit 1
  fi
fi

#Install updates and basic tools
$su apt update -y
$su apt upgrade -y 
$su apt install -y vim wget htop git curl nginx zip unzip ufw net-tools 

#Enable root login over ssh and set the port to 2222 for security reasons
$su sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
$su sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
$su service ssh restart

#Install Pufferpanel
curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | $su bash
$su apt-get install pufferpanel
$su systemctl enable pufferpanel
$su pufferpanel user add
$su systemctl enable --now pufferpanel

#Add rules to ufw
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 443/tcp
sudo ufw allow 25565/tcp
sudo ufw allow 5657/tcp
sudo ufw allow 2222/tcp
sudo ufw enable

#Install Java 17 for minecraft servers
$su add-apt-repository ppa:openjdk-r/ppa
$su apt update
$su apt install openjdk-17-jdk -y
if [[ $(java -version | grep -E "openjdk version 17") == "" ]]; then
  echo "Something went wrong during the installation of Java 17, aborting!"
  exit 1
fi

echo "Warning: This is only for advanced users as this is not fully automatable!"
echo "Would you like to install all necessary packages for offsite server backups using onedrive? (y/N)"
read -rp "Press Enter for default (y): "
answer0=${answer0:-y}
if [[ $answer0 =~ "y" ]]; then
  echo "Please follow the instructions listed in this article starting at step 3: https://itsfoss.com/use-onedrive-linux-rclone/"
  apt install rclone firefox firefox-esr browsh -y
  echo "Done. You can use browsh [onedrive login link] to connect your microsoft account to rclone!"
  mkdir /root/onedrive
  echo "Created new directory /root/onedrive for usage in rclone."
  echo "The script will end here for further configuration of rclone."
  exit 0
fi

echo "Warning: The following only works if you have installed rclone and configured it to be used with onedrive!"
echo "Would you like to configure rclone to be run at startup and auto-connect? (y/N)"
read -rp "Press Enter for default (y): "
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
      echo "The rclonemount.service was unable to start, please check the rclone config!"
      exit 1
    else
      systemctl enable rclonemount.service
      systemctl daemon-reload
    fi
fi