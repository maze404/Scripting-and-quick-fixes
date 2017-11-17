#!/bin/bash
echo "Welcome, what would you like to do?"
PS3="Select one of the numbers from above: "
options=("Update Repositories & install updates" "Remove and clean unused packages" "Start TLP manager" "Fix xhost problem" "Exit")
select opt in "${options[@]}"
do 
case $opt in

"Update Repositories & install updates")
echo "Updating repositories and installing updates"
sudo apt update && sudo apt upgrade && sudo apt dist-upgrade
;;

"Remove and clean unused packages")
echo "Removice unused packages and cleaning up"
sudo apt autoremove && sudo apt autoclean
;;

"Start TLP manager")
echo "Starting TLP manager"
sudo tlp start
sudo tlp start usb
;;

"Fix xhost problem")
logout
xhost +
;;

"Exit")
break
;;

*) echo "Invalit option";;

esac
done
clear
echo "All done, Goodbye!"
