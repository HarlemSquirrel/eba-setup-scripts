#!/bin/bash

# This script installs wireless drivers for Ubuntu 12.04 or 14.04 behind the NYC DOE Proxy server
# by Kevin McCormack


# function to check for errors
error_check () {
	if [ $? != 0 ]; then
		tput setaf 1
		printf "That did not work! Exiting now.\n"
		tput sgr0
		exit
	else
		tput setaf 2
		printf "done!\n"
		tput sgr0
	fi
}


# Get the computer product name
MODEL=$(cat "/sys/class/dmi/id/product_name");


# Set the proxy server
export http_proxy=http://proxy:8002


printf "Updating the package lists..."
sudo -E apt-get -qq update
error_check;


if (lspci -d 14e4:4311 || lspci -d 14e4:4315 || lspci -d 14e4:4318) then
	# Lenovo S10e and HP 6445b
	printf "Installing drivers for BCM4312 (14e4:4315)..."
	sudo -E apt-get -qq install firmware-b43-installer || sudo -E apt-get -qq install firmware-b43-lpphy-installer
	error_check;
else
	printf "We don't recognize the WiFi device in this $MODEL!\n"
	lspci -vnn -d 14e4:
	exit
fi


printf "Cleaning up any uneeded packages..."
sudo apt-get -qq autoremove
error_check;

printf "It looks like we are all done here. You might have to reboot for your new drivers to take effect.\n"
