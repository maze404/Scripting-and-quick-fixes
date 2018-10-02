#!/bin/bash
read -p "Please input the desired username and press [ENTER]:  " username

# FOR UBUNTU sudo su -c "useradd $username -s /bin/bash -m -G adm, cdrom, sudo, dip, plugdev, lpadmin, sambashare"
sudo su -c "useradd $username -s /bin/bash -m -G adm,cdrom,sudo,dip,plugdev" # FOR DEBIAN
echo -e "Please input a new password for the USER account:  "
sleep 1
sudo passwd $username
echo -e "Please input a new password for the ROOT access: "
sleep 1
sudo passwd
echo -e "All done. Please log out and log in again and choose the new profile."