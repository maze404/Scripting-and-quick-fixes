#!/bin/bash
echo "$(tput bold)###############################################################$(tput sgr0)"
echo "$(tput bold)##    Please input the desired username and press [ENTER]    ##$(tput sgr0)"
echo "$(tput bold)###############################################################$(tput sgr0)"
read -p "Username: " username
echo ""
# FOR UBUNTU sudo su -c "useradd $username -s /bin/bash -m -G adm, cdrom, sudo, dip, plugdev, lpadmin, sambashare"
sudo su -c "useradd $username -s /bin/bash -m -G adm,cdrom,sudo,dip,plugdev" # FOR DEBIAN
echo "$(tput bold)################################################################$(tput sgr0)"
echo "$(tput bold)##      Please input a new password for the USER account      ##$(tput sgr0)"
sleep 1
sudo passwd $username
echo "$(tput bold)################################################################$(tput sgr0)"
echo ""

echo "$(tput bold)################################################################$(tput sgr0)"
echo "$(tput bold)##      Please input a new password for the ROOT account      ##$(tput sgr0)"
sleep 1
sudo passwd 
echo "$(tput bold)################################################################$(tput sgr0)"
echo ""

echo "$(tput bold)################################################################$(tput sgr0)"
sleep 1
echo -e "All done. Please log out and log in again and choose the new profile."