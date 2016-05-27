#!/bin/bash

# Version 2014.06.09
# This script sets the ability for all users to change network connections and connect to wireless networks Ubuntu 12.04 and variants
# by Kevin McCormack


# Clear the screen and introduce the elves
clear
echo "$(tput setaf 6)The elves are requesting authorization...$(tput sgr0)" # cyan


sudo sed -i "695s/auth_admin_keep/yes/g" /usr/share/polkit-1/actions/org.freedesktop.NetworkManager.policy

# Display message and exit
echo "$(tput setaf 2)The elves have set the system to allow all users to connect to wireless networks.$(tput sgr0)"
read -p "$(tput setaf 2)Press <ENTER> to close...$(tput sgr0)" answer
exit
