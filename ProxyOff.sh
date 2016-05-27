#!/bin/bash
# This script removes all system-wide proxy settings and may need to be run with sudo
# This was created for Ubuntu 12.04 and derivatives
# Version 2014.09.30


# Check for running with bash
if [ "$BASH" != "/bin/bash" ]; then
  printf "Please run with ./$0 \n"
  exit 1
fi


gsettings set org.gnome.system.proxy mode "none"


if [ $EUID != 0 ]; then 
	printf "The proxy is turned off for you. \n"
	notify-send "The proxy is turned off for you."
else {

	printf "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games\" \n" > /etc/environment

	printf "" > /etc/apt/apt.conf

	printf "The proxy has been turned off everywhere! \n"
	notify-send "The proxy has been turned off everywhere!"
}
fi


sleep 2
exit
