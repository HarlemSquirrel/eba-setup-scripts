#!/bin/bash
# This script sets the NYC DOE proxy server system-wide and may need to be run with sudo
# This was created for Ubuntu 12.04 and derivatives
# Version 2014.09.30


# Check for running with bash
if [ "$BASH" != "/bin/bash" ]; then
  printf "Please run with ./$0 \n"
  exit 1
fi


if [ $EUID != 0 ]; then 
	# Set the proxy for GNOME, Unity, or Cinnamin
	gsettings set org.gnome.system.proxy mode "auto"
	gsettings set org.gnome.system.proxy autoconfig-url "http://proxy.nycboe.org/proxy.pac"
	printf "The NYC DOE proxy is set for you. \n"
	notify-send "The NYC DOE proxy is set for you."
else
	printf "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games\"

http_proxy=http://filtr.nycboe.org:8002/ \n" > /etc/environment

	printf "Acquire::http::Proxy \"http://filtr.nycboe.org:8002\"; \n" > /etc/apt/apt.conf

	notify-send "The NYC DOE proxy is set systemwide!"
	printf "The NYC DOE proxy is set systemwide! \n"
fi


sleep 2
exit
